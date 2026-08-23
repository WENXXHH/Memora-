import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/services/listening_audio/tts_listening_audio_service.dart';
import 'package:memora/core/services/tts/tts_service.dart';

/// TtsListeningAudioService 单元测试（doc 23 薄适配层）。
///
/// 验证：
/// 1. play 转发给 TtsService.speak
/// 2. stop 转发给 TtsService.stop
/// 3. speak 抛出的异常原样向上传递（doc 30：由 Controller 捕获设 hasAudioError，
///    绝不在适配层吞掉并错误地保存 SM-2）
///
/// 使用 Fake 实现 [TtsService]，不触碰真实 FlutterTts 插件。
void main() {
  late FakeTtsService ttsService;
  late TtsListeningAudioService adapter;

  setUp(() {
    ttsService = FakeTtsService();
    adapter = TtsListeningAudioService(ttsService);
  });

  group('TtsListeningAudioService — 代理转发', () {
    test('play 转发给 TtsService.speak', () async {
      await adapter.play('abandon');

      expect(ttsService.speakCalls, ['abandon']);
      expect(ttsService.stopCalls, 0);
    });

    test('stop 转发给 TtsService.stop', () async {
      await adapter.stop();

      expect(ttsService.stopCalls, 1);
    });

    test('连续 play 不重复 stop（speak 内部已防叠音，doc 29）', () async {
      await adapter.play('abandon');
      await adapter.play('ability');

      expect(ttsService.speakCalls, ['abandon', 'ability']);
      expect(ttsService.stopCalls, 0);
    });
  });

  group('TtsListeningAudioService — 错误传递（doc 30）', () {
    test('speak 抛异常原样向上传递，不被吞掉', () async {
      ttsService.speakError = Exception('TTS engine unavailable');

      expect(
        () => adapter.play('abandon'),
        throwsA(isA<Exception>()),
      );
    });

    test('空文本由底层 TtsService 抛 ArgumentError（不在适配层重复校验）', () {
      // 空文本校验是 TtsService 的职责，适配层只转发（doc 23 薄适配）
      ttsService.speakError = ArgumentError('朗读文本不能为空');

      expect(
        () => adapter.play('  '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

/// Fake TtsService — 记录调用，可模拟失败。
class FakeTtsService implements TtsService {
  final List<String> speakCalls = [];
  int stopCalls = 0;
  Object? speakError;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {
    speakCalls.add(text);
    final error = speakError;
    if (error != null) throw error;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<bool> isLanguageAvailable(String language) async => true;
}
