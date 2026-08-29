import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/custom_word_book_model.dart';
import 'package:memora/data/dto/custom_word_record_model.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/custom_word_book_repository.dart';
import 'package:memora/data/repositories/custom_word_repository.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/domain/use_cases/delete_custom_word_book_use_case.dart';
import 'package:memora/features/custom_word_book/controller/custom_word_book_management_controller.dart';

/// CustomWordBookManagementController 单元测试（doc 63 / 13 / 14）。
///
/// 覆盖：
/// 1. load → state.wordBooks
/// 2. create 成功（trim 后存储）/ 空名 / 超长 / 与内置重名 / 自建重名
/// 3. rename 成功（排除自身）/ 校验
/// 4. delete → 级联调用 UseCase（Book + Words + Reviews，doc 61）
/// 5. 内置词库禁止删除 → false + errorMessage（doc 18）
void main() {
  late _FakeCustomWordBookRepository bookRepo;
  late _FakeCustomWordRepository wordRepo;
  late _FakeReviewRepository reviewRepo;
  late DeleteCustomWordBookUseCase deleteUseCase;
  late CustomWordBookManagementController controller;

  setUp(() {
    bookRepo = _FakeCustomWordBookRepository();
    wordRepo = _FakeCustomWordRepository();
    reviewRepo = _FakeReviewRepository();
    deleteUseCase = DeleteCustomWordBookUseCase(bookRepo, wordRepo, reviewRepo);
    controller = CustomWordBookManagementController(bookRepo, deleteUseCase);
  });

  group('load（doc 63）', () {
    test('加载全部自建词库', () async {
      bookRepo.books.add(_book('custom_a', '考研词库'));
      bookRepo.books.add(_book('custom_b', '高频错词'));

      await controller.load();

      expect(controller.state.isLoading, false);
      expect(controller.state.wordBooks.length, 2);
      expect(controller.state.errorMessage, isNull);
    });
  });

  group('create（doc 13 / 14）', () {
    test('成功 → 返回新词库并刷新列表', () async {
      final book = await controller.create(' 考研词库 ');

      expect(book, isNotNull);
      expect(book!.name, '考研词库', reason: '名称 trim 后存储');
      expect(book.id, startsWith('custom_'));
      expect(controller.state.wordBooks, contains(book));
      expect(controller.state.errorMessage, isNull);
    });

    test('空名 → null + errorMessage', () async {
      final book = await controller.create('   ');

      expect(book, isNull);
      expect(controller.state.errorMessage, '词库名称不能为空');
    });

    test('超过 30 字 → null + errorMessage', () async {
      final book = await controller.create('一' * 31);

      expect(book, isNull);
      expect(controller.state.errorMessage, '词库名称不能超过 30 个字符');
    });

    test('与内置词库重名 → null + errorMessage（doc 14）', () async {
      final book = await controller.create('CET-6');

      expect(book, isNull);
      expect(controller.state.errorMessage, '与内置词库名称重复，请换一个名称');
    });

    test('与已有自建词库重名 → null + errorMessage', () async {
      await controller.create('考研词库');

      final book = await controller.create('考研词库');

      expect(book, isNull);
      expect(controller.state.errorMessage, '词库名称已存在');
    });
  });

  group('rename（doc 13 / 79）', () {
    test('成功 → 返回更新后词库，id 不变', () async {
      final created = await controller.create('考研词库');

      final renamed = await controller.rename(created!.id, '高频错词');

      expect(renamed, isNotNull);
      expect(renamed!.id, created.id, reason: '词库 ID 不随重命名变化（doc 5）');
      expect(renamed.name, '高频错词');
    });

    test('重命名为自身当前名称 → 成功（排除自身，doc 13）', () async {
      final created = await controller.create('考研词库');

      final renamed = await controller.rename(created!.id, '考研词库');

      expect(renamed, isNotNull);
      expect(renamed!.name, '考研词库');
    });
  });

  group('delete（doc 61 / 18）', () {
    test('删除自建词库 → 级联删除 Words + Reviews + Book', () async {
      final created = await controller.create('考研词库');

      final ok = await controller.delete(created!.id);

      expect(ok, isTrue);
      expect(wordRepo.deletedBookIds, [created.id]);
      expect(reviewRepo.deletedReviewBookIds, [created.id]);
      expect(bookRepo.deletedIds, [created.id]);
      expect(controller.state.errorMessage, isNull);
    });

    test('内置词库禁止删除 → false + errorMessage（doc 18）', () async {
      final ok = await controller.delete('cet6');

      expect(ok, isFalse);
      expect(controller.state.errorMessage, '删除词库失败');
      expect(wordRepo.deletedBookIds, isEmpty);
      expect(reviewRepo.deletedReviewBookIds, isEmpty);
      expect(bookRepo.deletedIds, isEmpty);
    });
  });
}

/// 构造自建词库测试数据。
CustomWordBook _book(String id, String name) {
  return CustomWordBook(
    id: id,
    name: name,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

/// Fake 词库仓库：内存列表 + 记录删除 ID。
class _FakeCustomWordBookRepository implements CustomWordBookRepository {
  final List<CustomWordBook> books = [];
  final List<String> deletedIds = [];

  @override
  Future<List<CustomWordBook>> getAll() async => List.of(books);

  @override
  Future<CustomWordBook?> getById(String id) async {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<bool> exists(String id) async {
    for (final book in books) {
      if (book.id == id) return true;
    }
    return false;
  }

  @override
  Future<CustomWordBook> create({required String name}) async {
    final book = _book('custom_${books.length + 1}', name);
    books.add(book);
    return book;
  }

  @override
  Future<CustomWordBook> rename({
    required String id,
    required String newName,
  }) async {
    final index = books.indexWhere((b) => b.id == id);
    final renamed = books[index].copyWith(
      name: newName,
      updatedAt: DateTime(2026, 1, 2),
    );
    books[index] = renamed;
    return renamed;
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    books.removeWhere((b) => b.id == id);
  }
}

/// Fake 单词仓库：只记录级联删除的调用。
class _FakeCustomWordRepository implements CustomWordRepository {
  final List<String> deletedBookIds = [];

  @override
  Future<void> deleteByWordBookId(String wordBookId) async {
    deletedBookIds.add(wordBookId);
  }

  @override
  Future<List<CustomWordRecord>> getAll(String wordBookId) async => [];

  @override
  Future<CustomWordRecord?> getById(String wordBookId, String wordId) async =>
      null;

  @override
  Future<CustomWordRecord> create({
    required String wordBookId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    throw UnimplementedError('测试不需要');
  }

  @override
  Future<CustomWordRecord> update({
    required String wordBookId,
    required String wordId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    throw UnimplementedError('测试不需要');
  }

  @override
  Future<void> delete(String wordBookId, String wordId) async {}

  @override
  Future<List<Word>> toWords(String wordBookId) async => [];
}

/// Fake Review 仓库：只记录级联删除的调用。
class _FakeReviewRepository implements ReviewRepository {
  final List<String> deletedReviewBookIds = [];

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {
    deletedReviewBookIds.add(wordBookId);
  }

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async =>
      null;

  @override
  Future<void> saveWordReview(WordReview review) async {}

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async => [];

  @override
  Future<int> getLearnedCount(String wordBookId) async => 0;

  @override
  Future<int> getMasteredCount(String wordBookId) async => 0;

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async => {};

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async => [];

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {}

  @override
  Future<int> getReviewedCount(String wordBookId) async => 0;

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async {}
}
