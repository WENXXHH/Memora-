import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/features/spelling_quiz/state/spelling_quiz_state.dart';

/// SpellingQuizState 测试（doc 32）。
///
/// 覆盖：
/// - 初始状态
/// - 各字段更新（isLoading / hasError / currentIndex / 统计 / inputError...）
/// - sentinel copyWith：不传参保持旧值、显式 null 能清除 nullable 字段
/// - currentWord getter（越界返回 null，doc 12）
void main() {
  Word makeWord(String id) {
    return Word(
      id: id,
      word: 'word$id',
      phonetic: '/test/',
      meaning: [
        MeaningEntry(pos: 'v.', definitions: ['释义$id']),
      ],
      example: ['Test sentence.'],
      audio: '',
      wordBookId: 'test',
    );
  }

  late SpellingQuizState baseState;
  late List<Word> testWords;

  setUp(() {
    testWords = [makeWord('1'), makeWord('2'), makeWord('3')];
    baseState = const SpellingQuizState(
      isLoading: false,
      hasError: false,
      words: [],
      currentIndex: 0,
      hasAnswered: false,
      isCorrect: null,
      correctCount: 0,
      wrongCount: 0,
      isCompleted: false,
    );
  });

  group('初始状态', () {
    test('默认值正确', () {
      expect(baseState.isLoading, false);
      expect(baseState.hasError, false);
      expect(baseState.errorMessage, isNull);
      expect(baseState.words, isEmpty);
      expect(baseState.currentIndex, 0);
      expect(baseState.hasAnswered, false);
      expect(baseState.isCorrect, isNull);
      expect(baseState.submittedAnswer, isNull);
      expect(baseState.correctCount, 0);
      expect(baseState.wrongCount, 0);
      expect(baseState.isCompleted, false);
      expect(baseState.hasSaveError, false);
      expect(baseState.inputError, isNull);
    });
  });

  group('普通字段更新', () {
    test('更新 isLoading', () {
      expect(baseState.copyWith(isLoading: true).isLoading, true);
    });

    test('更新 hasError / errorMessage', () {
      final next = baseState.copyWith(hasError: true, errorMessage: '加载失败');
      expect(next.hasError, true);
      expect(next.errorMessage, '加载失败');
    });

    test('更新 currentIndex', () {
      expect(baseState.copyWith(currentIndex: 2).currentIndex, 2);
    });

    test('更新 hasAnswered / isCorrect / submittedAnswer', () {
      final next = baseState.copyWith(
        hasAnswered: true,
        isCorrect: true,
        submittedAnswer: 'abandon',
      );
      expect(next.hasAnswered, true);
      expect(next.isCorrect, true);
      expect(next.submittedAnswer, 'abandon');
    });

    test('更新 correctCount / wrongCount', () {
      final next = baseState.copyWith(correctCount: 5, wrongCount: 3);
      expect(next.correctCount, 5);
      expect(next.wrongCount, 3);
    });

    test('更新 isCompleted', () {
      expect(baseState.copyWith(isCompleted: true).isCompleted, true);
    });

    test('更新 hasSaveError', () {
      expect(baseState.copyWith(hasSaveError: true).hasSaveError, true);
    });

    test('更新 inputError', () {
      final next = baseState.copyWith(inputError: '请输入单词');
      expect(next.inputError, '请输入单词');
    });
  });

  group('sentinel copyWith — nullable 字段', () {
    SpellingQuizState makeNullableState() => baseState.copyWith(
      hasError: true,
      errorMessage: '错误',
      isCorrect: false,
      submittedAnswer: 'abandon',
      inputError: '请输入单词',
    );

    test('不传参数 → 保留旧值', () {
      final next = makeNullableState().copyWith();
      expect(next.errorMessage, '错误');
      expect(next.isCorrect, false);
      expect(next.submittedAnswer, 'abandon');
      expect(next.inputError, '请输入单词');
    });

    test('显式 null 能清除 errorMessage', () {
      expect(
        makeNullableState().copyWith(errorMessage: null).errorMessage,
        isNull,
      );
    });

    test('显式 null 能清除 isCorrect', () {
      expect(makeNullableState().copyWith(isCorrect: null).isCorrect, isNull);
    });

    test('显式 null 能清除 submittedAnswer', () {
      expect(
        makeNullableState().copyWith(submittedAnswer: null).submittedAnswer,
        isNull,
      );
    });

    test('显式 null 能清除 inputError', () {
      expect(makeNullableState().copyWith(inputError: null).inputError, isNull);
    });
  });

  group('currentWord getter（doc 12）', () {
    test('正常范围返回对应单词', () {
      final state = baseState.copyWith(words: testWords, currentIndex: 1);
      expect(state.currentWord?.id, '2');
    });

    test('越界返回 null（防御，不用于判断完成态）', () {
      final empty = baseState.copyWith(words: [], currentIndex: 0);
      expect(empty.currentWord, isNull);

      final outOfRange = baseState.copyWith(words: testWords, currentIndex: 3);
      expect(outOfRange.currentWord, isNull);
    });
  });
}
