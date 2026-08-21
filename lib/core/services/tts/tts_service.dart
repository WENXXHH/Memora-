/// TTS（文本转语音）服务抽象接口
///
/// 定义了单词发音的核心能力，不与任何平台插件直接耦合。
/// 页面和 Controller 只依赖此接口，不直接依赖 flutter_tts。
abstract interface class TtsService {
  /// 初始化 TTS 引擎（设置语言、语速等默认参数）
  Future<void> initialize();

  /// 朗读指定文本
  ///
  /// [text] 不能为空字符串
  /// 如果当前正在朗读，会先停止再重新开始
  Future<void> speak(String text);

  /// 停止当前朗读
  Future<void> stop();

  /// 检查指定语言是否可用
  Future<bool> isLanguageAvailable(String language);
}
