import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/word_detail_state.dart';
import '../../../domain/enums/tts_enums.dart';
import '../../../core/services/tts/tts_service.dart';

/// 单词详情页 TTS 发音控制器
///
/// 负责管理 TTS 播放状态：
/// - speak() 触发朗读并更新状态（idle → speaking → idle）
/// - stop() 停止朗读
/// - dispose() 确保页面退出时停止播放
class WordDetailController extends StateNotifier<TtsState> {
  final TtsService _ttsService;

  WordDetailController(this._ttsService) : super(const TtsState());

  /// 朗读单词
  ///
  /// [word] 单词文本，为空时直接返回
  Future<void> speak(String word) async {
    if (word.trim().isEmpty) return;

    state = const TtsState(status: TtsStatus.speaking);

    try {
      await _ttsService.speak(word);
      state = const TtsState(status: TtsStatus.idle);
    } catch (e) {
      state = TtsState(
        status: TtsStatus.error,
        errorMessage: '单词发音失败',
      );
    }
  }

  /// 停止当前朗读
  Future<void> stop() {
    return _ttsService.stop();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}
