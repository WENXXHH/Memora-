import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/features/home/controller/home_controller.dart';

/// 首页统计按词库隔离测试（doc 40 / 49 / 62 首页）。
///
/// 核心断言：CET-6 与 CET-4 的待复习数 / 单词数 / 已学数 / 掌握数
/// 各自独立，加载一个词库不影响另一个词库的状态。
void main() {
  group('首页统计按词库隔离（doc 40）', () {
    test('CET-6 与 CET-4 统计各自独立', () async {
      final wordRepo = _FakeWordRepository({'cet6': 100, 'cet4': 50});
      final reviewRepo = _FakeReviewRepository()
        ..setDueCount('cet6', 8)
        ..setDueCount('cet4', 2)
        ..setReviewedCount('cet6', 30)
        ..setReviewedCount('cet4', 10)
        ..setMasteredCount('cet6', 5)
        ..setMasteredCount('cet4', 1);

      final cet6 = HomeController('cet6', wordRepo, reviewRepo);
      final cet4 = HomeController('cet4', wordRepo, reviewRepo);

      await cet6.loadData();
      expect(cet6.state.reviewCount, 8, reason: 'CET-6 待复习数');
      expect(cet6.state.totalWords, 100, reason: 'CET-6 单词数');
      expect(cet6.state.learnedCount, 30, reason: 'CET-6 已学数');
      expect(cet6.state.masteredWords, 5, reason: 'CET-6 掌握数');
      expect(cet6.state.isLoading, isFalse);

      await cet4.loadData();
      expect(cet4.state.reviewCount, 2, reason: 'CET-4 待复习数（doc 40：8→2）');
      expect(cet4.state.totalWords, 50);
      expect(cet4.state.learnedCount, 10);
      expect(cet4.state.masteredWords, 1);
      expect(cet4.state.isLoading, isFalse);

      // 加载 CET-4 不改变 CET-6 的统计（隔离）
      expect(cet6.state.reviewCount, 8, reason: 'CET-6 状态不受 CET-4 加载影响');
      expect(cet6.state.masteredWords, 5);
    });

    test('加载失败 → hasError，isLoading 复位', () async {
      final wordRepo = _FakeWordRepository({'cet6': 100});
      final reviewRepo = _ThrowingReviewRepository();
      final controller = HomeController('cet6', wordRepo, reviewRepo);

      await controller.loadData();
      expect(controller.state.hasError, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNotNull);
    });
  });
}

/// Fake WordRepository：按词库返回单词数。
class _FakeWordRepository implements WordRepository {
  _FakeWordRepository(this._counts);

  final Map<String, int> _counts;

  @override
  Future<int> getWordCount(String wordBookId) async => _counts[wordBookId] ?? 0;

  @override
  Future<List<Word>> getWords(String wordBookId) async => [];

  @override
  Future<Word?> getWordById(String wordBookId, String wordId) async => null;

  @override
  void clearCache() {}
}

/// Fake ReviewRepository：按词库返回首页统计数量。
class _FakeReviewRepository implements ReviewRepository {
  final Map<String, int> _dueCount = {};
  final Map<String, int> _reviewedCount = {};
  final Map<String, int> _masteredCount = {};

  _FakeReviewRepository setDueCount(String book, int n) {
    _dueCount[book] = n;
    return this;
  }

  _FakeReviewRepository setReviewedCount(String book, int n) {
    _reviewedCount[book] = n;
    return this;
  }

  _FakeReviewRepository setMasteredCount(String book, int n) {
    _masteredCount[book] = n;
    return this;
  }

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async {
    final n = _dueCount[wordBookId] ?? 0;
    return List.generate(
      n,
      (i) => WordReview(
        wordId: 'w$i',
        wordBookId: wordBookId,
        repetitionCount: 0,
        easinessFactor: 2.5,
        interval: 0,
        nextReviewDate: DateTime.now(),
        lastReviewDate: null,
        learned: false,
        mastery: 0.0,
      ),
    );
  }

  @override
  Future<int> getReviewedCount(String wordBookId) async =>
      _reviewedCount[wordBookId] ?? 0;

  @override
  Future<int> getMasteredCount(String wordBookId) async =>
      _masteredCount[wordBookId] ?? 0;

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async =>
      null;

  @override
  Future<void> saveWordReview(WordReview review) async {}

  @override
  Future<int> getLearnedCount(String wordBookId) async => 0;

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async => {};

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async => [];

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {}

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {}

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async {}
}

/// 模拟加载失败的 ReviewRepository（doc 44 降级路径）。
class _ThrowingReviewRepository implements ReviewRepository {
  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async =>
      throw Exception('simulated failure');

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<void> saveWordReview(WordReview review) async =>
      throw UnimplementedError();

  @override
  Future<int> getLearnedCount(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<int> getMasteredCount(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async =>
      throw UnimplementedError();

  @override
  Future<int> getReviewedCount(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async =>
      throw UnimplementedError();
}
