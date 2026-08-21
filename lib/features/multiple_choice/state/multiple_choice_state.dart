import '../../../data/dto/multiple_choice_question.dart';

/// 选择题状态类（不可变）。
///
/// 字段说明（§2.5 + §3.7 isSubmitting 简化）：
/// - [isLoading]：题目加载中
/// - [hasError] / [errorMessage]：加载失败
/// - [questions]：本次会话的全部题目
/// - [currentIndex]：当前题号（0-based）
/// - [currentQuestion]：当前题目（完成后为 null）
/// - [selectedIndex]：用户选中的选项索引（未作答为 null）
/// - [hasAnswered]：当前题是否已作答（Bug 9/10 防重复提交）
/// - [isCorrect]：本次作答是否正确（未作答为 null）
/// - [correctCount] / [wrongCount]：累计统计
/// - [isCompleted]：全部题目答完
/// - [hasSaveError]：SM-2 保存是否失败（第五天：保存失败反馈）
///
/// 状态不变量：
/// ```
/// 未作答：selectedIndex == null && hasAnswered == false
/// 已作答：selectedIndex != null && hasAnswered == true && isCorrect != null
/// 完成：currentIndex >= questions.length && isCompleted == true
/// ```
class MultipleChoiceState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<MultipleChoiceQuestion> questions;
  final int currentIndex;
  final MultipleChoiceQuestion? currentQuestion;
  final int? selectedIndex;
  final bool hasAnswered;
  final bool? isCorrect;
  final int correctCount;
  final int wrongCount;
  final bool isCompleted;
  final bool hasSaveError;

  const MultipleChoiceState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.questions,
    required this.currentIndex,
    required this.currentQuestion,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.isCorrect,
    required this.correctCount,
    required this.wrongCount,
    required this.isCompleted,
    this.hasSaveError = false,
  });

  /// 创建一个副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"和"显式传 null"，
  /// 参考 [learning_state.dart] 的实现方式（约束 21）。
  MultipleChoiceState copyWith({
    bool? isLoading,
    bool? hasError,
    Object? errorMessage = _sentinel,
    List<MultipleChoiceQuestion>? questions,
    int? currentIndex,
    Object? currentQuestion = _sentinel,
    Object? selectedIndex = _sentinel,
    bool? hasAnswered,
    Object? isCorrect = _sentinel,
    int? correctCount,
    int? wrongCount,
    bool? isCompleted,
    bool? hasSaveError,
  }) {
    return MultipleChoiceState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      currentQuestion: identical(currentQuestion, _sentinel)
          ? this.currentQuestion
          : currentQuestion as MultipleChoiceQuestion?,
      selectedIndex: identical(selectedIndex, _sentinel)
          ? this.selectedIndex
          : selectedIndex as int?,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      isCorrect: identical(isCorrect, _sentinel)
          ? this.isCorrect
          : isCorrect as bool?,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isCompleted: isCompleted ?? this.isCompleted,
      hasSaveError: hasSaveError ?? this.hasSaveError,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"
const Object _sentinel = Object();
