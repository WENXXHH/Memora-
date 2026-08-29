import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/built_in_word_books.dart';
import 'package:memora/data/dto/custom_word_book_model.dart';
import 'package:memora/data/repositories/custom_word_book_repository.dart';
import 'package:memora/domain/services/word_book_registry.dart';
import 'package:memora/domain/services/word_book_summary.dart';

/// WordBookRegistry 单元测试（doc 31 / 32 / 67）。
///
/// 覆盖：
/// 1. getAll 组合内置（在前）+ 自建，kind 正确
/// 2. findById 内置 / 自建 / 未知
/// 3. exists 内置 / 自建 / 未知
void main() {
  late _FakeCustomWordBookRepository customRepo;
  late WordBookRegistry registry;

  setUp(() {
    customRepo = _FakeCustomWordBookRepository();
    registry = WordBookRegistry(customRepo);
  });

  group('getAll（doc 32 / 37）', () {
    test('内置在前 + 自建在后，kind 正确', () async {
      customRepo.books.add(_book('custom_abc', '考研重点'));
      customRepo.books.add(_book('custom_xyz', '高频错词'));

      final all = await registry.getAll();

      expect(all.length, 4);
      expect(all[0].id, 'cet6');
      expect(all[0].kind, WordBookKind.builtIn);
      expect(all[1].id, 'cet4');
      expect(all[1].kind, WordBookKind.builtIn);
      expect(all[2].id, 'custom_abc');
      expect(all[2].name, '考研重点');
      expect(all[2].kind, WordBookKind.custom);
      expect(all[3].id, 'custom_xyz');
      expect(all[3].kind, WordBookKind.custom);
    });

    test('无自建词库时只返回内置', () async {
      final all = await registry.getAll();
      expect(all.length, BuiltInWordBooks.all.length);
      expect(all.every((b) => b.kind == WordBookKind.builtIn), isTrue);
    });
  });

  group('findById（doc 32）', () {
    test('内置词库 → builtIn Summary', () async {
      final book = await registry.findById('cet4');
      expect(book, isNotNull);
      expect(book!.name, 'CET-4');
      expect(book.kind, WordBookKind.builtIn);
    });

    test('自建词库 → custom Summary', () async {
      customRepo.books.add(_book('custom_abc', '考研重点'));
      final book = await registry.findById('custom_abc');
      expect(book, isNotNull);
      expect(book!.name, '考研重点');
      expect(book.kind, WordBookKind.custom);
    });

    test('未知 ID → null（不 fallback）', () async {
      expect(await registry.findById('unknown'), isNull);
    });
  });

  group('exists（doc 33 / 67）', () {
    test('内置词库存在', () async {
      expect(await registry.exists('cet6'), isTrue);
      expect(await registry.exists('cet4'), isTrue);
    });

    test('已注册自建词库存在', () async {
      customRepo.books.add(_book('custom_abc', '考研重点'));
      expect(await registry.exists('custom_abc'), isTrue);
    });

    test('未注册 / 未知词库不存在', () async {
      expect(await registry.exists('toefl'), isFalse);
      expect(await registry.exists('custom_deleted'), isFalse);
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

/// Fake CustomWordBookRepository：内存列表。
class _FakeCustomWordBookRepository implements CustomWordBookRepository {
  final List<CustomWordBook> books = [];

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
  Future<CustomWordBook> create({required String name}) {
    throw UnimplementedError('测试不需要');
  }

  @override
  Future<CustomWordBook> rename({
    required String id,
    required String newName,
  }) {
    throw UnimplementedError('测试不需要');
  }

  @override
  Future<void> delete(String id) async {}
}
