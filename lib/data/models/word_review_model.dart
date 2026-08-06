import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_review_model.freezed.dart';
part 'word_review_model.g.dart';

/// 单词复习状态模型
///
/// 存储 SM-2 间隔重复算法所需的各项参数，
/// 用于跟踪每个单词的学习进度与掌握程度。
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
