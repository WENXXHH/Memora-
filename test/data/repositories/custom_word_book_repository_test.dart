import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/data/repositories/custom_word_book_repository.dart';
import 'package:memora/data/sources/local/custom_word_book_local_source.dart';

/// CustomWordBookRepository 真 Hive 持久化测试（doc 84 / 72）。
///
/// 使用真实 Hive Box（临时目录），覆盖：
/// 1. create → getAll / getById / exists（doc 84）
/// 2. rename → id 不变，仅 name / updatedAt 变化（doc 5 / 79）
/// 3. delete（doc 84）
/// 4. 杀进程持久化：关闭 Box 重新打开后词库仍在（doc 72 第一层）
void main() {
  late Directory tempDir;
  late Box<Map<dynamic, dynamic>> box;
  late CustomWordBookRepository repository;

  setUpAll(() async {
    // Hive 引擎每个进程只初始化一次，指向临时目录避免污染真实数据。
    tempDir = await Directory.systemTemp.createTemp(
      'custom_word_book_repo_test',
    );
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map<dynamic, dynamic>>('custom_word_books');
    await box.clear();
    repository = CustomWordBookRepository(CustomWordBookLocalSource(box));
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('CRUD（doc 84）', () {
    test('create → getAll 按创建时间升序，ID 为 custom_<uuid>（doc 5）', () async {
      final b1 = await repository.create(name: '考研词库');
      // 间隔保证 createdAt 严格递增，验证展示顺序稳定
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final b2 = await repository.create(name: '高频错词');

      final all = await repository.getAll();

      expect(all.length, 2);
      expect(all[0].id, b1.id);
      expect(all[0].name, '考研词库');
      expect(all[1].id, b2.id);
      expect(all[1].name, '高频错词');
      expect(all[0].id, startsWith('custom_'));
    });

    test('getById / exists', () async {
      final book = await repository.create(name: '考研词库');

      expect((await repository.getById(book.id))?.name, '考研词库');
      expect(await repository.exists(book.id), isTrue);
      expect(await repository.getById('custom_missing'), isNull);
      expect(await repository.exists('custom_missing'), isFalse);
    });

    test('rename → id / createdAt 不变，仅 name / updatedAt 变化（doc 79）', () async {
      final book = await repository.create(name: 'A');

      final renamed = await repository.rename(id: book.id, newName: 'B');

      expect(renamed.id, book.id, reason: '词库 ID 不随重命名变化（doc 5）');
      expect(renamed.createdAt, book.createdAt);
      expect(renamed.name, 'B');
      expect(renamed.updatedAt.isAfter(book.updatedAt), isTrue);
    });

    test('delete → 词库不存在且列表为空', () async {
      final book = await repository.create(name: '考研词库');

      await repository.delete(book.id);

      expect(await repository.exists(book.id), isFalse);
      expect(await repository.getAll(), isEmpty);
    });
  });

  group('杀进程持久化（doc 72 第一层）', () {
    test('创建词库 → 关闭 Box → 重新打开 → 仍存在', () async {
      await repository.create(name: '考研词库');
      await box.close();

      // 模拟杀进程重启：同目录同名称重新打开，读取磁盘数据
      box = await Hive.openBox<Map<dynamic, dynamic>>('custom_word_books');
      repository = CustomWordBookRepository(CustomWordBookLocalSource(box));

      final all = await repository.getAll();
      expect(all.single.name, '考研词库');
    });
  });
}
