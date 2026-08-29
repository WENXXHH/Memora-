import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/listening_audio/listening_audio_service.dart';
import '../../../core/utils/question_generator.dart';
import '../../../data/dto/multiple_choice_question.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../../domain/use_cases/apply_review_feedback_use_case.dart';
import '../state/listening_quiz_state.dart';

/// 听音辨词控制器（doc 26 / 27 / 28 / 29 / 30 / 31）。
///
/// 设计要点（doc 6 原则 19：Controller 不依赖另一个 Controller）：
/// - 不调用 [MultipleChoiceController]，只复用其下层组件
///   [QuestionGenerator] 和 [ApplyReviewFeedbackUseCase]
/// - 复用同一套 SM-2 + Hive，听对→fuzzy，听错→unknown（doc 21）
///
/// 音频生命周期：
/// - [startQuiz]：生成题目后自动播放第一题（doc 27：不能写在 build）
/// - [nextQuestion]：先 stop 上一题，再推进，再播放下一题（doc 28）
/// - [replay]：先 stop 再播放当前词，不推进 currentIndex（doc 29）
/// - [dispose]：停止音频（doc 31：页面退出必须停止）
///
/// 音频错误隔离（doc 30 / Bug 11）：
/// - play 抛异常 → hasAudioError=true，显示"播放失败，请重试"
/// - 绝不因此调用 unknown / 保存 SM-2 / 跳下一题 / 改变正确率
class ListeningQuizController extends StateNotifier<ListeningQuizState> {
  ListeningQuizController(
    this._wordRepository,
    this._reviewRepository,
    this._useCase,
    this._audioService, {
    QuestionGenerator? questionGenerator,
  }) : _questionGenerator = questionGenerator ?? QuestionGenerator(Random()),
       super(
         const ListeningQuizState(
           isLoading: true,
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
         ),
       );

  final WordRepository _wordRepository;
  final ReviewRepository _reviewRepository;
  final ApplyReviewFeedbackUseCase _useCase;
  final ListeningAudioService _audioService;
  final QuestionGenerator _questionGenerator;

  /// 当前词库标识（startQuiz 时设置，selectOption 时使用）。
  String? _wordBookId;

  /// 每次听音辨词会话最多题数（与选择题保持一致）。
  static const int _maxQuestions = 10;

