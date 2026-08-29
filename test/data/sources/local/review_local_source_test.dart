import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/sources/local/review_local_source.dart';

/// ReviewLocalDataSource 真 Hive 持久化与隔离测试（doc 74 / 75 / 72）。
///
/// 使用真实 Hive reviews Box（临时目录），覆盖：
/// 1. 相同 wordId 跨词库隔离：cet6:1 与 custom_abc:1 独立演进（doc 74）
/// 2. 两个自建词库隔离：custom_a:1 与 custom_b:1 独立演进（doc 75）
/// 3. deleteReviewsByWordBookId 只删本词库（doc 61）
/// 4. 杀进程持久化：Review 重启后仍在（doc 73）
void main() {
  late Directory tempDir;
  late Box<Map<dynamic, dynamic>> box;
  late ReviewLocalDataSource source;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('review_local_source_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map<dynamic, dynamic>>('reviews');
    await box.clear();
    source = ReviewLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('内置 vs 自建 Review 隔离（doc 74）', () {
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

  group('两个自建词库 Review 隔离（doc 75）', () {
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

  group('级联删除支持（doc 61）', () {
    test('deleteReviewsByWordBookId 只删本词库 Review', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('1', 'custom_b', mastery: 0.6));

      await source.deleteReviewsByWordBookId('custom_a');

      expect(source.getWordReview('custom_a', '1'), isNull);
      expect(source.getWordReview('custom_b', '1'), isNotNull);
    });

    test('deleteReview 只删单个单词的 Review（doc 23）', () async {
      await source.saveWordReview(_review('1', 'custom_a', mastery: 0.8));
      await source.saveWordReview(_review('2', 'custom_a', mastery: 0.4));

      await source.deleteReview('custom_a', '1');

      expect(source.getWordReview('custom_a', '1'), isNull);
      expect(source.getWordReview('custom_a', '2'), isNotNull);
    });
  });

  group('杀进程持久化（doc 73）', () {
    test('Review 关闭 Box 重新打开后仍在', () async {
      await source.saveWordReview(_review('1', 'custom_abc', mastery: 0.8));
      await box.close();

      // 模拟杀进程重启：同目录同名称重新打开 reviews Box
      box = await Hive.openBox<Map<dynamic, dynamic>>('reviews');
      source = ReviewLocalDataSource(box);

      final review = source.getWordReview('custom_abc', '1');
      expect(review, isNotNull);
      expect(review!.mastery, 0.8);
      expect(review.wordBookId, 'custom_abc');
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
