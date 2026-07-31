import '../../../domain/enums/ai_enums.dart';

/// AI 助记生成状态
///
/// 五种状态对应的字段约定：
/// - idle：text 为空，errorMessage 为空
/// - loading：text 为空，等待首个片段
/// - streaming：text 逐块累加中
/// - success：text 包含完整助记内容
/// - error：errorMessage 包含错误描述
class AiSuggestionState {
  final AiSuggestionStatus status;
  final String text;
  final String? errorMessage;

  const AiSuggestionState({
    this.status = AiSuggestionStatus.idle,
    this.text = '',
    this.errorMessage,
  });

  AiSuggestionState copyWith({
    AiSuggestionStatus? status,
    String? text,
    String? errorMessage,
  }) {
    return AiSuggestionState(
      status: status ?? this.status,
      text: text ?? this.text,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
