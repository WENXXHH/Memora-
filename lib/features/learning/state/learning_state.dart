import '../../../data/dto/word_model.dart';
import '../../../domain/enums/learning_enums.dart';

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
  ///
  /// 使用 sentinel 模式区分"未传参"和"显式传 null"，
  /// 避免 Dart `??` 将 null 回退为旧值的问题。
  LearningState copyWith({
    List<Word>? wordQueue,
    Object? currentWord = _sentinel,
    int? currentIndex,
    int? totalCount,
    bool? isShowingAnswer,
    bool? isLoading,
    bool? hasError,
    Object? errorMessage = _sentinel,
    LearningMode? mode,
  }) {
    return LearningState(
      wordQueue: wordQueue ?? this.wordQueue,
      currentWord: identical(currentWord, _sentinel)
          ? this.currentWord
          : currentWord as Word?,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      isShowingAnswer: isShowingAnswer ?? this.isShowingAnswer,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      mode: mode ?? this.mode,
    );
  }
}

/// sentinel 值用于 copyWith 区分"未传参"与"显式传 null"
const Object _sentinel = Object();
