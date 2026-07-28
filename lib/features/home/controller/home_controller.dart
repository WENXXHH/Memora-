import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_state.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/repositories/review_repository.dart';

// 首页数据控制器
class HomeController extends StateNotifier<HomeState> {
  final WordRepository _wordRepository;
  final ReviewRepository _reviewRepository;

  HomeController(this._wordRepository, this._reviewRepository) : super(
    HomeState(
      reviewCount: 0,
      learnedCount: 0,
      totalWords: 0,
      masteredWords: 0,
      streakDays: 0,
      isLoading: true,
    ),
  );

  //加载卡片数据
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final totalWords = await _wordRepository.getWordCount('cet6');
      final dueReviews = await _reviewRepository.getDueReviews('cet6');
      final reviewedCount = await _reviewRepository.getReviewedCount('cet6');
      final masteredCount = await _reviewRepository.getMasteredCount('cet6');
      
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
