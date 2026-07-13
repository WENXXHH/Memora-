//首页数据状态

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
