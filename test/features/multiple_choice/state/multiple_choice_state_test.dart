import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/multiple_choice_question.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/features/multiple_choice/state/multiple_choice_state.dart';

/// MultipleChoiceState copyWith sentinel 模式测试。
///
/// 约束 21：copyWith 必须用 sentinel 模式区分"未传参"与"显式传 null"，
/// 否则会触发"最后一题循环"Bug。
void main() {
  Word makeWord(String id) {
    return Word(
      id: id,
      word: 'test$id',
      phonetic: '/test/',
      meaning: [
        MeaningEntry(pos: 'v.', definitions: ['测试$id']),
      ],
      example: ['Test sentence.'],
      audio: '',
      wordBookId: 'test',
    );
  }

  MultipleChoiceQuestion makeQuestion(String id) {
    return MultipleChoiceQuestion(
      correctWord: makeWord(id),
      options: ['测试$id', '干扰1', '干扰2', '干扰3'],
      correctIndex: 0,
    );
  }

  late MultipleChoiceState baseState;

  setUp(() {
    baseState = const MultipleChoiceState(
      isLoading: false,
      hasError: false,
      questions: [],
      currentIndex: 0,
      currentQuestion: null,
      selectedIndex: null,
      hasAnswered: false,
      isCorrect: null,
      correctCount: 0,
      wrongCount: 0,
      isCompleted: false,
    );
  });

  group('MultipleChoiceState.copyWith — 普通字段更新', () {
    test('更新 isLoading', () {
      final next = baseState.copyWith(isLoading: true);
      expect(next.isLoading, true);
      expect(next.hasError, false);
    });

    test('更新 correctCount', () {
      final next = baseState.copyWith(correctCount: 5);
      expect(next.correctCount, 5);
    });

    test('更新 wrongCount', () {
      final next = baseState.copyWith(wrongCount: 3);
      expect(next.wrongCount, 3);
    });

    test('更新 hasAnswered', () {
      final next = baseState.copyWith(hasAnswered: true);
      expect(next.hasAnswered, true);
    });

    test('更新 hasSaveError', () {
      final next = baseState.copyWith(hasSaveError: true);
      expect(next.hasSaveError, true);
    });
  });

  group('MultipleChoiceState.copyWith — sentinel 模式（nullable 字段）', () {
    test('currentQuestion：未传参 → 保留旧值', () {
      final question = makeQuestion('w1');
      final state = baseState.copyWith(currentQuestion: question);
      final next = state.copyWith(isLoading: true);
      expect(next.currentQuestion, question);
    });

    test('currentQuestion：显式传 null → 清空', () {
      final question = makeQuestion('w1');
      final state = baseState.copyWith(currentQuestion: question);
      final next = state.copyWith(currentQuestion: null);
      expect(next.currentQuestion, isNull);
    });

    test('selectedIndex：未传参 → 保留旧值', () {
      final state = baseState.copyWith(selectedIndex: 2);
      final next = state.copyWith(hasAnswered: true);
      expect(next.selectedIndex, 2);
    });

    test('selectedIndex：显式传 null → 清空', () {
      final state = baseState.copyWith(selectedIndex: 2);
      final next = state.copyWith(selectedIndex: null);
      expect(next.selectedIndex, isNull);
    });

    test('isCorrect：未传参 → 保留旧值', () {
      final state = baseState.copyWith(isCorrect: true);
      final next = state.copyWith(hasAnswered: true);
      expect(next.isCorrect, true);
    });

    test('isCorrect：显式传 null → 清空', () {
      final state = baseState.copyWith(isCorrect: true);
      final next = state.copyWith(isCorrect: null);
      expect(next.isCorrect, isNull);
    });

    test('errorMessage：未传参 → 保留旧值', () {
      final state = baseState.copyWith(errorMessage: '网络错误');
      final next = state.copyWith(isLoading: false);
      expect(next.errorMessage, '网络错误');
    });

    test('errorMessage：显式传 null → 清空', () {
      final state = baseState.copyWith(errorMessage: '网络错误');
      final next = state.copyWith(errorMessage: null);
      expect(next.errorMessage, isNull);
    });
  });

  group('MultipleChoiceState — 初始状态不变量', () {
    test('初始状态：未作答', () {
      expect(baseState.selectedIndex, isNull);
      expect(baseState.hasAnswered, false);
      expect(baseState.isCorrect, isNull);
      expect(baseState.isCompleted, false);
      expect(baseState.hasSaveError, false);
    });
  });

  group('MultipleChoiceState — 答题后状态不变量', () {
    test(
      '已作答：selectedIndex != null && hasAnswered == true && isCorrect != null',
      () {
        final answered = baseState.copyWith(
          selectedIndex: 1,
          hasAnswered: true,
          isCorrect: false,
        );
        expect(answered.selectedIndex, isNotNull);
        expect(answered.hasAnswered, true);
        expect(answered.isCorrect, isNotNull);
      },
    );
  });

  group('MultipleChoiceState — 完成状态不变量', () {
    test('完成：isCompleted == true && currentQuestion == null', () {
      final completed = baseState.copyWith(
        currentQuestion: null,
        isCompleted: true,
      );
      expect(completed.isCompleted, true);
      expect(completed.currentQuestion, isNull);
    });
  });
}
