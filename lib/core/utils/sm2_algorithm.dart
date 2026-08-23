import '../../data/dto/word_review_model.dart';
import '../../domain/enums/learning_enums.dart';

/// SM-2 间隔重复算法实现
///
/// 所有方法均为纯函数风格，无副作用，不依赖外部状态。
class SM2Algorithm {
  static int _qualityFromFeedback(FeedbackType feedback) {
    switch (feedback) {
      case FeedbackType.known:
        return 5;
      case FeedbackType.fuzzy:
        return 3;
      case FeedbackType.unknown:
        return 1;
    }
  }

  // SM-2 核心计算：根据评分质量返回新的间隔、EF 和重复次数
  static (int, double, int) _calculate(
    int quality,
    int currentRepetition,
    double currentEF,
    int currentInterval,
  ) {
    final clampedQuality = quality.clamp(0, 5);

    if (clampedQuality < 3) {
      return (1, currentEF, 0);
    }

    double newEF =
        currentEF +
        (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
    newEF = newEF.clamp(1.3, 5.0);

    final newRepetition = currentRepetition + 1;
    int newInterval;

    if (newRepetition == 1) {
      newInterval = 0; // 第一次学习后立即可复习，符合「学完即测」流程
    } else if (newRepetition == 2) {
      newInterval = 6;
    } else {
      newInterval = (currentInterval * newEF).round();
    }

    return (newInterval, newEF, newRepetition);
  }

  /// 创建一个单词的初始复习状态
  ///
  /// repetitionCount = 0, EF = 2.5, interval = 0
  /// nextReviewDate 为今天，表示需要立即学习
  static WordReview createInitialReview(String wordId, String wordBookId) {
    final now = DateTime.now();
    return WordReview(
      wordId: wordId,
      wordBookId: wordBookId,
      repetitionCount: 0,
      easinessFactor: 2.5,
      interval: 0,
      nextReviewDate: DateTime(now.year, now.month, now.day),
      lastReviewDate: null,
      learned: false,
      mastery: 0.0,
      clientUpdatedAt: now.toUtc(),
    );
  }

  /// 根据用户反馈更新复习状态
  ///
  /// 调用 SM-2 核心计算，返回新的 WordReview。
  static WordReview updateReview(WordReview review, FeedbackType feedback) {
    final quality = _qualityFromFeedback(feedback);
    final (newInterval, newEF, newRepetition) = _calculate(
      quality,
      review.repetitionCount,
      review.easinessFactor,
      review.interval,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = today.add(Duration(days: newInterval));

    // 熟练度：根据 repetitionCount 和 quality 估算
    final double newMastery;
    if (quality >= 4) {
      newMastery = (review.mastery + 0.2).clamp(0.0, 1.0);
    } else if (quality >= 3) {
      newMastery = (review.mastery + 0.05).clamp(0.0, 1.0);
    } else {
      newMastery = (review.mastery - 0.2).clamp(0.0, 1.0);
    }

    return review.copyWith(
      repetitionCount: newRepetition,
      easinessFactor: newEF,
      interval: newInterval,
      nextReviewDate: nextDate,
      lastReviewDate: now,
      learned: newRepetition >= 1 && quality >= 3,
      mastery: newMastery,
      clientUpdatedAt: now.toUtc(),
    );
  }

  /// 判断该复习记录今天是否到期
  static bool isDueToday(WordReview review) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(
      review.nextReviewDate.year,
      review.nextReviewDate.month,
      review.nextReviewDate.day,
    );
    return !next.isAfter(today);
  }
}
