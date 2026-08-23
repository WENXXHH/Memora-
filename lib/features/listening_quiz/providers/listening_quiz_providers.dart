import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/listening_audio/listening_audio_service.dart';
import '../../../core/services/listening_audio/tts_listening_audio_service.dart';
import '../../../features/vocabulary/providers/vocabulary_providers.dart';
import '../../../providers/repository_providers.dart';
import '../controller/listening_quiz_controller.dart';
import '../state/listening_quiz_state.dart';

/// 听音辨词音频服务 Provider（doc 22 / 23）。
///
/// 第 5 天起默认提供 [TtsListeningAudioService]：薄适配已有 [TtsService]
/// 实现真实朗读（依赖倒置，Controller 不感知底层实现）。
///
/// 测试环境通过 override 替换为 [FakeListeningAudioService] 验证题目状态机
/// （Problem A），或替换为记录调用的 Fake 防止真机发声。
final listeningAudioServiceProvider = Provider<ListeningAudioService>((ref) {
  return TtsListeningAudioService(ref.read(ttsServiceProvider));
});

/// 听音辨词控制器 Provider（doc 6 原则 19：独立 feature）。
///
/// 使用 autoDispose.family 按 wordBookId 隔离状态（与
/// [WordDetailController] 的 autoDispose 一致）：页面退出时 Provider 被
/// dispose，触发 [ListeningQuizController.dispose] 停止音频（doc 31：
/// 页面退出必须停止声音）。
///
/// 复用全局 [applyReviewFeedbackUseCaseProvider] 和 [wordRepositoryProvider] /
/// [reviewRepositoryProvider]，保证三种学习入口共享同一套 SM-2 + Hive。
final listeningQuizControllerProvider =
    StateNotifierProvider.autoDispose
        .family<ListeningQuizController, ListeningQuizState, String>(
      (ref, wordBookId) {
        return ListeningQuizController(
          ref.read(wordRepositoryProvider),
          ref.read(reviewRepositoryProvider),
          ref.read(applyReviewFeedbackUseCaseProvider),
          ref.read(listeningAudioServiceProvider),
        );
      },
    );
