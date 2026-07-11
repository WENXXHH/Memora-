import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/learning_state.dart';
import '../../../providers/repository_providers.dart';
import '../../../data/repositories/word_repository.dart';

/// 学习状态管理控制器
/// 
/// 负责处理：
/// - 从仓库加载单词队列
/// - 显示/隐藏单词释义
/// - 处理用户反馈并跳转到下一个单词
/// - 重置学习会话
/// 
/// 注意：当前版本为简化版本。SM-2 算法将在后续集成。
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

  /// 开始学习会话
  /// [wordBookId]: 词书标识符（如 'cet6', 'cet4'）
  /// [mode]: 学习模式（默认为 newWord）
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

  /// 显示单词释义和例句
  void showAnswer() {
    state = state.copyWith(isShowingAnswer: true);
  }

  /// 处理用户反馈并跳转到下一个单词
  /// [type]: 反馈类型（known/fuzzy/unknown）
  /// 
  /// 注意：SM-2 算法将在第2周集成，用于计算复习间隔
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

  /// 重置学习状态到初始状态
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

/// Riverpod 提供者：LearningController（带 wordBookId 参数）
/// 
/// 使用方式：
/// ```dart
/// final state = ref.watch(learningControllerProvider('cet6'));
/// final controller = ref.read(learningControllerProvider('cet6').notifier);
/// ```
final learningControllerProvider = StateNotifierProvider.family<LearningController, LearningState, String>(
  (ref, wordBookId) => LearningController(
    ref.read(wordRepositoryProvider),
  ),
);
