import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/spelling_answer_matcher.dart';

/// SpellingAnswerMatcher 单元测试（doc 31 全部 12 项）。
///
/// 规则（doc 6 / 7）：
/// - 只做 trim + toLowerCase 容错
/// - 错字母 / 少字母 / 多字母 / 内部多空格 一律判错，不做模糊匹配
void main() {
  const answer = 'abandon';

  group('SpellingAnswerMatcher.normalize', () {
    test('trim + toLowerCase', () {
      expect(SpellingAnswerMatcher.normalize('  Abandon  '), 'abandon');
    });
  });

  group('SpellingAnswerMatcher.isCorrect — 正确判定', () {
    test('#1 完全一致 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: answer, answer: answer),
        true,
      );
    });

    test('#2 大写输入 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'ABANDON', answer: answer),
        true,
      );
    });

    test('#3 首字母大写 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'Abandon', answer: answer),
        true,
      );
    });

    test('#4 前导空格 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: '  abandon', answer: answer),
        true,
      );
    });

    test('#5 尾部空格 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'abandon  ', answer: answer),
        true,
      );
    });

    test('#6 前后空格 → true', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: '  abandon  ', answer: answer),
        true,
      );
    });
  });

  group('SpellingAnswerMatcher.isCorrect — 错误判定', () {
    test('#7 错一个字母 → false', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'abandonx', answer: answer),
        false,
      );
    });

    test('#8 少一个字母 → false', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'abando', answer: answer),
        false,
      );
    });

    test('#9 多一个字母 → false', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'abandonnn', answer: answer),
        false,
      );
    });

    test('#10 空字符串 → false', () {
      expect(SpellingAnswerMatcher.isCorrect(input: '', answer: answer), false);
    });

    test('#11 只有空格 → false', () {
      expect(
        SpellingAnswerMatcher.isCorrect(input: '   ', answer: answer),
        false,
      );
    });

    test('#12 内部多空格不应被自动修复', () {
      // 两个词中间夹多个空格属于"拼写错误"，不做智能修复
      expect(
        SpellingAnswerMatcher.isCorrect(input: 'aband on', answer: answer),
        false,
      );
    });
  });
}
