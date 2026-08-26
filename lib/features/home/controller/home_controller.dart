import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_state.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/repositories/review_repository.dart';

/// 首页数据控制器
///
/// 负责加载指定词库的首页统计数据（复习数量、学习进度、掌握情况等）。
/// 由 family(wordBookId) 创建：每个词库一份独立状态，切换词库时页面
/// 自然 watch 新实例，CET-6 / CET-4 统计互不串扰（doc 24 / 26 / 40）。
/// 加载失败时标记错误状态，由 UI 层展示重试入口。
class HomeController extends StateNotifier<HomeState> {
  HomeController(this._wordBookId, this._wordRepository, this._reviewRepository)
    : super(
        HomeState(
          reviewCount: 0,
          learnedCount: 0,
          totalWords: 0,
          masteredWords: 0,
          streakDays: 0,
          isLoading: true,
        ),
      );

  final String _wordBookId;
  final WordRepository _wordRepository;
  final ReviewRepository _reviewRepository;

  /// 加载首页统计数据
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final totalWords = await _wordRepository.getWordCount(_wordBookId);
      final dueReviews = await _reviewRepository.getDueReviews(_wordBookId);
      final reviewedCount = await _reviewRepository.getReviewedCount(
        _wordBookId,
      );
      final masteredCount = await _reviewRepository.getMasteredCount(
        _wordBookId,
      );

      state = state.copyWith(
        reviewCount: dueReviews.length,
        learnedCount: reviewedCount,
        totalWords: totalWords,
        masteredWords: masteredCount,
        streakDays: 0,
        isLoading: false,
      );
    } catch (e) {
      // 数据获取失败时标记错误状态，由 UI 层展示重试入口
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
