import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/custom_word_book_model.dart';
import 'package:memora/data/dto/custom_word_record_model.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/repositories/custom_word_book_repository.dart';
import 'package:memora/data/repositories/custom_word_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/data/sources/word_data_source.dart';

/// WordRepository 多词库缓存隔离 + 内置/自建路由测试（doc 34 / 35 / 36 / 37 / 46 / 49）。
///
/// 覆盖：
/// 1. 数据隔离：cet6 / cet4 各自独立，wordBookId 全程正确
/// 2. 缓存隔离：先读 cet6 再读 cet4 再读 cet6，不会串库（Bug 2 防御），
///    每个内置词库只向 DataSource 请求一次
/// 3. 相同 wordId 跨词库不冲突（cet6:1 != cet4:1）
/// 4. 未知 wordBookId 明确失败（doc 30 / 46）
/// 5. 自建词库路由：getWords / getWordById 走 Hive，不缓存（doc 46 / 48 / 49）
void main() {
  Word makeWord({
    required String id,
    required String word,
    required String wordBookId,
  }) {
    return Word(
      id: id,
      word: word,
      phonetic: '/test/',
      meaning: const [
        MeaningEntry(pos: 'n.', definitions: ['测试']),
      ],
      example: const ['Test sentence.'],
      audio: '',
      wordBookId: wordBookId,
    );
  }

  group('数据隔离（doc 34）', () {
    test('cet6 与 cet4 各自独立且 wordBookId 正确', () async {
      final fake = FakeWordDataSource({
        'cet6': [
          makeWord(id: '1', word: 'abandon', wordBookId: 'cet6'),
          makeWord(id: '2', word: 'ability', wordBookId: 'cet6'),
        ],
        'cet4': [
          makeWord(id: '1', word: 'abandon', wordBookId: 'cet4'),
          makeWord(id: '3', word: 'abroad', wordBookId: 'cet4'),
        ],
      });
      final repository = buildRepository(fake);

      final cet6Words = await repository.getWords('cet6');
      final cet4Words = await repository.getWords('cet4');

      expect(cet6Words, isNot(equals(cet4Words)));
      expect(cet6Words.every((w) => w.wordBookId == 'cet6'), isTrue);
      expect(cet4Words.every((w) => w.wordBookId == 'cet4'), isTrue);
    });
  });

  group('缓存隔离（doc 35 / Bug 2 防御）', () {
    test('先 cet6 再 cet4 再 cet6，不串库', () async {
      final fake = FakeWordDataSource({
        'cet6': [makeWord(id: '1', word: 'cet6-word', wordBookId: 'cet6')],
        'cet4': [makeWord(id: '1', word: 'cet4-word', wordBookId: 'cet4')],
      });
      final repository = buildRepository(fake);

      final firstCet6 = await repository.getWords('cet6');
      final cet4 = await repository.getWords('cet4');
      final secondCet6 = await repository.getWords('cet6');

      expect(secondCet6, equals(firstCet6));
      expect(secondCet6.single.word, 'cet6-word');
      expect(cet4.single.word, 'cet4-word');
    });

    test('每个词库只向 DataSource 请求一次（缓存命中）', () async {
      final fake = FakeWordDataSource({
        'cet6': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet6')],
        'cet4': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet4')],
      });
      final repository = buildRepository(fake);

      await repository.getWords('cet6');
      await repository.getWords('cet6');
      await repository.getWords('cet4');
      await repository.getWords('cet4');

      expect(fake.callCounts['cet6'], 1);
      expect(fake.callCounts['cet4'], 1);
    });

    test('clearCache 后重新向 DataSource 请求', () async {
      final fake = FakeWordDataSource({
        'cet6': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet6')],
      });
      final repository = buildRepository(fake);

      await repository.getWords('cet6');
      repository.clearCache();
      await repository.getWords('cet6');

      expect(fake.callCounts['cet6'], 2);
    });
  });

  group('相同 wordId 跨词库不冲突（doc 36）', () {
    test('cet6:1 与 cet4:1 是两条不同记录', () async {
      final fake = FakeWordDataSource({
        'cet6': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet6')],
        'cet4': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet4')],
      });
      final repository = buildRepository(fake);

      final cet6Word = await repository.getWordById('cet6', '1');
      final cet4Word = await repository.getWordById('cet4', '1');

      expect(cet6Word, isNotNull);
      expect(cet4Word, isNotNull);
      expect(cet6Word!.wordBookId, 'cet6');
      expect(cet4Word!.wordBookId, 'cet4');
      expect(cet6Word, isNot(equals(cet4Word)));
    });
  });

  group('自建词库路由（doc 46 / 48 / 49）', () {
    test('getWords(custom_abc) → 走自建仓库并转 Word', () async {
      final customWords = {
        'custom_abc': [
          makeCustomWord(id: 'w1', word: 'abandon', wordBookId: 'custom_abc'),
          makeCustomWord(id: 'w2', word: 'ability', wordBookId: 'custom_abc'),
        ],
      };
      final repository = buildRepository(
        FakeWordDataSource({}),
        customBookIds: ['custom_abc'],
        customWords: customWords,
      );

      final words = await repository.getWords('custom_abc');

      expect(words.length, 2);
      expect(words.every((w) => w.wordBookId == 'custom_abc'), isTrue);
      expect(words.first.word, 'abandon');
      expect(words.first.audio, '', reason: '自建单词无音频资源');
    });

    test('自建词库不缓存：每次调用都重新读 Hive（doc 49）', () async {
      final customWordRepo = _FakeCustomWordRepository({
        'custom_abc': [
          makeCustomWord(id: 'w1', word: 'abandon', wordBookId: 'custom_abc'),
        ],
      });
      final repository = WordRepository(
        FakeWordDataSource({}),
        _FakeCustomWordBookRepository(['custom_abc']),
        customWordRepo,
      );

      await repository.getWords('custom_abc');
      await repository.getWords('custom_abc');

      expect(customWordRepo.toWordsCallCount, 2);
    });

    test('getWordById(custom_abc, w1) → 返回自建 Word', () async {
      final customWords = {
        'custom_abc': [
          makeCustomWord(id: 'w1', word: 'abandon', wordBookId: 'custom_abc'),
        ],
      };
      final repository = buildRepository(
        FakeWordDataSource({}),
        customBookIds: ['custom_abc'],
        customWords: customWords,
      );

      final word = await repository.getWordById('custom_abc', 'w1');

      expect(word, isNotNull);
      expect(word!.wordBookId, 'custom_abc');
      expect(word.word, 'abandon');
    });

    test('自建词库中不存在的 wordId → null', () async {
      final repository = buildRepository(
        FakeWordDataSource({}),
        customBookIds: ['custom_abc'],
        customWords: const {},
      );

      expect(await repository.getWordById('custom_abc', 'missing'), isNull);
    });
  });

  group('未知 wordBookId（doc 37 / 30）', () {
    test('内置不含且自建不存在 → 明确失败，不返回 CET-6', () async {
      final repository = buildRepository(FakeWordDataSource({}));

      await expectLater(
        repository.getWords('unknown'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('未知词库'),
          ),
        ),
      );
    });
  });
}

