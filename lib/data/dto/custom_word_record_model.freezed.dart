// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_word_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomWordRecord _$CustomWordRecordFromJson(Map<String, dynamic> json) {
  return _CustomWordRecord.fromJson(json);
}

/// @nodoc
mixin _$CustomWordRecord {
  /// 单词 ID（uuid，doc 19），一旦创建不再变化。
  String get id => throw _privateConstructorUsedError;

  /// 所属自建词库 Domain ID（custom_<uuid>）。
  String get wordBookId => throw _privateConstructorUsedError;

  /// 英文单词（trim + lowercase 标准化，doc 44）。
  String get word => throw _privateConstructorUsedError;

  /// 音标（可选，缺省为空串）。
  String get phonetic => throw _privateConstructorUsedError;

  /// 释义列表（表单只输入中文，生成一条默认 MeaningEntry，doc 12）。
  List<MeaningEntry> get meaning => throw _privateConstructorUsedError;

  /// 例句列表（表单可选输入单条）。
  List<String> get example => throw _privateConstructorUsedError;

  /// 创建时间（本地）。
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 最后修改时间（本地）。
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomWordRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomWordRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomWordRecordCopyWith<CustomWordRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomWordRecordCopyWith<$Res> {
  factory $CustomWordRecordCopyWith(
    CustomWordRecord value,
    $Res Function(CustomWordRecord) then,
  ) = _$CustomWordRecordCopyWithImpl<$Res, CustomWordRecord>;
  @useResult
  $Res call({
    String id,
    String wordBookId,
    String word,
    String phonetic,
    List<MeaningEntry> meaning,
    List<String> example,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CustomWordRecordCopyWithImpl<$Res, $Val extends CustomWordRecord>
    implements $CustomWordRecordCopyWith<$Res> {
  _$CustomWordRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomWordRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordBookId = null,
    Object? word = null,
    Object? phonetic = null,
    Object? meaning = null,
    Object? example = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            wordBookId: null == wordBookId
                ? _value.wordBookId
                : wordBookId // ignore: cast_nullable_to_non_nullable
                      as String,
            word: null == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String,
            phonetic: null == phonetic
                ? _value.phonetic
                : phonetic // ignore: cast_nullable_to_non_nullable
                      as String,
            meaning: null == meaning
                ? _value.meaning
                : meaning // ignore: cast_nullable_to_non_nullable
                      as List<MeaningEntry>,
            example: null == example
                ? _value.example
                : example // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$CustomWordRecordImplCopyWith<$Res>
    implements $CustomWordRecordCopyWith<$Res> {
  factory _$$CustomWordRecordImplCopyWith(
    _$CustomWordRecordImpl value,
    $Res Function(_$CustomWordRecordImpl) then,
  ) = __$$CustomWordRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String wordBookId,
    String word,
    String phonetic,
    List<MeaningEntry> meaning,
    List<String> example,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CustomWordRecordImplCopyWithImpl<$Res>
    extends _$CustomWordRecordCopyWithImpl<$Res, _$CustomWordRecordImpl>
    implements _$$CustomWordRecordImplCopyWith<$Res> {
  __$$CustomWordRecordImplCopyWithImpl(
    _$CustomWordRecordImpl _value,
    $Res Function(_$CustomWordRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomWordRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordBookId = null,
    Object? word = null,
    Object? phonetic = null,
    Object? meaning = null,
    Object? example = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CustomWordRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        wordBookId: null == wordBookId
            ? _value.wordBookId
            : wordBookId // ignore: cast_nullable_to_non_nullable
                  as String,
        word: null == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String,
        phonetic: null == phonetic
            ? _value.phonetic
            : phonetic // ignore: cast_nullable_to_non_nullable
                  as String,
        meaning: null == meaning
            ? _value._meaning
            : meaning // ignore: cast_nullable_to_non_nullable
                  as List<MeaningEntry>,
        example: null == example
            ? _value._example
            : example // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$CustomWordRecordImpl implements _CustomWordRecord {
  const _$CustomWordRecordImpl({
    required this.id,
    required this.wordBookId,
    required this.word,
    required this.phonetic,
    required final List<MeaningEntry> meaning,
    required final List<String> example,
    required this.createdAt,
    required this.updatedAt,
  }) : _meaning = meaning,
       _example = example;

  factory _$CustomWordRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomWordRecordImplFromJson(json);

  /// 单词 ID（uuid，doc 19），一旦创建不再变化。
  @override
  final String id;

  /// 所属自建词库 Domain ID（custom_<uuid>）。
  @override
  final String wordBookId;

  /// 英文单词（trim + lowercase 标准化，doc 44）。
  @override
  final String word;

  /// 音标（可选，缺省为空串）。
  @override
  final String phonetic;

  /// 释义列表（表单只输入中文，生成一条默认 MeaningEntry，doc 12）。
  final List<MeaningEntry> _meaning;

  /// 释义列表（表单只输入中文，生成一条默认 MeaningEntry，doc 12）。
  @override
  List<MeaningEntry> get meaning {
    if (_meaning is EqualUnmodifiableListView) return _meaning;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meaning);
  }

  /// 例句列表（表单可选输入单条）。
  final List<String> _example;

  /// 例句列表（表单可选输入单条）。
  @override
  List<String> get example {
    if (_example is EqualUnmodifiableListView) return _example;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_example);
  }

  /// 创建时间（本地）。
  @override
  final DateTime createdAt;

  /// 最后修改时间（本地）。
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CustomWordRecord(id: $id, wordBookId: $wordBookId, word: $word, phonetic: $phonetic, meaning: $meaning, example: $example, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomWordRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.wordBookId, wordBookId) ||
                other.wordBookId == wordBookId) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.phonetic, phonetic) ||
                other.phonetic == phonetic) &&
            const DeepCollectionEquality().equals(other._meaning, _meaning) &&
            const DeepCollectionEquality().equals(other._example, _example) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    wordBookId,
    word,
    phonetic,
    const DeepCollectionEquality().hash(_meaning),
    const DeepCollectionEquality().hash(_example),
    createdAt,
    updatedAt,
  );

  /// Create a copy of CustomWordRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomWordRecordImplCopyWith<_$CustomWordRecordImpl> get copyWith =>
      __$$CustomWordRecordImplCopyWithImpl<_$CustomWordRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomWordRecordImplToJson(this);
  }
}

abstract class _CustomWordRecord implements CustomWordRecord {
  const factory _CustomWordRecord({
    required final String id,
    required final String wordBookId,
    required final String word,
    required final String phonetic,
    required final List<MeaningEntry> meaning,
    required final List<String> example,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CustomWordRecordImpl;

  factory _CustomWordRecord.fromJson(Map<String, dynamic> json) =
      _$CustomWordRecordImpl.fromJson;

  /// 单词 ID（uuid，doc 19），一旦创建不再变化。
  @override
  String get id;

  /// 所属自建词库 Domain ID（custom_<uuid>）。
  @override
  String get wordBookId;

  /// 英文单词（trim + lowercase 标准化，doc 44）。
  @override
  String get word;

  /// 音标（可选，缺省为空串）。
  @override
  String get phonetic;

  /// 释义列表（表单只输入中文，生成一条默认 MeaningEntry，doc 12）。
  @override
  List<MeaningEntry> get meaning;

  /// 例句列表（表单可选输入单条）。
  @override
  List<String> get example;

  /// 创建时间（本地）。
  @override
  DateTime get createdAt;

  /// 最后修改时间（本地）。
  @override
  DateTime get updatedAt;

  /// Create a copy of CustomWordRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomWordRecordImplCopyWith<_$CustomWordRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
