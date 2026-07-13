// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordReviewImpl _$$WordReviewImplFromJson(Map<String, dynamic> json) =>
    _$WordReviewImpl(
      wordId: json['wordId'] as String,
      wordBookId: json['wordBookId'] as String,
      repetitionCount: (json['repetitionCount'] as num).toInt(),
      easinessFactor: (json['easinessFactor'] as num).toDouble(),
      interval: (json['interval'] as num).toInt(),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      lastReviewDate: json['lastReviewDate'] == null
          ? null
          : DateTime.parse(json['lastReviewDate'] as String),
      learned: json['learned'] as bool,
      mastery: (json['mastery'] as num).toDouble(),
    );

Map<String, dynamic> _$$WordReviewImplToJson(_$WordReviewImpl instance) =>
    <String, dynamic>{
      'wordId': instance.wordId,
      'wordBookId': instance.wordBookId,
      'repetitionCount': instance.repetitionCount,
      'easinessFactor': instance.easinessFactor,
      'interval': instance.interval,
      'nextReviewDate': instance.nextReviewDate.toIso8601String(),
      'lastReviewDate': instance.lastReviewDate?.toIso8601String(),
      'learned': instance.learned,
      'mastery': instance.mastery,
    };
