// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestImpl(
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
};

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

_$RemoteUserImpl _$$RemoteUserImplFromJson(Map<String, dynamic> json) =>
    _$RemoteUserImpl(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$$RemoteUserImplToJson(_$RemoteUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
    };

_$TokenResponseImpl _$$TokenResponseImplFromJson(Map<String, dynamic> json) =>
    _$TokenResponseImpl(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: RemoteUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TokenResponseImplToJson(_$TokenResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user.toJson(),
    };
