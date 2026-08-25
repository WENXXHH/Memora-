import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/spelling_answer_matcher.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../../domain/use_cases/apply_review_feedback_use_case.dart';
import '../state/spelling_quiz_state.dart';

/// 拼写复习控制器。
///
/// 职责（doc §0 / §41）：
/// 1. 加载今日到期复习词作为拼写队列（取题口径与选择题 / 听音辨词一致，doc §14）
/// 2. 处理用户提交（每题只提交一次，Bug 3 防重复）
/// 3. SM-2 映射（doc §16）：拼写正确 → known，错误 → unknown
/// 4. 通过 [ApplyReviewFeedbackUseCase] 复用 SM-2 + Hive 保存链路（doc §18）
///
/// 答题流程（doc §15）：
/// ```
/// 用户提交 → 已作答则返回 → trim 为空则 inputError
/// → 判定对错 → 锁定 hasAnswered → UseCase 保存 → 更新统计 → 手动"下一题"
/// ```
class SpellingQuizController extends StateNotifier<SpellingQuizState> {
  SpellingQuizController(
    this._wordRepository,
    this._reviewRepository,
    this._useCase,
  ) : super(
         const SpellingQuizState(
           isLoading: true,
           hasError: false,
           words: [],
           currentIndex: 0,
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

  /// 当前词库标识（startQuiz 时设置，submitAnswer 时使用）。
  String? _wordBookId;

  /// 每次拼写会话最多单词数（与选择题 / 听音辨词保持一致）。
  static const int _maxQuestions = 10;

  /// 启动拼写复习会话。
  ///
  /// 取题口径与 [MultipleChoiceController.startQuiz] 完全一致（doc §14）：
  /// 今日到期复习词 → 过滤出词库中的单词 → 最多 [_maxQuestions] 个。
  /// 队列为空时置空队列 + isCompleted（页面走空状态分支，doc §12 / §30）。
  Future<void> startQuiz(String wordBookId) async {
    _wordBookId = wordBookId;
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final dueReviews = await _reviewRepository.getDueReviews(wordBookId);
      final dueWordIds = dueReviews.map((r) => r.wordId).toSet();

      final allWords = await _wordRepository.getWords(wordBookId);

      final words = allWords
          .where((w) => dueWordIds.contains(w.id))
          .take(_maxQuestions)
          .toList();

      if (words.isEmpty) {
        // 无到期复习词：空队列 + 完成态（页面显示"暂无需要拼写复习的单词"）
        state = state.copyWith(
          isLoading: false,
          hasError: false,
          words: [],
          currentIndex: 0,
          isCompleted: true,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        hasError: false,
        words: words,
        currentIndex: 0,
        hasAnswered: false,
        isCorrect: null,
        submittedAnswer: null,
        inputError: null,
        correctCount: 0,
        wrongCount: 0,
        hasSaveError: false,
        isCompleted: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 用户提交拼写答案。
  ///
  /// 防重复提交（Bug 3）：已作答时直接返回。
  /// 空输入校验（doc §8 / Bug 2）：trim 后为空 → inputError 提示，
  /// 不判定、不保存 SM-2、不推进题目（输入无效 ≠ 回答错误）。
  /// SM-2 映射（doc §16）：正确 → known，错误 → unknown。
  /// 保存失败（doc §19）：设置 hasSaveError，不改变答题真假。
  Future<void> submitAnswer(String input) async {
    // Bug 3：hasAnswered 立即检查，防止快速双击提交导致同一题保存两次
    if (state.hasAnswered) return;

    // Bug 2：空输入校验（trim 后为空 ≠ 答错，不更新 SM-2）
    if (SpellingAnswerMatcher.normalize(input).isEmpty) {
      state = state.copyWith(inputError: '请输入单词');
      return;
    }

    final word = state.currentWord;
    if (word == null) return;

    final isCorrect = SpellingAnswerMatcher.isCorrect(
      input: input,
      answer: word.word,
    );

    // Bug 3：立即设置 hasAnswered = true 锁定输入，并清除上次校验提示
    state = state.copyWith(
      hasAnswered: true,
      isCorrect: isCorrect,
      submittedAnswer: input,
      inputError: null,
    );

    // doc §16：拼写正确 → known（主动回忆，认知强度强于选择题的 fuzzy）
    final feedback = isCorrect ? FeedbackType.known : FeedbackType.unknown;

    // 调用 UseCase 保存到 Hive；保存失败不阻断答题，通过 hasSaveError 反馈
    bool saveFailed = false;
    try {
      await _useCase.execute(
        wordBookId: _wordBookId!,
        wordId: word.id,
        feedback: feedback,
      );
    } catch (_) {
      saveFailed = true;
    }

    // 更新统计 + 保存错误标志（用户答案有效，不受保存成败影响）
    state = state.copyWith(
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      wrongCount: !isCorrect ? state.wrongCount + 1 : state.wrongCount,
      hasSaveError: saveFailed,
    );
  }

  /// 跳到下一题（doc §21）。
  ///
  /// 必须已作答才能跳转（不自动跳题，答错后需时间看正确拼写）。
  /// Bug 4：nextQuestion 绝对不保存 SM-2，只推进状态并清理作答字段。
  void nextQuestion() {
    if (!state.hasAnswered) return; // 未作答时不允许跳转

    if (state.currentIndex < state.words.length - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        currentIndex: nextIndex,
        hasAnswered: false,
        isCorrect: null,
        submittedAnswer: null,
        hasSaveError: false,
        inputError: null,
      );
    } else {
      // 全部题目答完
      state = state.copyWith(isCompleted: true);
    }
  }

  /// 重置到初始状态。
  void reset() {
    state = const SpellingQuizState(
      isLoading: true,
      hasError: false,
      words: [],
      currentIndex: 0,
      hasAnswered: false,
      isCorrect: null,
      correctCount: 0,
      wrongCount: 0,
      isCompleted: false,
    );
  }
}
