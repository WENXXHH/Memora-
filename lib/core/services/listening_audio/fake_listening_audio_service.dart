import 'listening_audio_service.dart';

/// Fake 听音辨词音频服务（doc 22）。
///
/// 第 4 天专用：不输出任何声音，只记录调用序列，用于隔离验证
/// 题目状态机（Problem A）——题号切换、重播、dispose 等调用是否正确。
///
/// 不引入 audioplayers 依赖、不准备任何 MP3 资源（doc 24）。
/// 第 5 天替换为 [TtsListeningAudioService] 后，这些调用序列会变成真实朗读。
///
/// 验证能力（doc 32）：
/// - startQuiz 是否调用 play(currentWord.word)
/// - nextQuestion 是否先 stop 再 play 新词
/// - replay 是否只重播不前进 currentIndex
/// - dispose 是否调用了 stop
class FakeListeningAudioService implements ListeningAudioService {
  final List<String> playCalls = [];
  int stopCalls = 0;
  String? lastPlayedWord;

  /// 测试钩子：设置后 [play] 抛出指定异常（doc 30：播放失败场景）。
  /// 生产环境不设置此字段。
  Object? playException;

  @override
  Future<void> play(String word) async {
    final exception = playException;
    if (exception != null) {
      // 仍然记录调用，便于断言"播放被尝试过但失败了"
      playCalls.add(word);
      lastPlayedWord = word;
      throw exception;
    }
    playCalls.add(word);
    lastPlayedWord = word;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  /// 重置所有调用记录，便于测试间隔离。
  void reset() {
    playCalls.clear();
    stopCalls = 0;
    lastPlayedWord = null;
    playException = null;
  }
}
