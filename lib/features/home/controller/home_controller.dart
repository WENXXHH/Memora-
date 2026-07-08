import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int reviewCount;
  final int learnedCount;
  final int totalWords;
  final int masteredWords;
  final int streakDays;
  final bool isLoading;

  HomeState({
    required this.reviewCount,
    required this.learnedCount,
    required this.totalWords,
    required this.masteredWords,
    required this.streakDays,
    required this.isLoading,
  });

  HomeState copyWith({
    int? reviewCount,
    int? learnedCount,
    int? totalWords,
    int? masteredWords,
    int? streakDays,
    bool? isLoading,
  }) {
    return HomeState(
      reviewCount: reviewCount ?? this.reviewCount,
      learnedCount: learnedCount ?? this.learnedCount,
      totalWords: totalWords ?? this.totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

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