/// 组装带自建路由能力的 WordRepository。
WordRepository buildRepository(
  FakeWordDataSource dataSource, {
  List<String> customBookIds = const [],
  Map<String, List<CustomWordRecord>> customWords = const {},
}) {
  return WordRepository(
    dataSource,
    _FakeCustomWordBookRepository(customBookIds),
    _FakeCustomWordRepository(customWords),
  );
}

/// 构造自建单词记录。
CustomWordRecord makeCustomWord({
  required String id,
  required String word,
  required String wordBookId,
}) {
  return CustomWordRecord(
    id: id,
    wordBookId: wordBookId,
    word: word,
    phonetic: '/test/',
    meaning: const [
      MeaningEntry(pos: 'n.', definitions: ['测试']),
    ],
    example: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

/// 可统计调用次数的 Fake 数据源（implements 保持契约完整）。
class FakeWordDataSource implements WordDataSource {
  FakeWordDataSource(this._data);

  final Map<String, List<Word>> _data;
  final Map<String, int> callCounts = {};

  @override
  Future<List<Word>> getWords(String wordBookId) async {
    callCounts[wordBookId] = (callCounts[wordBookId] ?? 0) + 1;
    final words = _data[wordBookId];
    if (words == null) {
      throw Exception('未知词库: $wordBookId');
    }
    return words;
  }
}

/// Fake CustomWordBookRepository：内存存在的词库 ID 集合。
class _FakeCustomWordBookRepository implements CustomWordBookRepository {
  _FakeCustomWordBookRepository(this._ids);

  final List<String> _ids;

  @override
  Future<bool> exists(String id) async => _ids.contains(id);

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

  @override
  Future<void> delete(String id) async {}
}

/// Fake CustomWordRepository：内存单词表，统计 toWords 调用次数。
class _FakeCustomWordRepository implements CustomWordRepository {
  _FakeCustomWordRepository(this._words);

  final Map<String, List<CustomWordRecord>> _words;
  int toWordsCallCount = 0;

  @override
  Future<List<Word>> toWords(String wordBookId) async {
    toWordsCallCount++;
    return (_words[wordBookId] ?? const [])
        .map((record) => record.toWord())
        .toList();
  }

  @override
  Future<List<CustomWordRecord>> getAll(String wordBookId) async =>
      List.of(_words[wordBookId] ?? const []);

  @override
  Future<CustomWordRecord?> getById(String wordBookId, String wordId) async {
    for (final record in _words[wordBookId] ?? const []) {
      if (record.id == wordId) return record;
    }
    return null;
  }

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
  Future<void> deleteByWordBookId(String wordBookId) async {}
}
