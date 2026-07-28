import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_review_model.freezed.dart';
part 'word_review_model.g.dart';

@freezed
class WordReview with _$WordReview {
  const factory WordReview({
    required String wordId,
    required String wordBookId,
    required int repetitionCount,
    required double easinessFactor,
    required int interval,
    required DateTime nextReviewDate,
    required DateTime? lastReviewDate,
    required bool learned,
    required double mastery,
  }) = _WordReview;

  factory WordReview.fromJson(Map<String, dynamic> json) =>
      _$WordReviewFromJson(json);
}
