import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/data/sources/word_data_source.dart';

/// WordRepository 多词库缓存隔离测试（doc 34 / 35 / 36 / 37）。
///
/// 覆盖：
/// 1. 数据隔离：cet6 / cet4 各自独立，wordBookId 全程正确
/// 2. 缓存隔离：先读 cet6 再读 cet4 再读 cet6，不会串库（Bug 2 防御），
///    每个词库只向 DataSource 请求一次
/// 3. 相同 wordId 跨词库不冲突（cet6:1 != cet4:1）
/// 4. 未知 wordBookId 明确失败
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
      final repository = WordRepository(fake);

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
      final repository = WordRepository(fake);

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
      final repository = WordRepository(fake);

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
      final repository = WordRepository(fake);

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
      final repository = WordRepository(fake);

      final cet6Word = await repository.getWordById('cet6', '1');
      final cet4Word = await repository.getWordById('cet4', '1');

      expect(cet6Word, isNotNull);
      expect(cet4Word, isNotNull);
      expect(cet6Word!.wordBookId, 'cet6');
      expect(cet4Word!.wordBookId, 'cet4');
      expect(cet6Word, isNot(equals(cet4Word)));
    });
  });

  group('未知 wordBookId（doc 37）', () {
    test('透传 DataSource 的明确失败，不返回 CET-6', () async {
      final fake = FakeWordDataSource({
        'cet6': [makeWord(id: '1', word: 'abandon', wordBookId: 'cet6')],
      });
      final repository = WordRepository(fake);

      await expectLater(
        repository.getWords('unknown'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('未知词库'),
          ),
        ),
      );
    });
  });
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
