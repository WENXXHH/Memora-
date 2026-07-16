import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_state.dart';
import '../../../providers/repository_providers.dart';
import '../../../data/repositories/word_repository.dart';

// 首页数据控制器
class HomeController extends StateNotifier<HomeState> {
  final WordRepository _wordRepository;

  HomeController(this._wordRepository) : super(
    HomeState(
      reviewCount: 0,
      learnedCount: 0,
      totalWords: 0,
      masteredWords: 0,
      streakDays: 0,
      isLoading: true,
    ),
  );

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final totalWords = await _wordRepository.getWordCount('cet6');
      final dueReviews = await _wordRepository.getDueReviews('cet6');
      final reviewedCount = await _wordRepository.getReviewedCount('cet6');
      final masteredCount = await _wordRepository.getMasteredCount('cet6');
      
      state = state.copyWith(
        reviewCount: dueReviews.length,
        learnedCount: reviewedCount,
        totalWords: totalWords,
        masteredWords: masteredCount,
        streakDays: 0,
        isLoading: false,
      );
    } catch (e) {
      // 数据获取失败时降级为默认值
      print('[HomeController] loadData error: $e');
      state = state.copyWith(
        reviewCount: 0,
        learnedCount: 0,
        totalWords: 200,
        masteredWords: 0,
        streakDays: 0,
        isLoading: false,
      );
    }
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(
    ref.read(wordRepositoryProvider),
  ),
);
