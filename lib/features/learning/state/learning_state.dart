import '../../../data/models/word_model.dart';

/// 用户对单词掌握程度的反馈类型
/// - known: 用户认识该单词
/// - fuzzy: 用户对单词记忆模糊
/// - unknown: 用户不认识该单词
enum FeedbackType {
  known,
  fuzzy,
  unknown,
}

/// 学习模式
/// - newWord: 学习新词（每次20个单词）
/// - review: 复习已学单词（每次10个单词）
enum LearningMode {
  newWord,
  review,
}

/// 学习状态类（不可变）
/// 
/// 字段说明：
/// - wordQueue: 当前学习会话的单词队列
/// - currentWord: 当前正在学习的单词
/// - currentIndex: 当前进度索引（从0开始）
/// - totalCount: 会话中单词总数
/// - isShowingAnswer: 是否显示释义和例句
/// - isLoading: 数据加载状态
/// - hasError: 是否发生错误
/// - errorMessage: 错误详情
/// - mode: 当前学习模式
class LearningState {
  final List<Word> wordQueue;
  final Word? currentWord;
  final int currentIndex;
  final int totalCount;
  final bool isShowingAnswer;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final LearningMode mode;

  LearningState({
    required this.wordQueue,
    required this.currentWord,
    required this.currentIndex,
    required this.totalCount,
    required this.isShowingAnswer,
    required this.isLoading,
    required this.hasError,
    required this.mode,
    this.errorMessage,
  });

  /// 创建一个副本，更新指定字段
  LearningState copyWith({
    List<Word>? wordQueue,
    Word? currentWord,
    int? currentIndex,
    int? totalCount,
    bool? isShowingAnswer,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    LearningMode? mode,
  }) {
    return LearningState(
      wordQueue: wordQueue ?? this.wordQueue,
      currentWord: currentWord ?? this.currentWord,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      isShowingAnswer: isShowingAnswer ?? this.isShowingAnswer,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
    );
  }
}
