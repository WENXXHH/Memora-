import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/question_generator.dart';
import '../../../data/dto/multiple_choice_question.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../../domain/use_cases/apply_review_feedback_use_case.dart';
import '../state/multiple_choice_state.dart';

/// 选择题控制器。
///
/// 职责：
/// 1. 加载今日到期复习词 → 生成四选一题目
/// 2. 处理用户选项点击（每题只提交一次，Bug 9/10 防御）
/// 3. SM-2 映射：正确→fuzzy，错误→unknown（约束 16 / Bug 11）
/// 4. 通过 [ApplyReviewFeedbackUseCase] 复用反馈保存逻辑（原则 16）
///
/// 答题流程（§2.5 文档 17）：
/// ```
/// 用户点击选项 → 已回答则直接返回 → 记录选中 → 判断对错
/// → 锁定选项 → UseCase 保存 → 更新统计 → 显示颜色 → 等"下一题"
/// ```
class MultipleChoiceController extends StateNotifier<MultipleChoiceState> {
  MultipleChoiceController(
    this._wordRepository,
    this._reviewRepository,
    this._useCase, {
    QuestionGenerator? questionGenerator,
  }) : _questionGenerator = questionGenerator ?? QuestionGenerator(Random()),
       super(
         const MultipleChoiceState(
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
  final QuestionGenerator _questionGenerator;

  /// 当前词库标识（startQuiz 时设置，selectOption 时使用）。
  String? _wordBookId;

  /// 每次选择题会话最多题数。
  static const int _maxQuestions = 10;

  /// 启动选择题会话。
  ///
  /// 流程：
  /// 1. 获取今日到期复习词（题目来源）
  /// 2. 获取词库全部单词（干扰项来源）
  /// 3. 为每个复习词生成一道题（过滤不足 4 个释义的词）
  /// 4. 最多取 [_maxQuestions] 道题
  Future<void> startQuiz(String wordBookId) async {
    _wordBookId = wordBookId;
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      // 题目来源：今日到期复习词
      final dueReviews = await _reviewRepository.getDueReviews(wordBookId);
      final dueWordIds = dueReviews.map((r) => r.wordId).toSet();

      // 干扰项来源：当前词库全部单词
      final allWords = await _wordRepository.getWords(wordBookId);

      // 筛选待复习的单词（保持顺序）
      final dueWords = allWords
          .where((w) => dueWordIds.contains(w.id))
          .take(_maxQuestions)
          .toList();

      // 为每个待复习词生成题目
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
        // 没有可生成的题目（词库太小或无到期复习词）
        state = state.copyWith(
          isLoading: false,
          questions: [],
          currentIndex: 0,
          currentQuestion: null,
          isCompleted: true,
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 用户选择某个选项。
  ///
  /// 防重复提交（Bug 9/10）：已作答时直接返回。
  /// SM-2 映射（约束 16）：正确→fuzzy，错误→unknown。
  /// 保存失败（第五天）：设置 hasSaveError，不阻断答题流程。
  Future<void> selectOption(int index) async {
    // Bug 9：hasAnswered 立即检查，防止重复提交
    if (state.hasAnswered) return;

    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = index == question.correctIndex;

    // Bug 9：立即设置 hasAnswered = true，锁定全部选项
    state = state.copyWith(
      selectedIndex: index,
      hasAnswered: true,
      isCorrect: isCorrect,
    );

    // Bug 11 / 约束 16：正确→fuzzy（不是 known），错误→unknown
    final feedback = isCorrect ? FeedbackType.fuzzy : FeedbackType.unknown;

    // 调用 UseCase 保存到 Hive（本地写入毫秒级，不显示 isSubmitting）
    // 保存失败不阻断答题流程，通过 hasSaveError 通知 UI 展示反馈
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

    // 更新统计 + 保存错误标志（用户答案有效，不受保存成败影响）
    state = state.copyWith(
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      wrongCount: !isCorrect ? state.wrongCount + 1 : state.wrongCount,
      hasSaveError: saveFailed,
    );
  }

  /// 跳到下一题。
  ///
  /// 必须已作答才能跳转（约束 19：用"下一题"按钮，不自动跳转）。
  /// Bug 10：下一题按钮不再保存 SM-2，只推进题目。
  void nextQuestion() {
    if (!state.hasAnswered) return; // 未作答时不允许跳转

    if (state.currentIndex < state.questions.length - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        currentIndex: nextIndex,
        currentQuestion: state.questions[nextIndex],
        selectedIndex: null,
        hasAnswered: false,
        isCorrect: null,
        hasSaveError: false,
      );
    } else {
      // 全部题目答完
      state = state.copyWith(currentQuestion: null, isCompleted: true);
    }
  }

  /// 重置到初始状态。
  void reset() {
    state = const MultipleChoiceState(
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
}
