// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordBookResponseImpl _$$WordBookResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WordBookResponseImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  isBuiltin: json['is_builtin'] as bool? ?? false,
  ownerUserId: (json['owner_user_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$$WordBookResponseImplToJson(
  _$WordBookResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'is_builtin': instance.isBuiltin,
  'owner_user_id': instance.ownerUserId,
};

_$WordResponseImpl _$$WordResponseImplFromJson(Map<String, dynamic> json) =>
    _$WordResponseImpl(
      id: (json['id'] as num).toInt(),
      wordBookId: (json['word_book_id'] as num).toInt(),
      text: json['text'] as String,
      phonetic: json['phonetic'] as String?,
      meaning: json['meaning'] as String?,
      example: json['example'] as String?,
    );

Map<String, dynamic> _$$WordResponseImplToJson(_$WordResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word_book_id': instance.wordBookId,
      'text': instance.text,
      'phonetic': instance.phonetic,
      'meaning': instance.meaning,
      'example': instance.example,
    };

_$ReviewRecordDtoImpl _$$ReviewRecordDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewRecordDtoImpl(
  wordBookId: (json['word_book_id'] as num).toInt(),
  wordId: (json['word_id'] as num).toInt(),
  repetitionCount: (json['repetition_count'] as num).toInt(),
  easinessFactor: (json['easiness_factor'] as num).toDouble(),
  interval: (json['interval'] as num).toInt(),
  nextReviewAt: DateTime.parse(json['next_review_at'] as String),
  lastReviewAt: json['last_review_at'] == null
      ? null
      : DateTime.parse(json['last_review_at'] as String),
  learned: json['learned'] as bool,
  mastery: (json['mastery'] as num).toDouble(),
  clientUpdatedAt: DateTime.parse(json['client_updated_at'] as String),
);

Map<String, dynamic> _$$ReviewRecordDtoImplToJson(
  _$ReviewRecordDtoImpl instance,
) => <String, dynamic>{
  'word_book_id': instance.wordBookId,
  'word_id': instance.wordId,
  'repetition_count': instance.repetitionCount,
  'easiness_factor': instance.easinessFactor,
  'interval': instance.interval,
  'next_review_at': instance.nextReviewAt.toIso8601String(),
  'last_review_at': instance.lastReviewAt?.toIso8601String(),
  'learned': instance.learned,
  'mastery': instance.mastery,
  'client_updated_at': instance.clientUpdatedAt.toIso8601String(),
};

_$ReviewRecordSyncRequestImpl _$$ReviewRecordSyncRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewRecordSyncRequestImpl(
  records: (json['records'] as List<dynamic>)
      .map((e) => ReviewRecordDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ReviewRecordSyncRequestImplToJson(
  _$ReviewRecordSyncRequestImpl instance,
) => <String, dynamic>{
  'records': instance.records.map((e) => e.toJson()).toList(),
};

_$ReviewRecordSyncResponseImpl _$$ReviewRecordSyncResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewRecordSyncResponseImpl(
  records: (json['records'] as List<dynamic>)
      .map((e) => ReviewRecordDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  serverTime: DateTime.parse(json['server_time'] as String),
);

Map<String, dynamic> _$$ReviewRecordSyncResponseImplToJson(
  _$ReviewRecordSyncResponseImpl instance,
) => <String, dynamic>{
  'records': instance.records.map((e) => e.toJson()).toList(),
  'server_time': instance.serverTime.toIso8601String(),
};
