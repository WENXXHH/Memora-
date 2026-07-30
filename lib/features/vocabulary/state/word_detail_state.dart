import '../../../domain/enums/tts_enums.dart';

/// 单词详情页 TTS 发音状态
///
/// 支持三种状态：
/// - idle：就绪，可点击播放
/// - speaking：正在朗读中（按钮高亮）
/// - error：播放失败（显示错误信息）
class TtsState {
  final TtsStatus status;
  final String? errorMessage;

  const TtsState({
    this.status = TtsStatus.idle,
    this.errorMessage,
  });

  TtsState copyWith({
    TtsStatus? status,
    String? errorMessage,
  }) {
    return TtsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
