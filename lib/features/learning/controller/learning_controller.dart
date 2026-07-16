import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/learning_state.dart';
import '../../../providers/repository_providers.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/models/word_review_model.dart';
import '../../../utils/sm2_algorithm.dart';
import '../../../data/models/word_model.dart';

/// 学习状态管理控制器
/// 
/// 负责处理：
/// - 从仓库加载单词队列（新词/复习模式）
/// - 显示/隐藏单词释义
/// - 处理用户反馈并调用 SM-2 算法更新复习状态
/// - 重置学习会话
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
      final allWords = await _wordRepository.getWords(wordBookId);
      
      List<Word> displayWords;
      if (mode == LearningMode.review) {
        // 复习模式：获取需要复习的单词
        final dueReviews = await _wordRepository.getDueReviews(wordBookId);
        final dueWordIds = dueReviews.map((r) => r.wordId).toSet();
        displayWords = allWords
            .where((w) => dueWordIds.contains(w.id))
            .take(10)
            .toList();
        
        // 如果没有待复习的单词，自动切换到新词学习
        if (displayWords.isEmpty) {
          displayWords = await _getUnlearnedWords(allWords, wordBookId);
        }
      } else {
        // 新词模式：过滤掉已学过的单词
        displayWords = await _getUnlearnedWords(allWords, wordBookId);
      }

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

  /// 获取未学过的单词（前20个）
  /// 只要有复习记录（不限到期时间），就从新词队列中排除
  Future<List<Word>> _getUnlearnedWords(List<Word> allWords, String wordBookId) async {
    final reviewedIds = await _wordRepository.getAllReviewIds(wordBookId);
    return allWords
        .where((w) => !reviewedIds.contains(w.id))
        .take(20)
        .toList();
  }

  /// 显示单词释义和例句
  void showAnswer() {
    state = state.copyWith(isShowingAnswer: true);
  }

  /// 处理用户反馈：集成 SM-2 算法更新复习状态
  /// [wordBookId]: 词书标识符
  /// [type]: 反馈类型（known/fuzzy/unknown）
  Future<void> handleFeedback(String wordBookId, FeedbackType type) async {
    if (state.currentWord == null) return;

    // 获取或创建复习状态
    var review = await _wordRepository.getWordReview(
      state.currentWord!.id,
      wordBookId,
    ) ?? WordReview.newReview(
      state.currentWord!.id,
      wordBookId,
    );

    // SM-2 算法更新
    final updatedReview = SM2Algorithm.updateReview(review, type);

    // 保存到内存缓存（内部自动打印日志）
    await _wordRepository.saveWordReview(updatedReview);

    // 跳转到下一个单词
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
