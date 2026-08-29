// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_word_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomWordRecordImpl _$$CustomWordRecordImplFromJson(
  Map<String, dynamic> json,
) => _$CustomWordRecordImpl(
  id: json['id'] as String,
  wordBookId: json['wordBookId'] as String,
  word: json['word'] as String,
  phonetic: json['phonetic'] as String,
  meaning: (json['meaning'] as List<dynamic>)
      .map((e) => MeaningEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  example: (json['example'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$CustomWordRecordImplToJson(
  _$CustomWordRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'wordBookId': instance.wordBookId,
  'word': instance.word,
  'phonetic': instance.phonetic,
  'meaning': instance.meaning.map((e) => e.toJson()).toList(),
  'example': instance.example,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
