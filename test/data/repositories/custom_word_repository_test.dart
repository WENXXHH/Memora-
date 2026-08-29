import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/data/dto/custom_word_record_model.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/repositories/custom_word_repository.dart';
import 'package:memora/data/sources/local/custom_word_local_source.dart';

/// CustomWordRepository 真 Hive 持久化测试（doc 84 / 72 / 75）。
///
/// 使用真实 Hive Box（临时目录），覆盖：
/// 1. create → getAll / getById（doc 84）
/// 2. update → id / createdAt 不变，仅内容变化（doc 80）
/// 3. delete 单个 / deleteByWordBookId（级联删词库支持，doc 61）
/// 4. 两个自建词库单词隔离（doc 75）
/// 5. 杀进程持久化：关闭 Box 重新打开后单词仍在（doc 72 第二层）
void main() {
  late Directory tempDir;
  late Box<Map<dynamic, dynamic>> box;
  late CustomWordRepository repository;
  late CustomWordLocalSource localSource;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('custom_word_repo_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map<dynamic, dynamic>>('custom_words');
    await box.clear();
    localSource = CustomWordLocalSource(box);
    repository = CustomWordRepository(localSource);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('CRUD（doc 84）', () {
    test('create → getAll 按创建时间升序返回指定词库单词', () async {
      final w1 = await repository.create(
        wordBookId: 'custom_abc',
        word: 'abandon',
        phonetic: '/əˈbændən/',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const ['Abandon the plan.'],
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final w2 = await repository.create(
        wordBookId: 'custom_abc',
        word: 'ability',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['能力']),
        ],
        example: const [],
      );

      final words = await repository.getAll('custom_abc');

      expect(words.length, 2);
      expect(words[0].id, w1.id);
      expect(words[0].word, 'abandon');
      expect(words[1].id, w2.id);
      expect(words[1].example, isEmpty);
    });

    test('getById → 存在返回记录，不存在返回 null', () async {
      final created = await repository.create(
        wordBookId: 'custom_abc',
        word: 'abandon',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const [],
      );

      final record = await repository.getById('custom_abc', created.id);

      expect(record, isNotNull);
      expect(record!.word, 'abandon');
      expect(await repository.getById('custom_abc', 'missing'), isNull);
    });

    test('update → id / createdAt 不变，仅内容与 updatedAt 变化（doc 80）', () async {
      final created = await repository.create(
        wordBookId: 'custom_abc',
        word: 'abandonn',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const [],
      );

      final updated = await repository.update(
        wordBookId: 'custom_abc',
        wordId: created.id,
        word: 'abandon',
        phonetic: '/əˈbændən/',
        meaning: const [
          MeaningEntry(pos: 'v.', definitions: ['抛弃', '放弃']),
        ],
        example: const ['A new example.'],
      );

      expect(updated.id, created.id, reason: '单词 ID 编辑后保持不变（doc 19）');
      expect(updated.createdAt, created.createdAt);
      expect(updated.word, 'abandon');
      expect(updated.meaning.first.definitions, ['抛弃', '放弃']);
      expect(updated.updatedAt.isAfter(created.updatedAt), isTrue);
    });

    test('delete 单个单词', () async {
      final created = await repository.create(
        wordBookId: 'custom_abc',
        word: 'abandon',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const [],
      );

      await repository.delete('custom_abc', created.id);

      expect(await repository.getAll('custom_abc'), isEmpty);
      expect(await repository.getById('custom_abc', created.id), isNull);
    });

    test('deleteByWordBookId 只删本词库单词（doc 61）', () async {
      await repository.create(
        wordBookId: 'custom_a',
        word: 'abandon',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const [],
      );
      await repository.create(
        wordBookId: 'custom_b',
        word: 'ability',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['能力']),
        ],
        example: const [],
      );

      await repository.deleteByWordBookId('custom_a');

      expect(await repository.getAll('custom_a'), isEmpty);
      expect((await repository.getAll('custom_b')).single.word, 'ability');
    });
  });

  group('两个自建词库单词隔离（doc 75）', () {
    test('custom_a:1 与 custom_b:1 联合 Key 独立', () async {
      // 人工构造相同 wordId，验证联合 Key `$wordBookId:$wordId` 隔离
      await localSource.save(_record('1', 'custom_a', 'abandon'));
      await localSource.save(_record('1', 'custom_b', 'ability'));

      final a = await repository.getById('custom_a', '1');
      final b = await repository.getById('custom_b', '1');

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a!.word, 'abandon');
      expect(b!.word, 'ability');
    });

    test('getAll 不会把其他词库的单词混进来', () async {
      await localSource.save(_record('1', 'custom_a', 'abandon'));
      await localSource.save(_record('2', 'custom_a', 'bold'));
      await localSource.save(_record('1', 'custom_b', 'ability'));

      final a = await repository.getAll('custom_a');

      expect(a.length, 2);
      expect(a.map((w) => w.word), containsAll(['abandon', 'bold']));
      expect(a.map((w) => w.word), isNot(contains('ability')));
    });
  });

  group('杀进程持久化（doc 72 第二层）', () {
    test('新增单词 → 关闭 Box → 重新打开 → 仍存在', () async {
      await repository.create(
        wordBookId: 'custom_abc',
        word: 'abandon',
        phonetic: '',
        meaning: const [
          MeaningEntry(pos: '', definitions: ['放弃']),
        ],
        example: const [],
      );
      await box.close();

      // 模拟杀进程重启：同目录同名称重新打开，读取磁盘数据
      box = await Hive.openBox<Map<dynamic, dynamic>>('custom_words');
      repository = CustomWordRepository(CustomWordLocalSource(box));

      final words = await repository.getAll('custom_abc');
      expect(words.single.word, 'abandon');
    });
  });
}

/// 构造指定 id / wordBookId 的测试记录（用于固定联合 Key 的隔离场景）。
CustomWordRecord _record(String id, String wordBookId, String word) {
  return CustomWordRecord(
    id: id,
    wordBookId: wordBookId,
    word: word,
    phonetic: '',
    meaning: const [
      MeaningEntry(pos: '', definitions: ['测试']),
    ],
    example: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}
