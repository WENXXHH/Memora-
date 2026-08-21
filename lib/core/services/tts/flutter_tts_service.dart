import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

import 'tts_service.dart';

/// FlutterTtsService — flutter_tts 插件的封装实现
///
/// 遵循 TtsService 接口，通过构造函数注入 FlutterTts 实例，
/// 确保页面和 Controller 不直接依赖平台插件。
@LazySingleton(as: TtsService)
class FlutterTtsService implements TtsService {
  final FlutterTts _tts;

  FlutterTtsService(this._tts);

  @override
  Future<void> initialize() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  @override
  Future<void> speak(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('朗读文本不能为空');
    }

    await _tts.stop();
    await _tts.speak(normalized);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<bool> isLanguageAvailable(String language) async {
    final result = await _tts.isLanguageAvailable(language);
    return result == true || result == 1;
  }
}
