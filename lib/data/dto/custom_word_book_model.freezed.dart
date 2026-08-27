// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_word_book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomWordBook _$CustomWordBookFromJson(Map<String, dynamic> json) {
  return _CustomWordBook.fromJson(json);
}

/// @nodoc
mixin _$CustomWordBook {
  /// 词库 Domain ID，格式 custom_<uuid>，一旦创建永不变化（doc 5）。
  String get id => throw _privateConstructorUsedError;

  /// 展示名称，trim 后 1~30 字符，同设备唯一（doc 13）。
  String get name => throw _privateConstructorUsedError;

  /// 创建时间（本地）。
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 最后修改时间（本地），重命名时更新。
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomWordBook to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomWordBook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomWordBookCopyWith<CustomWordBook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomWordBookCopyWith<$Res> {
  factory $CustomWordBookCopyWith(
    CustomWordBook value,
    $Res Function(CustomWordBook) then,
  ) = _$CustomWordBookCopyWithImpl<$Res, CustomWordBook>;
  @useResult
  $Res call({String id, String name, DateTime createdAt, DateTime updatedAt});
}

/// @nodoc
class _$CustomWordBookCopyWithImpl<$Res, $Val extends CustomWordBook>
    implements $CustomWordBookCopyWith<$Res> {
  _$CustomWordBookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomWordBook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomWordBookImplCopyWith<$Res>
    implements $CustomWordBookCopyWith<$Res> {
  factory _$$CustomWordBookImplCopyWith(
    _$CustomWordBookImpl value,
    $Res Function(_$CustomWordBookImpl) then,
  ) = __$$CustomWordBookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, DateTime createdAt, DateTime updatedAt});
}

/// @nodoc
class __$$CustomWordBookImplCopyWithImpl<$Res>
    extends _$CustomWordBookCopyWithImpl<$Res, _$CustomWordBookImpl>
    implements _$$CustomWordBookImplCopyWith<$Res> {
  __$$CustomWordBookImplCopyWithImpl(
    _$CustomWordBookImpl _value,
    $Res Function(_$CustomWordBookImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomWordBook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CustomWordBookImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomWordBookImpl implements _CustomWordBook {
  const _$CustomWordBookImpl({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$CustomWordBookImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomWordBookImplFromJson(json);

  /// 词库 Domain ID，格式 custom_<uuid>，一旦创建永不变化（doc 5）。
  @override
  final String id;

  /// 展示名称，trim 后 1~30 字符，同设备唯一（doc 13）。
  @override
  final String name;

  /// 创建时间（本地）。
  @override
  final DateTime createdAt;

  /// 最后修改时间（本地），重命名时更新。
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CustomWordBook(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomWordBookImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt, updatedAt);

  /// Create a copy of CustomWordBook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomWordBookImplCopyWith<_$CustomWordBookImpl> get copyWith =>
      __$$CustomWordBookImplCopyWithImpl<_$CustomWordBookImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomWordBookImplToJson(this);
  }
}

abstract class _CustomWordBook implements CustomWordBook {
  const factory _CustomWordBook({
    required final String id,
    required final String name,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CustomWordBookImpl;

  factory _CustomWordBook.fromJson(Map<String, dynamic> json) =
      _$CustomWordBookImpl.fromJson;

  /// 词库 Domain ID，格式 custom_<uuid>，一旦创建永不变化（doc 5）。
  @override
  String get id;

  /// 展示名称，trim 后 1~30 字符，同设备唯一（doc 13）。
  @override
  String get name;

  /// 创建时间（本地）。
  @override
  DateTime get createdAt;

  /// 最后修改时间（本地），重命名时更新。
  @override
  DateTime get updatedAt;

  /// Create a copy of CustomWordBook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomWordBookImplCopyWith<_$CustomWordBookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
