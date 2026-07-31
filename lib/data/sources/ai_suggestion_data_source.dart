import '../../data/models/ai_suggestion_request.dart';

/// AI 助记内容数据源抽象接口
///
/// 定义从 AI 服务获取助记建议的标准契约。
/// 返回 Stream of String，每个事件是增量文本片段（不含此前已返回的内容）。
abstract interface class AiSuggestionDataSource {
  /// 生成助记建议
  ///
  /// [request] 包含单词、释义、例句和反馈类型
  /// 返回增量文本片段流，由上层累加显示
  Stream<String> generateSuggestion(AiSuggestionRequest request);
}
