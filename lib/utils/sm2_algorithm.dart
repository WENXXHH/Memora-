import '../data/models/word_review_model.dart';
import '../features/learning/state/learning_state.dart';

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

    double newEF = currentEF + (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
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

  static WordReview updateReview(WordReview currentReview, FeedbackType feedback) {
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
      nextReviewDate: now.add(Duration(days: newInterval)),
      lastReviewDate: now,
      learned: newLearned,
      mastery: newMastery,
    );
  }

  static bool isDueToday(WordReview review) {
    final today = DateTime.now();
    return review.nextReviewDate.isBefore(today) ||
        review.nextReviewDate.isAtSameMomentAs(today);
  }

  static double _calculateMastery(int repetition, double ef) {
    final base = repetition * 0.15;
    final efBonus = (ef - 2.5) * 0.1;
    return (base + efBonus).clamp(0.0, 1.0);
  }
}