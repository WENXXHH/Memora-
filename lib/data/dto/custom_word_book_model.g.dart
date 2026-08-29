// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_word_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomWordBookImpl _$$CustomWordBookImplFromJson(Map<String, dynamic> json) =>
    _$CustomWordBookImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CustomWordBookImplToJson(
  _$CustomWordBookImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
