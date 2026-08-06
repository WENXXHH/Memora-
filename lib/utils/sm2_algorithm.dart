import '../data/models/word_review_model.dart';
import '../domain/enums/learning_enums.dart';

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
      newInterval = 1;
    } else if (newRepetition == 2) {
      newInterval = 6;
    } else {
      newInterval = (currentInterval * newEF).round();
    }

    return (newInterval, newEF, newRepetition);
  }

  /// 根据用户反馈更新复习记录，返回新的复习状态
  static WordReview updateReview(
    WordReview currentReview,
    FeedbackType feedback,
  ) {
    final quality = _qualityFromFeedback(feedback);
    final now = DateTime.now();

    final (newInterval, newEF, newRepetition) = _calculate(
      quality,
      currentReview.repetitionCount,
      currentReview.easinessFactor,
      currentReview.interval,
    );

    final newMastery = _calculateMastery(newRepetition, newEF);
    final newLearned = newRepetition >= 3 && newEF >= 2.3;

    return currentReview.copyWith(
      repetitionCount: newRepetition,
      easinessFactor: newEF,
      interval: newInterval,
      nextReviewDate: now.add(
        Duration(days: newInterval),
      ),
      lastReviewDate: now,
      learned: newLearned,
      mastery: newMastery,
    );
  }

  /// 检查下次复习日期是否已到（仅比较日期，忽略时分秒）
  static bool isDueToday(WordReview review) {
    final today = DateTime.now();
    final nextDateOnly = DateTime(
      review.nextReviewDate.year,
      review.nextReviewDate.month,
      review.nextReviewDate.day,
    );
    final todayOnly = DateTime(today.year, today.month, today.day);
    return !nextDateOnly.isAfter(todayOnly);
  }

  /// 创建单词的初始复习状态
  ///
  /// 工厂方法从 WordReview 模型移至此处，因为 SM-2 算法默认值
  /// 是算法关注点，非数据结构定义。
  static WordReview createInitialReview(String wordId, String wordBookId) {
    return WordReview(
      wordId: wordId,
      wordBookId: wordBookId,
      repetitionCount: 0,
      easinessFactor: 2.5,
      interval: 0,
      nextReviewDate: DateTime.now(),
      lastReviewDate: null,
      learned: false,
      mastery: 0.0,
    );
  }

  // 基于重复次数和 EF 计算掌握度 (0.0~1.0)
  static double _calculateMastery(int repetition, double ef) {
    final base = repetition * 0.15;
    final efBonus = (ef - 2.5) * 0.1;
    return (base + efBonus).clamp(0.0, 1.0);
  }
}
