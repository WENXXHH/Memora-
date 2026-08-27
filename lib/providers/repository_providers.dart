import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/dependency_injection.dart';
import '../data/repositories/word_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/custom_word_book_repository.dart';
import '../data/repositories/custom_word_repository.dart';
import '../domain/services/word_book_registry.dart';
import '../domain/use_cases/apply_review_feedback_use_case.dart';
import '../domain/use_cases/delete_custom_word_book_use_case.dart';

/// 全局 Provider：DI 容器
final getItProvider = Provider((ref) => getIt);

/// 全局 Provider：单词仓库
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return ref.read(getItProvider).get<WordRepository>();
});

// 全局 Provider：复习记录仓库
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ref.read(getItProvider).get<ReviewRepository>();
});

/// 全局 Provider：复习反馈 UseCase
///
/// 共享给 LearningController 和 MultipleChoiceController（原则 16）。
final applyReviewFeedbackUseCaseProvider = Provider<ApplyReviewFeedbackUseCase>(
  (ref) {
    return ApplyReviewFeedbackUseCase(ref.read(reviewRepositoryProvider));
  },
);

/// 全局 Provider：自建词库仓库
final customWordBookRepositoryProvider = Provider<CustomWordBookRepository>((
  ref,
) {
  return ref.read(getItProvider).get<CustomWordBookRepository>();
});

/// 全局 Provider：统一词库注册表（doc 31 / 32）
///
/// 组合内置静态目录 + 自建 Hive 词库，供词库选择验证与选择页渲染使用。
final wordBookRegistryProvider = Provider<WordBookRegistry>((ref) {
  return WordBookRegistry(ref.read(customWordBookRepositoryProvider));
});

/// 全局 Provider：自建单词仓库
final customWordRepositoryProvider = Provider<CustomWordRepository>((ref) {
  return ref.read(getItProvider).get<CustomWordRepository>();
});

/// 全局 Provider：删除自建词库 UseCase
///
/// 删除跨 Repository（单词 + Review + 词库），由 UseCase 编排（doc 60 / 61）。
final deleteCustomWordBookUseCaseProvider =
    Provider<DeleteCustomWordBookUseCase>((ref) {
      return DeleteCustomWordBookUseCase(
        ref.read(customWordBookRepositoryProvider),
        ref.read(customWordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
      );
    });
