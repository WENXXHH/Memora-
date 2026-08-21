import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/learning_state.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/dto/word_model.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../../domain/use_cases/apply_review_feedback_use_case.dart';

/// 学习状态管理控制器
///
/// 负责处理：
/// - 从仓库加载单词队列（新词/复习模式）
/// - 显示/隐藏单词释义
/// - 处理用户反馈并调用共享 [ApplyReviewFeedbackUseCase] 更新复习状态
/// - 重置学习会话
class LearningController extends StateNotifier<LearningState> {
  final WordRepository _wordRepository;
  final ReviewRepository _reviewRepository;
  final ApplyReviewFeedbackUseCase _useCase;

  LearningController(
    this._wordRepository,
    this._reviewRepository,
    this._useCase,
  ) : super(
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
  Future<void> startLearning(
    String wordBookId, {
    LearningMode mode = LearningMode.newWord,
  }) async {
    state = state.copyWith(isLoading: true, hasError: false, mode: mode);

    try {
      final allWords = await _wordRepository.getWords(wordBookId);

      List<Word> displayWords;
      if (mode == LearningMode.review) {
        // 复习模式：获取需要复习的单词
        final dueReviews = await _reviewRepository.getDueReviews(wordBookId);
        final dueWordIds = dueReviews.map((r) => r.wordId).toSet();
        displayWords = allWords
            .where((w) => dueWordIds.contains(w.id))
            .take(10)
            .toList();
        // 没有待复习单词时直接返回空队列，由页面层展示提示信息
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
  Future<List<Word>> _getUnlearnedWords(
    List<Word> allWords,
    String wordBookId,
  ) async {
    final reviewedIds = await _reviewRepository.getAllReviewIds(wordBookId);
    return allWords.where((w) => !reviewedIds.contains(w.id)).take(20).toList();
  }

  /// 显示单词释义和例句
  void showAnswer() {
    state = state.copyWith(isShowingAnswer: true);
  }

  /// 处理用户反馈：通过共享 [ApplyReviewFeedbackUseCase] 更新复习状态
  /// [wordBookId]: 词书标识符
  /// [type]: 反馈类型（known/fuzzy/unknown）
  /// [onCompleted]: 学习完成时的回调（可选，由页面层注入）
  Future<void> handleFeedback(
    String wordBookId,
    FeedbackType type, {
    VoidCallback? onCompleted,
  }) async {
    if (state.currentWord == null) return;

    // 原则 16：复用共享 UseCase（获取/创建 → SM-2 更新 → 保存）
    await _useCase.execute(
      wordBookId: wordBookId,
      wordId: state.currentWord!.id,
      feedback: type,
    );

    // 跳转到下一个单词
    if (state.currentIndex < state.totalCount - 1) {
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        currentIndex: nextIndex,
        currentWord: state.wordQueue[nextIndex],
        isShowingAnswer: false,
      );
    } else {
      state = state.copyWith(currentWord: null, isShowingAnswer: false);
      onCompleted?.call();
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
