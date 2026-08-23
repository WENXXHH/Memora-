import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/listening_audio/fake_listening_audio_service.dart';
import '../../../core/services/listening_audio/listening_audio_service.dart';
import '../../../providers/repository_providers.dart';
import '../controller/listening_quiz_controller.dart';
import '../state/listening_quiz_state.dart';

/// 听音辨词音频服务 Provider（doc 22 / 23）。
///
/// 第 4 天默认提供 [FakeListeningAudioService]：不输出声音，只记录
/// playCalls/stopCalls/lastPlayedWord，用于验证题目状态机（Problem A）。
///
/// 第 5 天将 override 为 [TtsListeningAudioService]（依赖已有 TtsService）
/// 接入真实朗读。Controller 不感知底层实现差异。
final listeningAudioServiceProvider = Provider<ListeningAudioService>((ref) {
  return FakeListeningAudioService();
});

/// 听音辨词控制器 Provider（doc 6 原则 19：独立 feature）。
///
/// 使用 family 按 wordBookId 隔离状态（与 [MultipleChoiceController] 一致）。
/// 复用全局 [applyReviewFeedbackUseCaseProvider] 和 [wordRepositoryProvider] /
/// [reviewRepositoryProvider]，保证三种学习入口共享同一套 SM-2 + Hive。
final listeningQuizControllerProvider =
    StateNotifierProvider.family<
      ListeningQuizController,
      ListeningQuizState,
      String
    >((ref, wordBookId) {
      return ListeningQuizController(
        ref.read(wordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
        ref.read(applyReviewFeedbackUseCaseProvider),
        ref.read(listeningAudioServiceProvider),
      );
    });
