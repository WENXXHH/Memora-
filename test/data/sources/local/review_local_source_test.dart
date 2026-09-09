import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/core/storage/data_owner.dart';
import 'package:memora/domain/models/word_review_model.dart';
import 'package:memora/data/sources/local/review_local_source.dart';

/// ReviewLocalDataSource 真 Hive 持久化与隔离测试。
///
/// 使用真实 Hive reviews/auth Box（临时目录），覆盖：
/// 1. 相同 wordId 跨词库隔离：cet6:1 与 custom_abc:1 独立演进
/// 2. 两个自建词库隔离：custom_a:1 与 custom_b:1 独立演进
/// 3. deleteReviewsByWordBookId 只删本词库
/// 4. 杀进程持久化：Review 重启后仍在
/// 5. owner 命名空间隔离：guest 与 user 空间互不可见
void main() {
  late Directory tempDir;
  late Box<Map<dynamic, dynamic>> box;
  late Box<String> authBox;
  late ReviewLocalDataSource source;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('review_local_source_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map<dynamic, dynamic>>('reviews');
    authBox = await Hive.openBox<String>('auth');
    await box.clear();
    await authBox.clear();
    source = ReviewLocalDataSource(box, authBox);
  });

  tearDown(() async {
    await box.close();
    await authBox.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('内置 vs 自建 Review 隔离', () {
    test('cet6:1 与 custom_abc:1 是两条独立记录，互不影响', () async {
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.9));
      await source.saveWordReview(_review('1', 'custom_abc', mastery: 0.1));

      final cet6 = source.getWordReview('cet6', '1');
      final custom = source.getWordReview('custom_abc', '1');

      expect(cet6, isNotNull);
      expect(custom, isNotNull);
      expect(cet6!.mastery, 0.9);
      expect(custom!.mastery, 0.1);

      // 更新自建记录不影响内置记录
      await source.saveWordReview(_review('1', 'custom_abc', mastery: 0.2));
      expect(source.getWordReview('cet6', '1')!.mastery, 0.9);
    });
  });

  group('两个自建词库 Review 隔离', () {
    test('custom_a:1 与 custom_b:1 独立演进', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('1', 'custom_b', mastery: 0.3));

      expect(source.getWordReview('custom_a', '1')!.mastery, 0.8);
      expect(source.getWordReview('custom_b', '1')!.mastery, 0.3);

      // 更新 custom_b 不影响 custom_a
      await source.saveWordReview(_review('1', 'custom_b', mastery: 0.9));
      expect(source.getWordReview('custom_a', '1')!.mastery, 0.8);
    });

    test('getAllReviews / getAllReviewIds 按词库过滤', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('2', 'custom_a', mastery: 0.4));
      await source.saveWordReview(_review('1', 'custom_b', mastery: 0.6));

      final a = source.getAllReviews('custom_a');
      expect(a.length, 2);
      expect(source.getAllReviewIds('custom_a'), {'1', '2'});
      expect(source.getAllReviews('custom_b').length, 1);
    });
  });

  group('级联删除支持', () {
    test('deleteReviewsByWordBookId 只删本词库 Review', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('1', 'custom_b', mastery: 0.6));

      await source.deleteReviewsByWordBookId('custom_a');

      expect(source.getWordReview('custom_a', '1'), isNull);
      expect(source.getWordReview('custom_b', '1'), isNotNull);
    });

    test('deleteReview 只删单个单词的 Review', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('2', 'custom_a', mastery: 0.4));

      await source.deleteReview('custom_a', '1');

      expect(source.getWordReview('custom_a', '1'), isNull);
      expect(source.getWordReview('custom_a', '2'), isNotNull);
    });
  });

  group('杀进程持久化', () {
    test('Review 关闭 Box 重新打开后仍在', () async {
      await source.saveWordReview(_review('1', 'custom_abc', mastery: 0.8));
      await box.close();
      await authBox.close();

      // 模拟杀进程重启：同目录同名称重新打开 reviews Box
      box = await Hive.openBox<Map<dynamic, dynamic>>('reviews');
      authBox = await Hive.openBox<String>('auth');
      source = ReviewLocalDataSource(box, authBox);

      final review = source.getWordReview('custom_abc', '1');
      expect(review, isNotNull);
      expect(review!.mastery, 0.8);
      expect(review.wordBookId, 'custom_abc');
    });
  });

  group('owner 命名空间隔离', () {
    test('未设置 owner 时写入 guest 空间，key 带 guest 前缀', () async {
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.5));

      expect(box.keys, contains('$kGuestOwner|cet6:1'));
      expect(source.getWordReview('cet6', '1'), isNotNull);
    });

    test('切换 owner 后读不到其它空间的数据', () async {
      // guest 空间写入
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.5));

      // 切到 user:1 空间：读不到 guest 数据
      await authBox.put(kDataOwnerKey, userOwnerKey('1'));
      expect(source.getWordReview('cet6', '1'), isNull);
      expect(source.getAllReviews('cet6'), isEmpty);

      // user:1 空间写入自己的数据，互不覆盖
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.9));
      expect(source.getWordReview('cet6', '1')!.mastery, 0.9);
      expect(box.keys, contains('${userOwnerKey('1')}|cet6:1'));

      // 切回 guest：guest 数据原样还在
      await authBox.put(kDataOwnerKey, kGuestOwner);
      expect(source.getWordReview('cet6', '1')!.mastery, 0.5);
    });

    test('deleteReviewsByWordBookId 只删当前 owner 空间', () async {
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.5));

      await authBox.put(kDataOwnerKey, userOwnerKey('2'));
      await source.saveWordReview(_review('1', 'cet6', mastery: 0.8));
      await source.deleteReviewsByWordBookId('cet6');

      // user:2 空间被清空，guest 空间不受影响
      expect(source.getAllReviews('cet6'), isEmpty);
      await authBox.put(kDataOwnerKey, kGuestOwner);
      expect(source.getWordReview('cet6', '1'), isNotNull);
    });
  });

  group('getRecentLearned 巩固练习队列', () {
    WordReview rec(
      String id, {
      required DateTime nextReview,
      DateTime? lastReview,
    }) {
      return WordReview(
        wordId: id,
        wordBookId: 'cet6',
        repetitionCount: lastReview == null ? 0 : 2,
        easinessFactor: 2.5,
        interval: 10,
        nextReviewDate: nextReview,
        lastReviewDate: lastReview,
        learned: lastReview != null,
        mastery: 0.5,
      );
    }

    test('只含已学且未到期的记录，排除到期词与未学词', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 到期词（今天该复习）→ 排除
      await source.saveWordReview(
        rec('due',
            nextReview: today,
            lastReview: today.subtract(const Duration(days: 3))),
      );
      // 未学词（lastReviewDate 为 null）→ 排除
      await source.saveWordReview(rec('fresh', nextReview: today));
      // 已学未到期 → 保留
      await source.saveWordReview(
        rec('learned',
            nextReview: today.add(const Duration(days: 5)),
            lastReview: today.subtract(const Duration(days: 1))),
      );

      final recent = source.getRecentLearned('cet6');
      expect(recent.map((r) => r.wordId), ['learned']);
    });

    test('按上次复习时间倒序（最近复习优先）', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await source.saveWordReview(
        rec('old',
            nextReview: today.add(const Duration(days: 9)),
            lastReview: today.subtract(const Duration(days: 5))),
      );
      await source.saveWordReview(
        rec('mid',
            nextReview: today.add(const Duration(days: 8)),
            lastReview: today.subtract(const Duration(days: 2))),
      );
      await source.saveWordReview(
        rec('newest',
            nextReview: today.add(const Duration(days: 7)),
            lastReview: today.subtract(const Duration(days: 1))),
      );

      final recent = source.getRecentLearned('cet6');
      expect(recent.map((r) => r.wordId), ['newest', 'mid', 'old']);
    });

    test('只读当前 owner 空间', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await source.saveWordReview(
        rec('g',
            nextReview: today.add(const Duration(days: 5)),
            lastReview: today.subtract(const Duration(days: 1))),
      );

      await authBox.put(kDataOwnerKey, userOwnerKey('9'));
      expect(source.getRecentLearned('cet6'), isEmpty);
    });
  });
}

/// 构造指定 wordId / wordBookId / mastery 的 WordReview。
WordReview _review(
  String wordId,
  String wordBookId, {
  required double mastery,
}) {
  return WordReview(
    wordId: wordId,
    wordBookId: wordBookId,
    repetitionCount: 1,
    easinessFactor: 2.5,
    interval: 1,
    nextReviewDate: DateTime(2026, 1, 2),
    lastReviewDate: DateTime(2026, 1, 1),
    learned: false,
    mastery: mastery,
  );
}
