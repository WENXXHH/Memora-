import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../controller/spelling_quiz_controller.dart';
import '../state/spelling_quiz_state.dart';

/// 拼写复习控制器 Provider（doc §26）。
///
/// 使用 autoDispose.family 按 wordBookId 隔离状态：
/// - 页面退出后 Provider 被 dispose，再次进入不会残留上一轮作答（Bug 8）
/// - 不同 wordBookId → 不同 Controller，不会发生状态串场
///
/// 与最新的听音辨词 feature 保持一致（选择题仍是旧的非 autoDispose
/// StateNotifierProvider.family，历史遗留，TODO 迁移到 autoDispose）。
final spellingQuizControllerProvider = StateNotifierProvider.autoDispose
    .family<SpellingQuizController, SpellingQuizState, String>((
      ref,
      wordBookId,
    ) {
      return SpellingQuizController(
        ref.read(wordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
        ref.read(applyReviewFeedbackUseCaseProvider),
      );
    });
