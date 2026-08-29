import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/question_generator.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/domain/enums/learning_enums.dart';
import 'package:memora/domain/use_cases/apply_review_feedback_use_case.dart';
import 'package:memora/features/multiple_choice/controller/multiple_choice_controller.dart';

/// MultipleChoiceController 单元测试。
///
/// 测试覆盖：
/// 1. Bug 9：防重复提交（已作答再点选项无效）
/// 2. 约束 16/19：正确→fuzzy，错误→unknown
/// 3. Bug 10：nextQuestion 不保存 SM-2
/// 4. 约束 19：nextQuestion 需先作答
/// 5. 保存失败：hasSaveError 反馈
/// 6. 状态转换：最后一题 → isCompleted
///
/// 使用 `implements` 关键字创建 fake 仓库，无需调用真实构造函数。
void main() {
  Word makeWord(String id, String word, String definition) {
    return Word(
      id: id,
      word: word,
      phonetic: '/test/',
      meaning: [
        MeaningEntry(pos: 'v.', definitions: [definition]),
      ],
      example: ['Test sentence.'],
      audio: '',
      wordBookId: 'test',
    );
  }

  late List<Word> testWords;
  late FakeWordRepository wordRepo;
  late FakeReviewRepository reviewRepo;
  late FakeApplyReviewFeedbackUseCase useCase;
  late MultipleChoiceController controller;

  setUp(() {
    testWords = [
      makeWord('w1', 'abandon', '放弃'),
      makeWord('w2', 'bold', '勇敢的'),
      makeWord('w3', 'candid', '坦诚的'),
      makeWord('w4', 'dazzle', '使目眩'),
      makeWord('w5', 'eager', '渴望的'),
    ];

    wordRepo = FakeWordRepository(testWords);
    reviewRepo = FakeReviewRepository();
    useCase = FakeApplyReviewFeedbackUseCase();

    controller = MultipleChoiceController(
      wordRepo,
      reviewRepo,
      useCase,
      questionGenerator: QuestionGenerator(Random(42)),
    );
  });

  group('startQuiz — 加载题目', () {
    test('成功加载题目后状态正确', () async {
      // 让所有单词都标记为"到期复习"
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }

      await controller.startQuiz('test');

      expect(controller.state.isLoading, false);
      expect(controller.state.hasError, false);
      expect(controller.state.questions, isNotEmpty);
      expect(controller.state.currentIndex, 0);
      expect(controller.state.currentQuestion, isNotNull);
      expect(controller.state.hasAnswered, false);
      expect(controller.state.isCompleted, false);
    });

    test('无到期复习词 → 空队列 + isCompleted + 无提示', () async {
      await controller.startQuiz('test');

      expect(controller.state.isLoading, false);
      expect(controller.state.questions, isEmpty);
      expect(controller.state.isCompleted, true);
      expect(controller.state.errorMessage, isNull);
    });

    test('部分到期词 → 只为到期词生成题目（干扰项取整词库）', () async {
      // 词库 5 个词、仅 2 个到期：可生成 2 道题（干扰项来自整词库）
      reviewRepo.addDueReview('w1');
      reviewRepo.addDueReview('w2');
      await controller.startQuiz('test');

      expect(controller.state.questions.length, 2);
    });
  });

  group('词库太小边界（doc 52）', () {
    test('唯一释义 < 4 → 空队列 + 明确提示', () async {
      // 3 个不同释义：任何题都无法生成"1 正确 + 3 干扰"
      final smallWords = [
        makeWord('w1', 'abandon', '放弃'),
        makeWord('w2', 'bold', '勇敢的'),
        makeWord('w3', 'candid', '坦诚的'),
      ];
      final smallController = MultipleChoiceController(
        FakeWordRepository(smallWords),
        reviewRepo,
        useCase,
        questionGenerator: QuestionGenerator(Random(42)),
      );
      for (final w in smallWords) {
        reviewRepo.addDueReview(w.id);
      }

      await smallController.startQuiz('test');

      expect(smallController.state.questions, isEmpty);
      expect(smallController.state.isCompleted, true);
      expect(smallController.state.errorMessage, contains('4 个不同释义'));
    });

    test('恰好 4 个唯一释义且全部到期 → 可生成题目', () async {
      final fourWords = [
        makeWord('w1', 'abandon', '放弃'),
        makeWord('w2', 'bold', '勇敢的'),
        makeWord('w3', 'candid', '坦诚的'),
        makeWord('w4', 'dazzle', '使目眩'),
      ];
      final smallController = MultipleChoiceController(
        FakeWordRepository(fourWords),
        reviewRepo,
        useCase,
        questionGenerator: QuestionGenerator(Random(42)),
      );
      for (final w in fourWords) {
        reviewRepo.addDueReview(w.id);
      }

      await smallController.startQuiz('test');

      expect(smallController.state.questions, isNotEmpty);
      expect(smallController.state.errorMessage, isNull);
    });
  });

  group('selectOption — 防重复提交（Bug 9）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('第一次点击选项 → 正常作答', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      expect(controller.state.hasAnswered, true);
      expect(controller.state.selectedIndex, correctIndex);
      expect(controller.state.isCorrect, true);
      expect(controller.state.correctCount, 1);
    });

    test('已作答后再次点击 → 无效（Bug 9）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      // 再次点击不同选项
      final otherIndex = (correctIndex + 1) % 4;
      await controller.selectOption(otherIndex);

      // 状态不变
      expect(controller.state.selectedIndex, correctIndex);
      expect(controller.state.correctCount, 1);
      expect(controller.state.wrongCount, 0);
    });

    test('选错选项 → isCorrect=false + wrongCount+1', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      final wrongIndex = (correctIndex + 1) % 4;
      await controller.selectOption(wrongIndex);

      expect(controller.state.isCorrect, false);
      expect(controller.state.wrongCount, 1);
      expect(controller.state.correctCount, 0);
    });
  });

  group('selectOption — SM-2 映射（约束 16/Bug 11）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('正确答案 → feedback = fuzzy（不是 known）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      expect(useCase.lastFeedback, FeedbackType.fuzzy);
      expect(useCase.lastFeedback, isNot(FeedbackType.known));
    });

    test('错误答案 → feedback = unknown', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      final wrongIndex = (correctIndex + 1) % 4;
      await controller.selectOption(wrongIndex);

      expect(useCase.lastFeedback, FeedbackType.unknown);
    });
  });

  group('nextQuestion — 状态推进', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('未作答时 nextQuestion → 无效（约束 19）', () {
      final initialIndex = controller.state.currentIndex;
      controller.nextQuestion();

      expect(controller.state.currentIndex, initialIndex);
      expect(controller.state.hasAnswered, false);
    });

    test('作答后 nextQuestion → 推进到下一题 + 重置作答状态', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      controller.nextQuestion();

      expect(controller.state.currentIndex, 1);
      expect(controller.state.currentQuestion, isNotNull);
      expect(controller.state.hasAnswered, false);
      expect(controller.state.selectedIndex, isNull);
      expect(controller.state.isCorrect, isNull);
      expect(controller.state.hasSaveError, false);
    });

    test('最后一题 nextQuestion → isCompleted + currentQuestion=null', () async {
      final totalQuestions = controller.state.questions.length;

      for (var i = 0; i < totalQuestions; i++) {
        final correctIndex = controller.state.currentQuestion!.correctIndex;
        await controller.selectOption(correctIndex);
        controller.nextQuestion();
      }

      expect(controller.state.isCompleted, true);
      expect(controller.state.currentQuestion, isNull);
    });

    test('nextQuestion 不调用 UseCase（Bug 10）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      useCase.callCount = 0;
      controller.nextQuestion();

      expect(useCase.callCount, 0);
    });
  });

  group('selectOption — 保存失败反馈', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('UseCase 抛异常 → hasSaveError=true', () async {
      useCase.shouldThrow = true;

      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      expect(controller.state.hasSaveError, true);
      // 答题统计仍然更新（用户答案有效，不受保存成败影响）
      expect(controller.state.correctCount, 1);
    });

    test('保存失败后 nextQuestion → hasSaveError 重置', () async {
      useCase.shouldThrow = true;
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      expect(controller.state.hasSaveError, true);

      controller.nextQuestion();
      expect(controller.state.hasSaveError, false);
    });
  });
}

