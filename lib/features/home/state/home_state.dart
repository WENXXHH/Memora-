/// 首页数据状态
///
/// 支持四种 UI 状态：
/// - 加载中：isLoading = true
/// - 正常有数据：isLoading = false, hasError = false, reviewCount > 0
/// - 空数据（首次启动）：isLoading = false, hasError = false, reviewCount = 0
/// - 错误：isLoading = false, hasError = true
class HomeState {
  final int reviewCount;
  final int learnedCount;
  final int totalWords;
  final int masteredWords;
  final int streakDays;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  HomeState({
    required this.reviewCount,
    required this.learnedCount,
    required this.totalWords,
    required this.masteredWords,
    required this.streakDays,
    required this.isLoading,
    this.hasError = false,
    this.errorMessage,
  });

  HomeState copyWith({
    int? reviewCount,
    int? learnedCount,
    int? totalWords,
    int? masteredWords,
    int? streakDays,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return HomeState(
      reviewCount: reviewCount ?? this.reviewCount,
      learnedCount: learnedCount ?? this.learnedCount,
      totalWords: totalWords ?? this.totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
