import '../../../data/models/word_model.dart';

/// Feedback type for user's word mastery
/// - known: user knows the word
/// - fuzzy: user is uncertain about the word
/// - unknown: user doesn't know the word
enum FeedbackType {
  known,
  fuzzy,
  unknown,
}

/// Learning mode
/// - newWord: learn new words (20 words per session)
/// - review: review learned words (10 words per session)
enum LearningMode {
  newWord,
  review,
}

/// Learning state class (immutable)
/// 
/// Fields:
/// - wordQueue: list of words for current session
/// - currentWord: the word being studied
/// - currentIndex: progress index (0-based)
/// - totalCount: total words in session
/// - isShowingAnswer: whether to show definition/example
/// - isLoading: data loading status
/// - hasError: whether an error occurred
/// - errorMessage: error details
/// - mode: current learning mode
class LearningState {
  final List<Word> wordQueue;
  final Word? currentWord;
  final int currentIndex;
  final int totalCount;
  final bool isShowingAnswer;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final LearningMode mode;

  LearningState({
    required this.wordQueue,
    required this.currentWord,
    required this.currentIndex,
    required this.totalCount,
    required this.isShowingAnswer,
    required this.isLoading,
    required this.hasError,
    required this.mode,
    this.errorMessage,
  });

  /// Create a copy with updated fields
  LearningState copyWith({
    List<Word>? wordQueue,
    Word? currentWord,
    int? currentIndex,
    int? totalCount,
    bool? isShowingAnswer,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    LearningMode? mode,
  }) {
    return LearningState(
      wordQueue: wordQueue ?? this.wordQueue,
      currentWord: currentWord ?? this.currentWord,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      isShowingAnswer: isShowingAnswer ?? this.isShowingAnswer,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
    );
  }
}