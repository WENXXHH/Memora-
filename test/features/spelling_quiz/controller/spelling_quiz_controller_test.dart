import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/domain/enums/learning_enums.dart';
import 'package:memora/domain/use_cases/apply_review_feedback_use_case.dart';
import 'package:memora/features/spelling_quiz/controller/spelling_quiz_controller.dart';

/// SpellingQuizController 单元测试（doc 33 全部 18 项）。
///
/// 测试覆盖：
/// 1. startQuiz 正常加载题目
/// 2. 空队列正确处理
/// 3. 正确答案（hasAnswered / isCorrect / correctCount）
/// 4. 错误答案（hasAnswered / isCorrect / wrongCount）
/// 5. 正确 → known
/// 6. 错误 → unknown
/// 7. 大小写正确容错
/// 8. 前后空格正确容错
/// 9. 空输入不提交 → inputError
/// 10. 空输入不调用 UseCase
/// 11. 同一道题重复 submit 只保存一次
/// 12. nextQuestion 不调用 UseCase
/// 13. nextQuestion 推进 currentIndex
/// 14. nextQuestion 清理作答字段 + inputError
/// 15. 最后一题 nextQuestion → isCompleted
/// 16. 保存失败 → hasSaveError
/// 17. 保存失败不改变答题真假
/// 18. 不同 wordBookId 数据隔离
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
  late SpellingQuizController controller;

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

    controller = SpellingQuizController(wordRepo, reviewRepo, useCase);
  });

  Future<void> startWithAllDue() async {
    for (final w in testWords) {
      reviewRepo.addDueReview(w.id);
    }
    await controller.startQuiz('test');
  }

  group('startQuiz — 加载题目（doc 33 #1, #2）', () {
    test('#1 startQuiz 正常加载题目', () async {
      await startWithAllDue();

      expect(controller.state.isLoading, false);
      expect(controller.state.hasError, false);
      expect(controller.state.words, isNotEmpty);
      expect(controller.state.words.length, lessThanOrEqualTo(10));
      expect(controller.state.currentIndex, 0);
      expect(controller.state.currentWord, isNotNull);
      expect(controller.state.hasAnswered, false);
      expect(controller.state.isCompleted, false);
      expect(controller.state.inputError, isNull);
    });

    test('#2 空队列正确处理（空 words + isCompleted，页面走空状态分支）', () async {
      await controller.startQuiz('test');

      expect(controller.state.words, isEmpty);
      expect(controller.state.isCompleted, true);
      expect(controller.state.hasError, false);
      expect(controller.state.currentWord, isNull);
    });

    test('只有 1 个到期词 → 正常开始拼写（doc 82：拼写不设 4 词门槛）', () async {
      final singleWord = makeWord('w1', 'abandon', '放弃');
      final singleController = SpellingQuizController(
        FakeWordRepository([singleWord]),
        FakeReviewRepository()..addDueReview('w1'),
        useCase,
      );

      await singleController.startQuiz('test');

      expect(singleController.state.isLoading, false);
      expect(singleController.state.hasError, false);
      expect(singleController.state.words, [singleWord]);
      expect(singleController.state.isCompleted, false);
    });

    test('加载失败 → hasError + errorMessage', () async {
      wordRepo.throwOnGetWords = true;

      await controller.startQuiz('test');

      expect(controller.state.isLoading, false);
      expect(controller.state.hasError, true);
      expect(controller.state.errorMessage, isNotNull);
    });
  });

  group('submitAnswer — 正确 / 错误（doc 33 #3, #4, #5, #6）', () {
    setUp(startWithAllDue);

    test('#3 正确答案', () async {
      await controller.submitAnswer('abandon');

      expect(controller.state.hasAnswered, true);
      expect(controller.state.isCorrect, true);
      expect(controller.state.correctCount, 1);
      expect(controller.state.wrongCount, 0);
      expect(controller.state.submittedAnswer, 'abandon');
    });

    test('#4 错误答案', () async {
      await controller.submitAnswer('abandonn');

      expect(controller.state.hasAnswered, true);
      expect(controller.state.isCorrect, false);
      expect(controller.state.wrongCount, 1);
      expect(controller.state.correctCount, 0);
    });

    test('#5 正确 → known', () async {
      await controller.submitAnswer('abandon');

      expect(useCase.lastFeedback, FeedbackType.known);
      expect(useCase.lastWordId, 'w1');
      expect(useCase.lastWordBookId, 'test');
    });

    test('#6 错误 → unknown', () async {
      await controller.submitAnswer('abandonn');

      expect(useCase.lastFeedback, FeedbackType.unknown);
      expect(useCase.lastWordId, 'w1');
    });
  });

  group('submitAnswer — 容错（doc 33 #7, #8）', () {
    setUp(startWithAllDue);

    test('#7 大小写正确容错', () async {
      await controller.submitAnswer('ABANDON');
      expect(controller.state.isCorrect, true);
      expect(controller.state.correctCount, 1);
    });

    test('#8 前后空格正确容错', () async {
      await controller.submitAnswer('  abandon  ');
      expect(controller.state.isCorrect, true);
    });
  });

  group('submitAnswer — 空输入（doc 33 #9, #10）', () {
    setUp(startWithAllDue);

    test('#9 空输入不提交 → inputError', () async {
      await controller.submitAnswer('');

      expect(controller.state.inputError, '请输入单词');
      expect(controller.state.hasAnswered, false);
      expect(controller.state.isCorrect, isNull);
      expect(controller.state.correctCount, 0);
    });

    test('只有空格也算空输入', () async {
      await controller.submitAnswer('   ');

      expect(controller.state.inputError, '请输入单词');
      expect(controller.state.hasAnswered, false);
    });

    test('#10 空输入不调用 UseCase', () async {
      await controller.submitAnswer('');

      expect(useCase.callCount, 0);
    });

    test('inputError 在合法提交后清除', () async {
      await controller.submitAnswer('');
      expect(controller.state.inputError, '请输入单词');

      await controller.submitAnswer('abandon');

      expect(controller.state.inputError, isNull);
      expect(controller.state.isCorrect, true);
    });
  });

  group('submitAnswer — 防重复（doc 33 #11）', () {
    setUp(startWithAllDue);

    test('#11 同一道题重复 submit 只保存一次', () async {
      await controller.submitAnswer('abandon');
      await controller.submitAnswer('abandonn');

      expect(useCase.callCount, 1);
      expect(controller.state.correctCount, 1);
      expect(controller.state.wrongCount, 0);
    });

    test('重复提交不改变 inputError / 统计', () async {
      await controller.submitAnswer('abandon');
      expect(controller.state.inputError, isNull);

      await controller.submitAnswer('');
      expect(controller.state.inputError, isNull);
      expect(useCase.callCount, 1);
      expect(controller.state.correctCount, 1);
      expect(controller.state.wrongCount, 0);
    });
  });

  group('nextQuestion — 推进（doc 33 #12, #13, #14, #15）', () {
    setUp(startWithAllDue);

    test('#12 nextQuestion 不调用 UseCase', () async {
      await controller.submitAnswer('abandon');
      useCase.callCount = 0;

      controller.nextQuestion();

      expect(useCase.callCount, 0);
    });

    test('#13 nextQuestion 推进 currentIndex', () async {
      await controller.submitAnswer('abandon');
      final indexBefore = controller.state.currentIndex;

      controller.nextQuestion();

      expect(controller.state.currentIndex, indexBefore + 1);
      expect(controller.state.currentWord?.id, 'w2');
    });

    test('#14 nextQuestion 清理作答字段 + inputError', () async {
      // 先制造 inputError，再正常作答，然后 nextQuestion 应全部清空
      await controller.submitAnswer('');
      await controller.submitAnswer('abandon');
      expect(controller.state.hasAnswered, true);

      controller.nextQuestion();

      expect(controller.state.hasAnswered, false);
      expect(controller.state.isCorrect, isNull);
      expect(controller.state.submittedAnswer, isNull);
      expect(controller.state.inputError, isNull);
      expect(controller.state.hasSaveError, false);
    });

    test('未作答时 nextQuestion 无效', () async {
      final indexBefore = controller.state.currentIndex;

      controller.nextQuestion();

      expect(controller.state.currentIndex, indexBefore);
    });

    test('#15 最后一题 nextQuestion → isCompleted', () async {
      final total = controller.state.words.length;
      for (var i = 0; i < total; i++) {
        final word = controller.state.currentWord!;
        await controller.submitAnswer(word.word);
        controller.nextQuestion();
      }

      expect(controller.state.isCompleted, true);
      expect(controller.state.correctCount, total);
    });
  });

  group('保存失败（doc 33 #16, #17）', () {
    setUp(() async {
      await startWithAllDue();
      useCase.shouldThrow = true;
    });

    test('#16 保存失败 → hasSaveError = true', () async {
      await controller.submitAnswer('abandon');

      expect(controller.state.hasSaveError, true);
    });

    test('#17 保存失败不改变答题真假', () async {
      await controller.submitAnswer('abandon');

      expect(controller.state.hasAnswered, true);
      expect(controller.state.isCorrect, true);
      expect(controller.state.correctCount, 1);
      expect(controller.state.submittedAnswer, 'abandon');
    });
  });

  group('不同 wordBookId 数据隔离（doc 33 #18）', () {
    test('#18 不同词库互不影响', () async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id, wordBookId: 'bookA');
      }
      reviewRepo.addDueReview('w1', wordBookId: 'bookB');

      await controller.startQuiz('bookA');
      expect(controller.state.words.length, testWords.length);

      await controller.startQuiz('bookB');
      expect(controller.state.words.length, 1);
      expect(controller.state.words.first.id, 'w1');
    });
  });
}

/// Fake WordRepository — 使用 `implements` 避免调用真实构造函数。
class FakeWordRepository implements WordRepository {
  FakeWordRepository(this._words);

  final List<Word> _words;

  /// 模拟加载失败（用于 hasError 分支测试）。
  bool throwOnGetWords = false;

  @override
  Future<List<Word>> getWords(String wordBookId) async {
    if (throwOnGetWords) {
      throw Exception('load failed');
    }
    return _words;
  }

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

/// Fake ReviewRepository — 按词库记录到期队列，可控制到期复习词。
class FakeReviewRepository implements ReviewRepository {
  final Map<String, Set<String>> _dueByBook = {};
  final Map<String, WordReview> _store = {};

  void addDueReview(String wordId, {String wordBookId = 'test'}) {
    _dueByBook.putIfAbsent(wordBookId, () => {}).add(wordId);
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
    final dueIds = _dueByBook[wordBookId] ?? {};
    return dueIds.map((id) {
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
