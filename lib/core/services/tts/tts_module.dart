import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

/// TTS 依赖注入模块
///
/// 为 injectable 代码生成器提供 FlutterTts 第三方实例的获取方式。
@module
abstract class TtsModule {
  @lazySingleton
  FlutterTts get flutterTts => FlutterTts();
}
