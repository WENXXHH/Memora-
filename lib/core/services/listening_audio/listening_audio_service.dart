/// 听音辨词音频服务抽象接口（doc 23）。
///
/// 作用：为 [ListeningQuizController] 提供单词播放能力，屏蔽底层
/// 实现细节（Fake / TTS）。
///
/// 第一版使用 [FakeListeningAudioService] 验证题目状态机（doc 22），
/// 第 5 天替换为 [TtsListeningAudioService] 接入已有 [TtsService]。
/// Controller 不感知底层究竟是 Fake 还是 TTS，这就是依赖倒置。
abstract interface class ListeningAudioService {
  /// 播放指定英文单词的发音。
  ///
  /// 实现必须保证：连续快速调用时先停止旧播放再开始新播放，
  /// 防止多个声音叠在一起（doc 29）。
  Future<void> play(String word);

  /// 停止当前正在播放的音频（doc 31：页面退出必须停止音频）。
  Future<void> stop();
}
