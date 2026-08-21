// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeaningEntryImpl _$$MeaningEntryImplFromJson(Map<String, dynamic> json) =>
    _$MeaningEntryImpl(
      pos: json['pos'] as String,
      definitions: (json['definitions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$MeaningEntryImplToJson(_$MeaningEntryImpl instance) =>
    <String, dynamic>{'pos': instance.pos, 'definitions': instance.definitions};

_$WordImpl _$$WordImplFromJson(Map<String, dynamic> json) => _$WordImpl(
  id: json['id'] as String,
  word: json['word'] as String,
  phonetic: json['phonetic'] as String,
  meaning: (json['meaning'] as List<dynamic>)
      .map((e) => MeaningEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  example: (json['example'] as List<dynamic>).map((e) => e as String).toList(),
  audio: json['audio'] as String,
  wordBookId: json['wordBookId'] as String,
);

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'phonetic': instance.phonetic,
      'meaning': instance.meaning.map((e) => e.toJson()).toList(),
      'example': instance.example,
      'audio': instance.audio,
      'wordBookId': instance.wordBookId,
    };
