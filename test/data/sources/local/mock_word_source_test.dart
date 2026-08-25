import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/sources/local/mock_word_source.dart';

/// MockWordSource 内置词库 asset 解析测试（doc 32 / 33）。
///
/// 使用真实 asset（pubspec 已注册 cet-4.json / cet-6.json）：
/// 1. CET-4：可读取、非空、wordBookId 全为 cet4、wordId 唯一、英文非空
/// 2. CET-6 回归：可读取、非空、wordBookId 全为 cet6
/// 3. 未知词库明确失败（不回退 cet6）
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockWordSource source;

  setUp(() {
    source = MockWordSource();
  });

  group('CET-4 asset 解析（doc 32）', () {
    test('可以成功读取并解析为 Word', () async {
      final words = await source.getWords('cet4');
      expect(words, isNotEmpty);
      expect(words, isA<List<Word>>());
    });

    test('结果非空且数量为 200', () async {
      final words = await source.getWords('cet4');
      expect(words.length, 200);
    });

    test('每条 Word.wordBookId == cet4', () async {
      final words = await source.getWords('cet4');
      expect(words.every((w) => w.wordBookId == 'cet4'), isTrue);
    });

    test('同一词库 wordId 唯一', () async {
      final words = await source.getWords('cet4');
      final ids = words.map((w) => w.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('英文 word 非空', () async {
      final words = await source.getWords('cet4');
      expect(words.every((w) => w.word.trim().isNotEmpty), isTrue);
    });

    test('meaning 满足现有模型要求（每词性至少一个释义）', () async {
      final words = await source.getWords('cet4');
      for (final word in words) {
        expect(word.meaning, isNotEmpty);
        for (final entry in word.meaning) {
          expect(entry.pos.trim(), isNotEmpty);
          expect(entry.definitions, isNotEmpty);
        }
      }
    });
  });

  group('CET-6 回归（doc 33）', () {
    test('getWords(cet6) 非空且全部属于 cet6', () async {
      final words = await source.getWords('cet6');
      expect(words, isNotEmpty);
      expect(words.length, 200);
      expect(words.every((w) => w.wordBookId == 'cet6'), isTrue);
    });
  });

  group('未知词库（doc 37 / Bug 3 防御）', () {
    test('unknown 明确失败，不回退 CET-6', () async {
      await expectLater(
        source.getWords('unknown'),
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
