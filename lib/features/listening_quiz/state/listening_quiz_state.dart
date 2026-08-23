import '../../../data/dto/multiple_choice_question.dart';

/// 听音辨词状态类（不可变，doc 25）。
///
/// 与选择题相比，复用 [MultipleChoiceQuestion] 题目模型，但状态
/// 新增三个音频相关字段以承载播放状态机（doc 27/28/29/30）：
/// - [isPlaying]：当前是否正在播放（驱动 UI 显示 loading 指示）
/// - [hasAudioError]：播放是否失败（doc 30：与答题错误必须区分）
/// - [lastPlayedWord]：最后播放的单词文本（第 4 天 UI debug 文本 ♪ 用）
///
/// 状态不变量：
/// ```
/// 未作答：selectedIndex == null && hasAnswered == false
/// 已作答：selectedIndex != null && hasAnswered == true && isCorrect != null
/// 完成：currentIndex >= questions.length && isCompleted == true
/// ```
///
/// 音频错误不变量（doc 30 / Bug 11）：
/// `hasAudioError == true` 时不允许保存 SM-2，由 Controller 强制
/// 在 selectOption 首行检查 isPlaying 正常 / hasAudioError == false。
class ListeningQuizState {
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

  /// 当前是否正在播放音频（doc 27）。
  final bool isPlaying;

  /// 音频播放是否失败（doc 30：播放失败不能修改 SM-2）。
  final bool hasAudioError;

  /// 最后一次播放的英文单词文本（doc 22：第 4 天 UI debug 用）。
  final String? lastPlayedWord;

  /// 播放失败的提示信息。
  final String? audioErrorMessage;

  const ListeningQuizState({
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
    this.isPlaying = false,
    this.hasAudioError = false,
    this.lastPlayedWord,
    this.audioErrorMessage,
  });

  /// 创建副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"与"显式传 null"
  /// （与 [MultipleChoiceState] 保持一致，约束 21）。
  ListeningQuizState copyWith({
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
    bool? isPlaying,
    bool? hasAudioError,
    Object? lastPlayedWord = _sentinel,
    Object? audioErrorMessage = _sentinel,
  }) {
    return ListeningQuizState(
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
      isPlaying: isPlaying ?? this.isPlaying,
      hasAudioError: hasAudioError ?? this.hasAudioError,
      lastPlayedWord: identical(lastPlayedWord, _sentinel)
          ? this.lastPlayedWord
          : lastPlayedWord as String?,
      audioErrorMessage: identical(audioErrorMessage, _sentinel)
          ? this.audioErrorMessage
          : audioErrorMessage as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"。
const Object _sentinel = Object();
