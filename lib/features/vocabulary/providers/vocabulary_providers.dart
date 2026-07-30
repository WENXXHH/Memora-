import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/word_list_controller.dart';
import '../controller/word_detail_controller.dart';
import '../state/word_list_state.dart';
import '../state/word_detail_state.dart';
import '../../../providers/repository_providers.dart';
import '../../../services/tts_service.dart';

/// 词库单词列表 Provider
final wordListControllerProvider =
    StateNotifierProvider.family<WordListController, WordListState, String>(
      (ref, wordBookId) => WordListController(ref.read(wordRepositoryProvider)),
    );

/// TTS 服务 Provider（通过 getIt 获取）
final ttsServiceProvider = Provider<TtsService>((ref) {
  return ref.read(getItProvider).get<TtsService>();
});

/// 单词详情页 TTS 发音 Provider（autoDispose 确保页面退出时停止朗读）
final wordDetailControllerProvider =
    StateNotifierProvider.autoDispose<WordDetailController, TtsState>((ref) {
  return WordDetailController(ref.read(ttsServiceProvider));
});
