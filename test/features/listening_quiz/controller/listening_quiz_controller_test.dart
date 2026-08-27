import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/services/listening_audio/fake_listening_audio_service.dart';
import 'package:memora/core/utils/question_generator.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/domain/enums/learning_enums.dart';
import 'package:memora/domain/use_cases/apply_review_feedback_use_case.dart';
import 'package:memora/features/listening_quiz/controller/listening_quiz_controller.dart';

/// ListeningQuizController 单元测试（doc 32 全部 12 项）。
///
/// 测试覆盖：
/// 1. startQuiz 能产生第一题
/// 2. 第一题准备后调用一次 play
/// 3. replay 不改变 currentIndex
/// 4. replay 不改变成绩
/// 5. 正确答案 → fuzzy
/// 6. 错误答案 → unknown
/// 7. 每题只保存一次
/// 8. 重复点击答案无效
/// 9. nextQuestion 只前进一次
/// 10. nextQuestion 自动播放新题
/// 11. 播放失败不保存 Review
/// 12. dispose 停止音频
///
/// 音频测试不真的调用扬声器，使用 [FakeListeningAudioService] 记录
/// playCalls / stopCalls / lastPlayedWord。
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
  late FakeListeningAudioService audioService;
  late ListeningQuizController controller;

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
    audioService = FakeListeningAudioService();

    controller = ListeningQuizController(
      wordRepo,
      reviewRepo,
      useCase,
      audioService,
      questionGenerator: QuestionGenerator(Random(42)),
    );
  });

  group('startQuiz — 加载题目 + 播放（doc 32 #1, #2）', () {
    test('#1 startQuiz 能产生第一题', () async {
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

    test('#2 第一题准备后调用一次 play', () async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }

      await controller.startQuiz('test');

      final firstWord = controller.state.currentQuestion!.correctWord.word;
      expect(audioService.playCalls, [firstWord]);
      expect(audioService.lastPlayedWord, firstWord);
      expect(controller.state.isPlaying, false);
      expect(controller.state.hasAudioError, false);
    });

    test('无到期复习词 → 空队列 + isCompleted + 不播放', () async {
      await controller.startQuiz('test');

      expect(controller.state.questions, isEmpty);
      expect(controller.state.isCompleted, true);
      expect(audioService.playCalls, isEmpty);
    });
  });

  group('replay — 重播（doc 32 #3, #4）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
      audioService.playCalls.clear();
    });

    test('#3 replay 不改变 currentIndex', () async {
      final indexBefore = controller.state.currentIndex;

      await controller.replay();

      expect(controller.state.currentIndex, indexBefore);
    });

    test('#4 replay 不改变成绩', () async {
      // 先答对一题建立成绩，再跳到下一题
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);
      await controller.nextQuestion();
      final correctBefore = controller.state.correctCount;
      final wrongBefore = controller.state.wrongCount;

      await controller.replay();

      expect(controller.state.correctCount, correctBefore);
      expect(controller.state.wrongCount, wrongBefore);
    });

    test('replay 先 stop 再 play 当前词', () async {
      final currentWord = controller.state.currentQuestion!.correctWord.word;

      await controller.replay();

      expect(audioService.stopCalls, greaterThanOrEqualTo(1));
      expect(audioService.playCalls, [currentWord]);
    });
  });

  group('selectOption — 作答 + SM-2 映射（doc 32 #5, #6, #7, #8）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('#5 正确答案 → feedback = fuzzy（不是 known）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;

      await controller.selectOption(correctIndex);

      expect(useCase.lastFeedback, FeedbackType.fuzzy);
      expect(useCase.lastFeedback, isNot(FeedbackType.known));
      expect(controller.state.isCorrect, true);
      expect(controller.state.correctCount, 1);
    });

    test('#6 错误答案 → feedback = unknown', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      final wrongIndex = (correctIndex + 1) % 4;

      await controller.selectOption(wrongIndex);

      expect(useCase.lastFeedback, FeedbackType.unknown);
      expect(controller.state.isCorrect, false);
      expect(controller.state.wrongCount, 1);
    });

    test('#7 每题只保存一次（UseCase callCount == 1）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;

      await controller.selectOption(correctIndex);

      expect(useCase.callCount, 1);
    });

    test('#8 重复点击答案无效', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;

      await controller.selectOption(correctIndex);
      // 再次点击不同选项
      final otherIndex = (correctIndex + 1) % 4;
      await controller.selectOption(otherIndex);

      expect(useCase.callCount, 1);
      expect(controller.state.selectedIndex, correctIndex);
      expect(controller.state.correctCount, 1);
      expect(controller.state.wrongCount, 0);
    });
  });

  group('nextQuestion — 推进 + 自动播放（doc 32 #9, #10）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
    });

    test('#9 nextQuestion 只前进一次', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);
      final indexBefore = controller.state.currentIndex;

      await controller.nextQuestion();

      expect(controller.state.currentIndex, indexBefore + 1);
      expect(controller.state.hasAnswered, false);
      expect(controller.state.selectedIndex, isNull);
      expect(controller.state.isCorrect, isNull);
    });

    test('#10 nextQuestion 自动播放新题', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);
      audioService.playCalls.clear();
      audioService.stopCalls = 0;

      await controller.nextQuestion();

      final newWord = controller.state.currentQuestion!.correctWord.word;
      expect(audioService.stopCalls, greaterThanOrEqualTo(1));
      expect(audioService.playCalls, [newWord]);
      expect(controller.state.lastPlayedWord, newWord);
    });

    test('未作答时 nextQuestion 无效', () async {
      final indexBefore = controller.state.currentIndex;

      await controller.nextQuestion();

      expect(controller.state.currentIndex, indexBefore);
    });

    test('最后一题 nextQuestion → isCompleted + 停止音频', () async {
      final totalQuestions = controller.state.questions.length;

      for (var i = 0; i < totalQuestions; i++) {
        final correctIndex = controller.state.currentQuestion!.correctIndex;
        await controller.selectOption(correctIndex);
        await controller.nextQuestion();
      }

      expect(controller.state.isCompleted, true);
      expect(controller.state.currentQuestion, isNull);
      // 完成时也调用 stop（doc 31 末态停止音频）
      expect(audioService.stopCalls, greaterThanOrEqualTo(1));
    });

    test('nextQuestion 不调用 UseCase（与选择题 Bug 10 一致）', () async {
      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);
      useCase.callCount = 0;

      await controller.nextQuestion();

      expect(useCase.callCount, 0);
    });
  });

  group('音频错误隔离（doc 32 #11 / doc 30 / Bug 11）', () {
    setUp(() async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      audioService.playException = Exception('TTS engine unavailable');
    });

    test('#11 播放失败不保存 Review（hasAudioError + useCase 未调用）', () async {
      await controller.startQuiz('test');

      expect(controller.state.hasAudioError, true);
      expect(controller.state.audioErrorMessage, isNotNull);
      expect(useCase.callCount, 0);
    });

    test('hasAudioError 时 selectOption 不保存', () async {
      await controller.startQuiz('test');
      // 播放失败状态
      expect(controller.state.hasAudioError, true);

      final correctIndex = controller.state.currentQuestion!.correctIndex;
      await controller.selectOption(correctIndex);

      expect(useCase.callCount, 0);
      expect(controller.state.hasAnswered, false);
    });

    test('replay 成功后清除 hasAudioError 恢复正常', () async {
      await controller.startQuiz('test');
      expect(controller.state.hasAudioError, true);

      // 修复播放
      audioService.playException = null;
      await controller.replay();

      expect(controller.state.hasAudioError, false);
      expect(controller.state.audioErrorMessage, isNull);
    });
  });

  group('dispose — 停止音频（doc 32 #12 / doc 31）', () {
    test('#12 dispose 停止音频', () async {
      for (final w in testWords) {
        reviewRepo.addDueReview(w.id);
      }
      await controller.startQuiz('test');
      final stopsBefore = audioService.stopCalls;

      await controller.dispose();

      expect(audioService.stopCalls, greaterThan(stopsBefore));
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
