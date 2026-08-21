/// 应用复习反馈的 UseCase。
///
/// 原则 16：把反馈更新提取为可复用 UseCase。
/// 此 UseCase 封装"获取/创建 → SM-2 更新 → 保存"三步链路，
/// 供 [LearningController] 和 [MultipleChoiceController] 共享调用。
///
/// 概念代码来自文档 11，已适配项目实际签名。
library;

import '../../data/dto/word_review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/enums/learning_enums.dart';
import '../../core/utils/sm2_algorithm.dart';

class ApplyReviewFeedbackUseCase {
  ApplyReviewFeedbackUseCase(this._reviewRepository);

  final ReviewRepository _reviewRepository;

  /// 执行反馈更新：获取现有记录（或创建初始） → SM-2 更新 → 保存。
  ///
  /// [wordBookId] 词库标识
  /// [wordId] 单词标识
  /// [feedback] 用户反馈类型
  /// 返回更新后的 [WordReview]。
  Future<WordReview> execute({
    required String wordBookId,
    required String wordId,
    required FeedbackType feedback,
  }) async {
    final existing = await _reviewRepository.getWordReview(
      wordId,
      wordBookId,
    );
    final review =
        existing ?? SM2Algorithm.createInitialReview(wordId, wordBookId);
    final updated = SM2Algorithm.updateReview(review, feedback);
    await _reviewRepository.saveWordReview(updated);
    return updated;
  }
}
