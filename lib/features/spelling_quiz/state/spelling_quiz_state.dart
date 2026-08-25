import '../../../data/dto/word_model.dart';

/// 拼写复习状态类（不可变）。
///
/// 字段说明（doc §9，按修订版补充 hasError / inputError）：
/// - [isLoading]：题目加载中
/// - [hasError] / [errorMessage]：加载失败
/// - [words]：本次会话的全部待拼写单词
/// - [currentIndex]：当前题号（0-based）
/// - [currentWord]：当前单词（getter，越界返回 null，不单独存储）
/// - [hasAnswered]：当前题是否已提交（Bug 3 防重复提交）
/// - [isCorrect]：本次作答是否正确（未作答为 null）
/// - [submittedAnswer]：用户提交的英文答案（答错时用于展示）
/// - [correctCount] / [wrongCount]：累计统计
/// - [isCompleted]：全部题目完成
/// - [hasSaveError]：SM-2 保存是否失败（与答题对错无关，doc §19）
/// - [inputError]：空输入校验提示（"请输入单词"，doc §8）
///
/// 状态不变量：
/// ```
/// 未作答：hasAnswered == false && isCorrect == null
/// 已作答：hasAnswered == true && isCorrect != null
/// 完成：isCompleted == true（currentIndex 停留在最后一题，words 不置空）
/// ```
class SpellingQuizState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<Word> words;
  final int currentIndex;
  final bool hasAnswered;
  final bool? isCorrect;
  final String? submittedAnswer;
  final int correctCount;
  final int wrongCount;
  final bool isCompleted;
  final bool hasSaveError;
  final String? inputError;

  const SpellingQuizState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.words,
    required this.currentIndex,
    required this.hasAnswered,
    required this.isCorrect,
    this.submittedAnswer,
    required this.correctCount,
    required this.wrongCount,
    required this.isCompleted,
    this.hasSaveError = false,
    this.inputError,
  });

  /// 当前单词。
  ///
  /// 作为 getter 而非独立字段，避免 words + currentIndex 之外的第二事实
  /// 来源（doc §12）；越界时返回 null（防御，页面分支不要依赖它判断完成）。
  Word? get currentWord {
    if (currentIndex < 0 || currentIndex >= words.length) {
      return null;
    }
    return words[currentIndex];
  }

  /// 创建副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"与"显式传 null"（约束 21，
  /// 与 [MultipleChoiceState] / [ListeningQuizState] 保持一致）。
  SpellingQuizState copyWith({
    bool? isLoading,
    bool? hasError,
    Object? errorMessage = _sentinel,
    List<Word>? words,
    int? currentIndex,
    bool? hasAnswered,
    Object? isCorrect = _sentinel,
    Object? submittedAnswer = _sentinel,
    int? correctCount,
    int? wrongCount,
    bool? isCompleted,
    bool? hasSaveError,
    Object? inputError = _sentinel,
  }) {
    return SpellingQuizState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      isCorrect: identical(isCorrect, _sentinel)
          ? this.isCorrect
          : isCorrect as bool?,
      submittedAnswer: identical(submittedAnswer, _sentinel)
          ? this.submittedAnswer
          : submittedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isCompleted: isCompleted ?? this.isCompleted,
      hasSaveError: hasSaveError ?? this.hasSaveError,
      inputError: identical(inputError, _sentinel)
          ? this.inputError
          : inputError as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"。
const Object _sentinel = Object();
