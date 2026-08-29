import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/custom_word_book_model.dart';
import 'package:memora/data/dto/custom_word_record_model.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/custom_word_book_repository.dart';
import 'package:memora/data/repositories/custom_word_repository.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/domain/use_cases/delete_custom_word_book_use_case.dart';

/// DeleteCustomWordBookUseCase 级联删除测试（doc 60 / 61 / 18）。
///
/// 覆盖：
/// 1. 删除词库 → 依次删除其全部单词、全部 Review、词库元数据（doc 61）
/// 2. 内置词库禁止删除（doc 18）
void main() {
  late _FakeCustomWordBookRepository bookRepo;
  late _FakeCustomWordRepository wordRepo;
  late _FakeReviewRepository reviewRepo;
  late DeleteCustomWordBookUseCase useCase;

  setUp(() {
    bookRepo = _FakeCustomWordBookRepository();
    wordRepo = _FakeCustomWordRepository();
    reviewRepo = _FakeReviewRepository();
    useCase = DeleteCustomWordBookUseCase(bookRepo, wordRepo, reviewRepo);
  });

  group('删 Book → Words + Reviews（doc 61）', () {
    test('依次删除单词 → Review → 词库元数据', () async {
      await useCase.execute('custom_abc');

      expect(wordRepo.deletedBookIds, ['custom_abc']);
      expect(reviewRepo.deletedReviewBookIds, ['custom_abc']);
      expect(bookRepo.deletedIds, ['custom_abc']);
    });

    test('非当前词库不影响当前选择（doc 36）：只删数据不动选择', () async {
      await useCase.execute('custom_xyz');

      expect(wordRepo.deletedBookIds, ['custom_xyz']);
      expect(reviewRepo.deletedReviewBookIds, ['custom_xyz']);
      expect(bookRepo.deletedIds, ['custom_xyz']);
    });

    test('内置词库禁止删除（doc 18）', () async {
      await expectLater(useCase.execute('cet6'), throwsA(isA<ArgumentError>()));
      expect(wordRepo.deletedBookIds, isEmpty);
      expect(reviewRepo.deletedReviewBookIds, isEmpty);
      expect(bookRepo.deletedIds, isEmpty);
    });
  });
}

/// Fake 词库仓库：记录被删除的 ID。
class _FakeCustomWordBookRepository implements CustomWordBookRepository {
  final List<String> deletedIds = [];

  @override
  Future<void> delete(String id) async => deletedIds.add(id);

  @override
  Future<bool> exists(String id) async => false;

  @override
  Future<List<CustomWordBook>> getAll() async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordBook?> getById(String id) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordBook> create({required String name}) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordBook> rename({
    required String id,
    required String newName,
  }) async => throw UnimplementedError('测试不需要');
}

/// Fake 单词仓库：记录按词库批量删除的 ID。
class _FakeCustomWordRepository implements CustomWordRepository {
  final List<String> deletedBookIds = [];

  @override
  Future<void> deleteByWordBookId(String wordBookId) async =>
      deletedBookIds.add(wordBookId);

  @override
  Future<List<CustomWordRecord>> getAll(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordRecord?> getById(String wordBookId, String wordId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordRecord> create({
    required String wordBookId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async => throw UnimplementedError('测试不需要');

  @override
  Future<CustomWordRecord> update({
    required String wordBookId,
    required String wordId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async => throw UnimplementedError('测试不需要');

  @override
  Future<void> delete(String wordBookId, String wordId) async {}

  @override
  Future<List<Word>> toWords(String wordBookId) async =>
      throw UnimplementedError('测试不需要');
}

/// Fake Review 仓库：记录按词库批量删除的 ID。
class _FakeReviewRepository implements ReviewRepository {
  final List<String> deletedReviewBookIds = [];

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async =>
      deletedReviewBookIds.add(wordBookId);

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<void> saveWordReview(WordReview review) async {}

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<int> getLearnedCount(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<int> getMasteredCount(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {}

  @override
  Future<int> getReviewedCount(String wordBookId) async =>
      throw UnimplementedError('测试不需要');

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async {}
}
