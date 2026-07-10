import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/learning_state.dart';
import '../../../providers/repository_providers.dart';
import '../../../data/repositories/word_repository.dart';

/// Controller for learning state management
/// 
/// Handles:
/// - Loading word queue from repository
/// - Showing/hiding word definitions
/// - Processing user feedback and advancing to next word
/// - Resetting learning session
/// 
/// Note: Current version is simplified. SM-2 algorithm will be integrated later.
class LearningController extends StateNotifier<LearningState> {
  final WordRepository _wordRepository;

  LearningController(this._wordRepository) : super(
    LearningState(
      wordQueue: [],
      currentWord: null,
      currentIndex: 0,
      totalCount: 0,
      isShowingAnswer: false,
      isLoading: true,
      hasError: false,
      mode: LearningMode.newWord,
    ),
  );

  /// Start learning session
  /// [wordBookId]: word book identifier (e.g., 'cet6', 'cet4')
  /// [mode]: learning mode (default: newWord)
  Future<void> startLearning(String wordBookId, {LearningMode mode = LearningMode.newWord}) async {
    state = state.copyWith(isLoading: true, hasError: false, mode: mode);

    try {
      final words = await _wordRepository.getWords(wordBookId);
      
      final displayWords = mode == LearningMode.newWord 
          ? words.take(20).toList() 
          : words.take(10).toList();

      state = state.copyWith(
        wordQueue: displayWords,
        currentWord: displayWords.isNotEmpty ? displayWords.first : null,
        currentIndex: 0,
        totalCount: displayWords.length,
        isShowingAnswer: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Show word definition and examples
  void showAnswer() {
    state = state.copyWith(isShowingAnswer: true);
  }

  /// Process user feedback and advance to next word
  /// [type]: feedback type (known/fuzzy/unknown)
  /// 
  /// Note: SM-2 algorithm will be integrated in Week 2 to calculate review intervals
  void handleFeedback(FeedbackType type) {
    if (state.currentWord == null) return;

    if (state.currentIndex < state.totalCount - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        currentIndex: nextIndex,
        currentWord: state.wordQueue[nextIndex],
        isShowingAnswer: false,
      );
    } else {
      state = state.copyWith(
        currentWord: null,
        isShowingAnswer: false,
      );
    }
  }

  /// Reset learning state to initial
  void reset() {
    state = state.copyWith(
      currentWord: null,
      currentIndex: 0,
      totalCount: 0,
      isShowingAnswer: false,
      isLoading: true,
      hasError: false,
    );
  }
}

/// Riverpod provider for LearningController (with wordBookId parameter)
/// 
/// Usage:
/// ```dart
/// final state = ref.watch(learningControllerProvider('cet6'));
/// final controller = ref.read(learningControllerProvider('cet6').notifier);
/// ```
final learningControllerProvider = StateNotifierProvider.family<LearningController, LearningState, String>(
  (ref, wordBookId) => LearningController(
    ref.read(wordRepositoryProvider),
  ),
);