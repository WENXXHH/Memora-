import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/core/storage/data_owner.dart';
import 'package:memora/domain/models/word_review_model.dart';
import 'package:memora/data/services/user_data_space_service.dart';

/// UserDataSpaceService 迁移与切换测试。
///
/// 使用真实 Hive reviews/auth Box（临时目录），覆盖：
/// 1. currentOwner 缺省为 guest
/// 2. migrateLegacyKeysToGuest：旧格式 key 归入 guest 空间
/// 3. switchToUser：guest 成果迁入用户空间、LWW 冲突处理、清空 guest 空间
/// 4. switchToGuest：owner 切回且用户空间数据保留
void main() {
  late Directory tempDir;
  late Box<Map<dynamic, dynamic>> reviewsBox;
  late Box<String> authBox;
  late UserDataSpaceService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('user_data_space_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    reviewsBox = await Hive.openBox<Map<dynamic, dynamic>>('reviews');
    authBox = await Hive.openBox<String>('auth');
    await reviewsBox.clear();
    await authBox.clear();
    service = UserDataSpaceService(reviewsBox, authBox);
  });

  tearDown(() async {
    await reviewsBox.close();
    await authBox.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('currentOwner', () {
    test('未设置时缺省为 guest', () {
      expect(service.currentOwner(), kGuestOwner);
    });

    test('switchToUser 后返回该用户空间', () async {
      await service.switchToUser('42');

      expect(service.currentOwner(), userOwnerKey('42'));
      expect(authBox.get(kDataOwnerKey), userOwnerKey('42'));
    });
  });

  group('migrateLegacyKeysToGuest', () {
    test('旧格式 key 归入 guest 空间且数据不变', () async {
      // 模拟历史版本数据：无 owner 前缀
      await reviewsBox.put('cet6:1', _review('1', 'cet6').toJson());
      await reviewsBox.put('custom_abc:9', _review('9', 'custom_abc').toJson());

      await service.migrateLegacyKeysToGuest();

      expect(reviewsBox.containsKey('cet6:1'), isFalse);
      expect(reviewsBox.containsKey('$kGuestOwner|cet6:1'), isTrue);
      expect(
        WordReview.fromJson(
          Map<String, dynamic>.from(reviewsBox.get('$kGuestOwner|cet6:1')!),
        ).wordId,
        '1',
      );
      // 已带前缀的 key 不受影响
      await reviewsBox.put('${userOwnerKey('1')}|cet6:1', {}.cast<String, dynamic>());
      await service.migrateLegacyKeysToGuest();
      expect(reviewsBox.containsKey('${userOwnerKey('1')}|cet6:1'), isTrue);
    });

    test('重复调用幂等', () async {
      await reviewsBox.put('cet6:1', _review('1', 'cet6').toJson());

      await service.migrateLegacyKeysToGuest();
      await service.migrateLegacyKeysToGuest();

      expect(reviewsBox.length, 1);
      expect(reviewsBox.containsKey('$kGuestOwner|cet6:1'), isTrue);
    });
  });

  group('switchToUser', () {
    test('guest 学习成果迁入用户空间，guest 空间清空', () async {
      await authBox.put(kDataOwnerKey, kGuestOwner);
      await reviewsBox.put('$kGuestOwner|cet6:1', _review('1', 'cet6').toJson());
      await reviewsBox.put(
        '$kGuestOwner|cet6:2',
        _review('2', 'cet6').toJson(),
      );

      await service.switchToUser('7');

      final target = userOwnerKey('7');
      expect(reviewsBox.containsKey('$target|cet6:1'), isTrue);
      expect(reviewsBox.containsKey('$target|cet6:2'), isTrue);
      expect(reviewsBox.containsKey('$kGuestOwner|cet6:1'), isFalse);
      expect(service.currentOwner(), target);
    });

    test('与用户空间已有记录冲突时 LWW（guest 较新则 guest 胜）', () async {
      final target = userOwnerKey('7');
      final older = DateTime.utc(2026, 1, 1);
      final newer = DateTime.utc(2026, 9, 1);

      // 用户空间已有旧记录
      await reviewsBox.put(
        '$target|cet6:1',
        _review('1', 'cet6', clientUpdatedAt: older, mastery: 0.2).toJson(),
      );
      // guest 空间是较新的学习成果
      await reviewsBox.put(
        '$kGuestOwner|cet6:1',
        _review('1', 'cet6', clientUpdatedAt: newer, mastery: 0.8).toJson(),
      );

      await service.switchToUser('7');

      final winner = WordReview.fromJson(
        Map<String, dynamic>.from(reviewsBox.get('$target|cet6:1')!),
      );
      expect(winner.mastery, 0.8);
    });

    test('与用户空间已有记录冲突时 LWW（用户较新则用户胜）', () async {
      final target = userOwnerKey('7');
      final older = DateTime.utc(2026, 1, 1);
      final newer = DateTime.utc(2026, 9, 1);

      // 用户空间已有较新记录
      await reviewsBox.put(
        '$target|cet6:1',
        _review('1', 'cet6', clientUpdatedAt: newer, mastery: 0.9).toJson(),
      );
      // guest 空间是较旧的记录
      await reviewsBox.put(
        '$kGuestOwner|cet6:1',
        _review('1', 'cet6', clientUpdatedAt: older, mastery: 0.1).toJson(),
      );

      await service.switchToUser('7');

      final winner = WordReview.fromJson(
        Map<String, dynamic>.from(reviewsBox.get('$target|cet6:1')!),
      );
      expect(winner.mastery, 0.9);
      // guest 条目依然被清走
      expect(reviewsBox.containsKey('$kGuestOwner|cet6:1'), isFalse);
    });
  });

  group('switchToGuest', () {
    test('owner 切回 guest 且用户空间数据保留', () async {
      final target = userOwnerKey('7');
      await service.switchToUser('7');
      await reviewsBox.put('$target|cet6:1', _review('1', 'cet6').toJson());

      await service.switchToGuest();

      expect(service.currentOwner(), kGuestOwner);
      expect(reviewsBox.containsKey('$target|cet6:1'), isTrue);
    });
  });
}

/// 构造指定 wordId / wordBookId 的 WordReview。
WordReview _review(
  String wordId,
  String wordBookId, {
  DateTime? clientUpdatedAt,
  double mastery = 0.5,
}) {
  return WordReview(
    wordId: wordId,
    wordBookId: wordBookId,
    repetitionCount: 1,
    easinessFactor: 2.5,
    interval: 1,
    nextReviewDate: DateTime(2026, 1, 2),
    lastReviewDate: DateTime(2026, 1, 1),
    clientUpdatedAt: clientUpdatedAt,
    learned: false,
    mastery: mastery,
  );
}
