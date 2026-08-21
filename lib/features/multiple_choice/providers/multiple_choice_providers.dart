import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../controller/multiple_choice_controller.dart';
import '../state/multiple_choice_state.dart';

/// 选择题控制器 Provider。
///
/// 使用 family 按 wordBookId 隔离状态（与 LearningController 一致）。
/// [ApplyReviewFeedbackUseCase] 从全局 [applyReviewFeedbackUseCaseProvider] 获取。
/// [QuestionGenerator] 内部使用生产环境 `Random()`，
/// 测试可通过 override 传入 `Random(42)` 实现可重复结果。
final multipleChoiceControllerProvider =
    StateNotifierProvider.family<
      MultipleChoiceController,
      MultipleChoiceState,
      String
    >((ref, wordBookId) {
      return MultipleChoiceController(
        ref.read(wordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
        ref.read(applyReviewFeedbackUseCaseProvider),
      );
    });
