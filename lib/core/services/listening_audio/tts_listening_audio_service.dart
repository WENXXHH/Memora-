import '../tts/tts_service.dart';
import 'listening_audio_service.dart';

/// 基于 [TtsService] 的听音辨词音频服务（doc 23）。
///
/// 第 5 天替换 [FakeListeningAudioService] 的真实实现。它不是第二个
/// TTS 实现，而是 [TtsService] 的薄适配层：将 [ListeningAudioService]
/// 的 play/stop 转发给已有 [TtsService]。
///
/// 边界与复用（doc 23）：
/// - 不在此处调用 `FlutterTts()` 或 `setLanguage` —— 初始化由
///   [TtsService.initialize] 负责，已在 main.dart 启动时完成
/// - [TtsService.speak] 内部已先 stop 再 speak，连续点击不会叠音
///   （doc 29 / Bug 9），此处不重复 stop
/// - speak 抛异常（空文本、引擎不可用）会向上抛出，由
///   [ListeningQuizController._playCurrentWord] 的 try/catch 捕获
///   并设置 hasAudioError（doc 30），绝不调用 SM-2
class TtsListeningAudioService implements ListeningAudioService {
  TtsListeningAudioService(this._ttsService);

  final TtsService _ttsService;

  @override
  Future<void> play(String word) => _ttsService.speak(word);

  @override
  Future<void> stop() => _ttsService.stop();
}
