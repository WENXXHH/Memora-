import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_state.dart';

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(
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
    await Future.delayed(const Duration(milliseconds: 800));
    
    state = state.copyWith(
      reviewCount: 15,
      learnedCount: 5,
      totalWords: 200,
      masteredWords: 45,
      streakDays: 7,
      isLoading: false,
    );
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(),
);