  /// 启动听音辨词会话（doc 26）。
  ///
  /// 流程：
  /// 1. 获取今日到期复习词（题目来源）
  /// 2. 获取词库全部单词（干扰项来源）
  /// 3. 为每个复习词生成一道题（复用 QuestionGenerator）
  /// 4. 设置第一题为当前题
  /// 5. 自动播放第一题音频（doc 27：不能写在 build）
  Future<void> startQuiz(String wordBookId) async {
    _wordBookId = wordBookId;
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final dueReviews = await _reviewRepository.getDueReviews(wordBookId);
      final dueWordIds = dueReviews.map((r) => r.wordId).toSet();

      final allWords = await _wordRepository.getWords(wordBookId);

      final dueWords = allWords
          .where((w) => dueWordIds.contains(w.id))
          .take(_maxQuestions)
          .toList();

      final questions = <MultipleChoiceQuestion>[];
      for (final word in dueWords) {
        final question = _questionGenerator.build(
          correctWord: word,
          allWords: allWords,
        );
        if (question != null) {
          questions.add(question);
        }
      }

      if (questions.isEmpty) {
        // 无题可生成：区分"词库太小"与"暂无到期复习词"（doc 53）。
        // 与选择题同一产品规则：唯一释义 < 4 时无法生成四选一。
        final enough =
            _questionGenerator.uniqueMeaningCount(allWords) >=
            QuestionGenerator.optionCount;
        state = state.copyWith(
          isLoading: false,
          questions: [],
          currentIndex: 0,
          currentQuestion: null,
          isCompleted: true,
          errorMessage: enough
              ? null
              : '至少需要 ${QuestionGenerator.optionCount} 个不同释义的单词才能进行听音辨词',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        questions: questions,
        currentIndex: 0,
        currentQuestion: questions.first,
        selectedIndex: null,
        hasAnswered: false,
        isCorrect: null,
        correctCount: 0,
        wrongCount: 0,
        isCompleted: false,
      );

      // 自动播放第一题（doc 27）
      await _playCurrentWord();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 用户选择某个选项（doc 30：音频错误时不保存 SM-2）。
  ///
  /// 防重复提交：已作答时直接返回（Bug 9/10）。
  /// SM-2 映射（doc 21）：正确→fuzzy，错误→unknown。
  Future<void> selectOption(int index) async {
    if (state.hasAnswered) return;

    final question = state.currentQuestion;
    if (question == null) return;

    // Bug 11：音频错误时不允许保存（与"答错"完全不同的事件）
    if (state.hasAudioError) return;

    final isCorrect = index == question.correctIndex;

    state = state.copyWith(
      selectedIndex: index,
      hasAnswered: true,
      isCorrect: isCorrect,
    );

    final feedback = isCorrect ? FeedbackType.fuzzy : FeedbackType.unknown;

    bool saveFailed = false;
    try {
      await _useCase.execute(
        wordBookId: _wordBookId!,
        wordId: question.correctWord.id,
        feedback: feedback,
      );
    } catch (_) {
      saveFailed = true;
    }

    state = state.copyWith(
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      wrongCount: !isCorrect ? state.wrongCount + 1 : state.wrongCount,
      hasSaveError: saveFailed,
    );
  }

  /// 跳到下一题（doc 28）。
  ///
  /// 必须已作答才能跳转（约束 19）。
  /// 流程：stop 上一题 → 推进 → 清作答状态 → 播放下一题。
  Future<void> nextQuestion() async {
    if (!state.hasAnswered) return;

    if (state.currentIndex < state.questions.length - 1) {
      // 先停止上一题音频，防止叠音（doc 28 / Bug 9）
      await _audioService.stop();

      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        currentIndex: nextIndex,
        currentQuestion: state.questions[nextIndex],
        selectedIndex: null,
        hasAnswered: false,
        isCorrect: null,
        hasSaveError: false,
        hasAudioError: false,
        audioErrorMessage: null,
      );

      // 自动播放下一题（doc 28）
      await _playCurrentWord();
    } else {
      // 最后一题答完 → 进入成绩页，停止音频
      await _audioService.stop();
      state = state.copyWith(currentQuestion: null, isCompleted: true);
    }
  }

  /// 重新播放当前题音频（doc 29）。
  ///
  /// 流程：stop → play(currentWord.word)，不推进 currentIndex。
  /// 连续快速点击时旧音频必须停止，防止叠音（Bug 9）。
  Future<void> replay() async {
    await _audioService.stop();
    // 清除上一次的播放错误状态，允许重新尝试
    if (state.hasAudioError) {
      state = state.copyWith(hasAudioError: false, audioErrorMessage: null);
    }
    await _playCurrentWord();
  }

  /// 播放当前题对应的英文单词。
  ///
  /// 失败时设置 hasAudioError，不抛出，不调用 SM-2（doc 30）。
  /// 成功时更新 lastPlayedWord 供 UI 显示 debug 文本（doc 22）。
  Future<void> _playCurrentWord() async {
    final question = state.currentQuestion;
    if (question == null) return;

    final word = question.correctWord.word;

    state = state.copyWith(
      isPlaying: true,
      hasAudioError: false,
      audioErrorMessage: null,
      lastPlayedWord: word,
    );

    try {
      await _audioService.play(word);
      // 播放完成（Fake 是同步完成；TTS 真实场景由 speak 的 Future 决定）
      if (state.isPlaying) {
        state = state.copyWith(isPlaying: false);
      }
    } catch (e) {
      // doc 30：播放失败只设置错误标志，不保存 SM-2
      state = state.copyWith(
        isPlaying: false,
        hasAudioError: true,
        audioErrorMessage: '播放失败，请重试',
      );
    }
  }

  /// 重置到初始状态。
  Future<void> reset() async {
    await _audioService.stop();
    state = const ListeningQuizState(
      isLoading: true,
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
  }

  @override
  Future<void> dispose() async {
    // doc 31：页面退出必须停止音频
    await _audioService.stop();
    super.dispose();
  }
}
