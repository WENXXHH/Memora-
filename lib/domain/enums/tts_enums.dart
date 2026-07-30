/// TTS 播放状态枚举
///
/// 用于标识单词发音的当前播放状态：
/// - idle：未在播放，可接受新的朗读请求
/// - speaking：正在朗读中
/// - error：朗读失败
enum TtsStatus {
  idle,
  speaking,
  error,
}
