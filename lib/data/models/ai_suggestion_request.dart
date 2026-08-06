import '../../../domain/enums/learning_enums.dart';

/// AI 助记生成请求模型
///
/// 封装生成 AI 助记所需的所有上下文信息，
/// 在各层之间传递，避免参数散落。
class AiSuggestionRequest {
  /// 目标单词
  final String word;

  /// 中文释义（取第一个词性的第一条释义）
  final String meaning;

  /// 例句（取第一条例句）
  final String example;

  /// 用户反馈类型（不认识/模糊/认识）
  final FeedbackType feedbackType;

  const AiSuggestionRequest({
    required this.word,
    required this.meaning,
    required this.example,
    required this.feedbackType,
  });
}
