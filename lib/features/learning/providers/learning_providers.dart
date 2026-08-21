import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/learning_controller.dart';
import '../state/learning_state.dart';
import '../../../providers/repository_providers.dart';

/// 学习功能 Riverpod Provider 定义
///
/// 按规范将 Provider 与 Controller 类分离
/// 原则 16：复用共享 [applyReviewFeedbackUseCaseProvider] 实现 SM-2 更新逻辑
final learningControllerProvider =
    StateNotifierProvider.family<LearningController, LearningState, String>(
      (ref, wordBookId) => LearningController(
        ref.read(wordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
        ref.read(applyReviewFeedbackUseCaseProvider),
      ),
    );
