import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/review_record_dto.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/domain/services/word_book_id_map.dart';
import 'package:memora/domain/services/word_id_map.dart';

/// CET-4 ID 映射测试（doc 40 / Bug 7 / Bug 8 防御）。
///
/// 验证现有映射算法无需为 CET-4 添加特判（doc 29）：
/// 1. WordBookIdMap 能解析 cet4 ↔ 后端 "CET-4"
/// 2. WordIdMap 能按英文文本映射 CET-4 单词，不要求 Flutter ID == 后端 ID
void main() {
  group('WordBookIdMap 解析 CET-4（doc 29 / Bug 7）', () {
    test('后端 CET-4 → cet4 映射成功', () {
      final map = WordBookIdMap.fromBooks([
        const WordBookResponse(id: 1, name: 'CET-6'),
        const WordBookResponse(
          id: 203,
          name: 'CET-4',
          isBuiltin: true,
          ownerUserId: null,
        ),
      ]);

      expect(map.stringToInt('cet4'), 203);
      expect(map.stringToInt('cet6'), 1);
      expect(map.intToString(203), 'cet4');
    });

    test('CET-4 与 CET-6 命名空间互不干扰', () {
      final map = WordBookIdMap.fromBooks([
        const WordBookResponse(id: 1, name: 'CET-6'),
        const WordBookResponse(id: 2, name: 'CET-4'),
      ]);

      expect(map.stringToInt('cet6'), 1);
      expect(map.stringToInt('cet4'), 2);
    });
  });

  group('WordIdMap 映射 CET-4 单词（doc 40 / Bug 8）', () {
    test('按英文文本匹配，Flutter ID 与后端 ID 不同也能映射', () {
      final map = WordIdMap.fromWords(
        remoteWords: [
          const WordResponse(id: 201, wordBookId: 203, text: 'abandon'),
          const WordResponse(id: 202, wordBookId: 203, text: 'ability'),
        ],
        localWords: [
          _word(id: '1', word: 'abandon', bookId: 'cet4'),
          _word(id: '2', word: 'ability', bookId: 'cet4'),
        ],
      );

      // Flutter "1" ↔ 后端 201，通过英文文本 "abandon" 对齐
      expect(map.stringToInt('1'), 201);
      expect(map.intToString(201), '1');
      expect(map.stringToInt('2'), 202);
    });

    test('映射缺失返回 null（不强行兜底）', () {
      final map = WordIdMap.fromWords(
        remoteWords: [
          const WordResponse(id: 201, wordBookId: 203, text: 'abandon'),
        ],
        localWords: [
          _word(id: '1', word: 'totally-unknown-word', bookId: 'cet4'),
        ],
      );

      expect(map.stringToInt('1'), isNull);
    });
  });
}

Word _word({required String id, required String word, required String bookId}) {
  return Word(
    id: id,
    word: word,
    phonetic: '/test/',
    meaning: const [
      MeaningEntry(pos: 'n.', definitions: ['测试']),
    ],
    example: const ['Test sentence.'],
    audio: '',
    wordBookId: bookId,
  );
}
