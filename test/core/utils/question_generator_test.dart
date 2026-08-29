import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/question_generator.dart';
import 'package:memora/data/dto/word_model.dart';

/// QuestionGenerator 单元测试。
///
/// 测试覆盖：
/// 1. 正常生成（5+ 不同释义 → 返回有效题目）
/// 2. 边界情况 1：词库不足 4 个不同释义 → 返回 null
/// 3. 边界情况 2：多个单词释义相同 → 按释义去重
/// 4. 边界情况 3：正确答案不进入干扰项
/// 5. 选项唯一性 + correctIndex 正确指向
/// 6. Fisher-Yates 可重复性（Random(42) 两次结果一致）
void main() {
  late QuestionGenerator generator;

  /// 构造一个测试用 Word
  Word makeWord({
    required String id,
    required String word,
    required String pos,
    required String definition,
    String phonetic = '/test/',
  }) {
    return Word(
      id: id,
      word: word,
      phonetic: phonetic,
      meaning: [
        MeaningEntry(pos: pos, definitions: [definition]),
      ],
      example: ['This is a test sentence.'],
      audio: '',
      wordBookId: 'test',
    );
  }

  /// 构造 5 个不同释义的单词
  List<Word> makeFiveUniqueWords() {
    return [
      makeWord(id: 'w1', word: 'abandon', pos: 'v.', definition: '放弃、抛弃'),
      makeWord(id: 'w2', word: 'bold', pos: 'adj.', definition: '勇敢的'),
      makeWord(id: 'w3', word: 'candid', pos: 'adj.', definition: '坦诚的'),
      makeWord(id: 'w4', word: 'dazzle', pos: 'v.', definition: '使目眩'),
      makeWord(id: 'w5', word: 'eager', pos: 'adj.', definition: '渴望的'),
    ];
  }

  group('QuestionGenerator.build — 正常生成', () {
    setUp(() {
      generator = QuestionGenerator(Random(42));
    });

    test('返回非 null 题目', () {
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question, isNotNull);
    });

    test('题目包含 4 个选项', () {
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question!.options.length, 4);
    });

    test('correctIndex 在 0-3 范围内', () {
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question!.correctIndex, inInclusiveRange(0, 3));
    });

    test('正确答案的释义在选项中', () {
      final words = makeFiveUniqueWords();
      final correctWord = words[0];
      final question = generator.build(
        correctWord: correctWord,
        allWords: words,
      );
      final correctMeaning = question!.options[question.correctIndex];
      expect(correctMeaning, contains('放弃'));
    });

    test('correctWord 被正确设置', () {
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question!.correctWord.id, 'w1');
    });
  });

  group('QuestionGenerator.build — 边界情况 1：词库不足', () {
    test('只有 3 个不同释义 → 返回 null', () {
      generator = QuestionGenerator(Random(42));
      final words = [
        makeWord(id: 'w1', word: 'a', pos: 'v.', definition: '释义A'),
        makeWord(id: 'w2', word: 'b', pos: 'v.', definition: '释义B'),
        makeWord(id: 'w3', word: 'c', pos: 'v.', definition: '释义C'),
      ];
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question, isNull);
    });

    test('4 个不同释义但正确答案占 1 个 → 仅 3 个干扰项候选 → 返回有效题目', () {
      generator = QuestionGenerator(Random(42));
      final words = [
        makeWord(id: 'w1', word: 'a', pos: 'v.', definition: '释义A'),
        makeWord(id: 'w2', word: 'b', pos: 'v.', definition: '释义B'),
        makeWord(id: 'w3', word: 'c', pos: 'v.', definition: '释义C'),
        makeWord(id: 'w4', word: 'd', pos: 'v.', definition: '释义D'),
      ];
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question, isNotNull);
      expect(question!.options.length, 4);
    });
  });

  group('QuestionGenerator.build — 边界情况 2：释义去重', () {
    test('多个单词释义相同 → 干扰项按释义去重', () {
      generator = QuestionGenerator(Random(42));
      final words = [
        makeWord(id: 'w1', word: 'abandon', pos: 'v.', definition: '放弃'),
        makeWord(id: 'w2', word: 'forsake', pos: 'v.', definition: '放弃'),
        makeWord(id: 'w3', word: 'desert', pos: 'v.', definition: '放弃'),
        makeWord(id: 'w4', word: 'bold', pos: 'adj.', definition: '勇敢的'),
        makeWord(id: 'w5', word: 'candid', pos: 'adj.', definition: '坦诚的'),
        makeWord(id: 'w6', word: 'dazzle', pos: 'v.', definition: '使目眩'),
      ];
      final question = generator.build(correctWord: words[0], allWords: words);
      // 即使有 3 个"放弃"，选项中"放弃"只出现一次
      expect(question, isNotNull);
      final abandonCount = question!.options
          .where((o) => o.contains('放弃'))
          .length;
      expect(abandonCount, 1);
    });

    test('所有释义都相同 → 返回 null', () {
      generator = QuestionGenerator(Random(42));
      final words = [
        makeWord(id: 'w1', word: 'a', pos: 'v.', definition: '相同'),
        makeWord(id: 'w2', word: 'b', pos: 'v.', definition: '相同'),
        makeWord(id: 'w3', word: 'c', pos: 'v.', definition: '相同'),
        makeWord(id: 'w4', word: 'd', pos: 'v.', definition: '相同'),
        makeWord(id: 'w5', word: 'e', pos: 'v.', definition: '相同'),
      ];
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question, isNull);
    });
  });

  group('QuestionGenerator.build — 边界情况 3：正确答案排除', () {
    test('正确答案不进入干扰项池', () {
      generator = QuestionGenerator(Random(42));
      final words = makeFiveUniqueWords();
      final correctWord = words[0]; // 'abandon', 释义 '放弃、抛弃'
      final question = generator.build(
        correctWord: correctWord,
        allWords: words,
      );
      // 正确答案释义在选项中只出现一次
      final correctMeaning = question!.options[question.correctIndex];
      final matchCount = question.options
          .where((o) => o == correctMeaning)
          .length;
      expect(matchCount, 1);
    });
  });

  group('QuestionGenerator.build — 选项唯一性', () {
    test('4 个选项互不相同', () {
      generator = QuestionGenerator(Random(42));
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      final uniqueOptions = question!.options.toSet();
      expect(uniqueOptions.length, 4);
    });
  });

  group('QuestionGenerator.build — Fisher-Yates 可重复性', () {
    test('相同 Random 种子 → 相同 correctIndex 和 options', () {
      final words = makeFiveUniqueWords();
      final gen1 = QuestionGenerator(Random(42));
      final gen2 = QuestionGenerator(Random(42));

      final q1 = gen1.build(correctWord: words[0], allWords: words);
      final q2 = gen2.build(correctWord: words[0], allWords: words);

      expect(q1!.correctIndex, q2!.correctIndex);
      expect(q1.options, q2.options);
    });

    test('不同 Random 种子 → correctIndex 可能不同', () {
      final words = makeFiveUniqueWords();
      final indices = <int>{};
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
        final gen = QuestionGenerator(Random(seed));
        final q = gen.build(correctWord: words[0], allWords: words);
        if (q != null) indices.add(q.correctIndex);
      }
      // 至少有 2 种不同的 correctIndex，证明打乱生效
      expect(indices.length, greaterThan(1));
    });
  });

  group('QuestionGenerator.build — correctAnswer getter', () {
    test('correctAnswer 返回正确答案释义', () {
      generator = QuestionGenerator(Random(42));
      final words = makeFiveUniqueWords();
      final question = generator.build(correctWord: words[0], allWords: words);
      expect(question!.correctAnswer, question.options[question.correctIndex]);
    });
  });

  group('QuestionGenerator.uniqueMeaningCount（doc 52）', () {
    setUp(() {
      generator = QuestionGenerator(Random(42));
    });

    test('5 个不同释义 → 5', () {
      expect(generator.uniqueMeaningCount(makeFiveUniqueWords()), 5);
    });

    test('释义相同按文本去重', () {
      final words = [
        makeWord(id: 'w1', word: 'abandon', pos: 'v.', definition: '放弃'),
        makeWord(id: 'w2', word: 'bold', pos: 'v.', definition: '放弃'),
        makeWord(id: 'w3', word: 'candid', pos: 'n.', definition: '坦诚'),
      ];
      expect(generator.uniqueMeaningCount(words), 2);
    });

    test('空词库 → 0', () {
      expect(generator.uniqueMeaningCount(const []), 0);
    });
  });
}