/// Fake WordRepository — 使用 `implements` 避免调用真实构造函数。
class FakeWordRepository implements WordRepository {
  FakeWordRepository(this._words);

  final List<Word> _words;

  @override
  Future<List<Word>> getWords(String wordBookId) async => _words;

  @override
  Future<int> getWordCount(String wordBookId) async => _words.length;

  @override
  Future<Word?> getWordById(String wordBookId, String wordId) async {
    return _words.where((w) => w.id == wordId).firstOrNull;
  }

  @override
  void clearCache() {
    // Fake 无缓存，无需清理
  }
}

/// Fake ReviewRepository — 内存存储，可控制到期复习队列。
class FakeReviewRepository implements ReviewRepository {
  final Set<String> _dueWordIds = {};
  final Map<String, WordReview> _store = {};

  void addDueReview(String wordId) {
    _dueWordIds.add(wordId);
  }

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async {
    return _store['$wordBookId:$wordId'];
  }

  @override
  Future<void> saveWordReview(WordReview review) async {
    _store['${review.wordBookId}:${review.wordId}'] = review;
  }

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async {
    return _dueWordIds.map((id) {
      final key = '$wordBookId:$id';
      return _store[key] ??
          WordReview(
            wordId: id,
            wordBookId: wordBookId,
            repetitionCount: 0,
            easinessFactor: 2.5,
            interval: 0,
            nextReviewDate: DateTime.now(),
            lastReviewDate: null,
            learned: false,
            mastery: 0.0,
          );
    }).toList();
  }

  @override
  Future<int> getLearnedCount(String wordBookId) async => 0;

  @override
  Future<int> getMasteredCount(String wordBookId) async => 0;

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async => {};

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async {
    return _store.values.where((r) => r.wordBookId == wordBookId).toList();
  }

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {
    for (final review in reviews) {
      _store['${review.wordBookId}:${review.wordId}'] = review;
    }
  }

  @override
  Future<int> getReviewedCount(String wordBookId) async => 0;

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {}

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async {}
}

/// Fake ApplyReviewFeedbackUseCase — 记录调用，可模拟失败。
class FakeApplyReviewFeedbackUseCase implements ApplyReviewFeedbackUseCase {
  FeedbackType? lastFeedback;
  String? lastWordId;
  String? lastWordBookId;
  int callCount = 0;
  bool shouldThrow = false;

  @override
  Future<WordReview> execute({
    required String wordBookId,
    required String wordId,
    required FeedbackType feedback,
  }) async {
    callCount++;
    lastFeedback = feedback;
    lastWordId = wordId;
    lastWordBookId = wordBookId;

    if (shouldThrow) {
      throw Exception('Simulated save failure');
    }

    return WordReview(
      wordId: wordId,
      wordBookId: wordBookId,
      repetitionCount: 1,
      easinessFactor: 2.5,
      interval: 1,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      lastReviewDate: DateTime.now(),
      learned: false,
      mastery: 0.1,
    );
  }
}
