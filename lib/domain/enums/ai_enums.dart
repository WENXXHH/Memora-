/// AI 助记内容生成状态枚举
///
/// - idle：初始状态，尚未请求生成
/// - loading：请求已发出，等待首个文本块返回
/// - streaming：正在逐块接收并显示文本
/// - success：流式输出正常完成
/// - error：生成过程出错
enum AiSuggestionStatus {
  idle,
  loading,
  streaming,
  success,
  error,
}
