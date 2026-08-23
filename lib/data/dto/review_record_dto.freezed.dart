// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_record_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WordBookResponse _$WordBookResponseFromJson(Map<String, dynamic> json) {
  return _WordBookResponse.fromJson(json);
}

/// @nodoc
mixin _$WordBookResponse {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_builtin')
  bool get isBuiltin => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_user_id')
  int? get ownerUserId => throw _privateConstructorUsedError;

  /// Serializes this WordBookResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordBookResponseCopyWith<WordBookResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordBookResponseCopyWith<$Res> {
  factory $WordBookResponseCopyWith(
    WordBookResponse value,
    $Res Function(WordBookResponse) then,
  ) = _$WordBookResponseCopyWithImpl<$Res, WordBookResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'is_builtin') bool isBuiltin,
    @JsonKey(name: 'owner_user_id') int? ownerUserId,
  });
}

/// @nodoc
class _$WordBookResponseCopyWithImpl<$Res, $Val extends WordBookResponse>
    implements $WordBookResponseCopyWith<$Res> {
  _$WordBookResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? isBuiltin = null,
    Object? ownerUserId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isBuiltin: null == isBuiltin
                ? _value.isBuiltin
                : isBuiltin // ignore: cast_nullable_to_non_nullable
                      as bool,
            ownerUserId: freezed == ownerUserId
                ? _value.ownerUserId
                : ownerUserId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordBookResponseImplCopyWith<$Res>
    implements $WordBookResponseCopyWith<$Res> {
  factory _$$WordBookResponseImplCopyWith(
    _$WordBookResponseImpl value,
    $Res Function(_$WordBookResponseImpl) then,
  ) = __$$WordBookResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'is_builtin') bool isBuiltin,
    @JsonKey(name: 'owner_user_id') int? ownerUserId,
  });
}

/// @nodoc
class __$$WordBookResponseImplCopyWithImpl<$Res>
    extends _$WordBookResponseCopyWithImpl<$Res, _$WordBookResponseImpl>
    implements _$$WordBookResponseImplCopyWith<$Res> {
  __$$WordBookResponseImplCopyWithImpl(
    _$WordBookResponseImpl _value,
    $Res Function(_$WordBookResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WordBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? isBuiltin = null,
    Object? ownerUserId = freezed,
  }) {
    return _then(
      _$WordBookResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isBuiltin: null == isBuiltin
            ? _value.isBuiltin
            : isBuiltin // ignore: cast_nullable_to_non_nullable
                  as bool,
        ownerUserId: freezed == ownerUserId
            ? _value.ownerUserId
            : ownerUserId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordBookResponseImpl implements _WordBookResponse {
  const _$WordBookResponseImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'is_builtin') this.isBuiltin = false,
    @JsonKey(name: 'owner_user_id') this.ownerUserId,
  });

  factory _$WordBookResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordBookResponseImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'is_builtin')
  final bool isBuiltin;
  @override
  @JsonKey(name: 'owner_user_id')
  final int? ownerUserId;

  @override
  String toString() {
    return 'WordBookResponse(id: $id, name: $name, description: $description, isBuiltin: $isBuiltin, ownerUserId: $ownerUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordBookResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isBuiltin, isBuiltin) ||
                other.isBuiltin == isBuiltin) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, isBuiltin, ownerUserId);

  /// Create a copy of WordBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordBookResponseImplCopyWith<_$WordBookResponseImpl> get copyWith =>
      __$$WordBookResponseImplCopyWithImpl<_$WordBookResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WordBookResponseImplToJson(this);
  }
}

abstract class _WordBookResponse implements WordBookResponse {
  const factory _WordBookResponse({
    @JsonKey(name: 'id') required final int id,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'is_builtin') final bool isBuiltin,
    @JsonKey(name: 'owner_user_id') final int? ownerUserId,
  }) = _$WordBookResponseImpl;

  factory _WordBookResponse.fromJson(Map<String, dynamic> json) =
      _$WordBookResponseImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'is_builtin')
  bool get isBuiltin;
  @override
  @JsonKey(name: 'owner_user_id')
  int? get ownerUserId;

  /// Create a copy of WordBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordBookResponseImplCopyWith<_$WordBookResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WordResponse _$WordResponseFromJson(Map<String, dynamic> json) {
  return _WordResponse.fromJson(json);
}

/// @nodoc
mixin _$WordResponse {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'word_book_id')
  int get wordBookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'text')
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'phonetic')
  String? get phonetic => throw _privateConstructorUsedError;
  @JsonKey(name: 'meaning')
  String? get meaning => throw _privateConstructorUsedError;
  @JsonKey(name: 'example')
  String? get example => throw _privateConstructorUsedError;

  /// Serializes this WordResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordResponseCopyWith<WordResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordResponseCopyWith<$Res> {
  factory $WordResponseCopyWith(
    WordResponse value,
    $Res Function(WordResponse) then,
  ) = _$WordResponseCopyWithImpl<$Res, WordResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'word_book_id') int wordBookId,
    @JsonKey(name: 'text') String text,
    @JsonKey(name: 'phonetic') String? phonetic,
    @JsonKey(name: 'meaning') String? meaning,
    @JsonKey(name: 'example') String? example,
  });
}

/// @nodoc
class _$WordResponseCopyWithImpl<$Res, $Val extends WordResponse>
    implements $WordResponseCopyWith<$Res> {
  _$WordResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordBookId = null,
    Object? text = null,
    Object? phonetic = freezed,
    Object? meaning = freezed,
    Object? example = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            wordBookId: null == wordBookId
                ? _value.wordBookId
                : wordBookId // ignore: cast_nullable_to_non_nullable
                      as int,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            phonetic: freezed == phonetic
                ? _value.phonetic
                : phonetic // ignore: cast_nullable_to_non_nullable
                      as String?,
            meaning: freezed == meaning
                ? _value.meaning
                : meaning // ignore: cast_nullable_to_non_nullable
                      as String?,
            example: freezed == example
                ? _value.example
                : example // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordResponseImplCopyWith<$Res>
    implements $WordResponseCopyWith<$Res> {
  factory _$$WordResponseImplCopyWith(
    _$WordResponseImpl value,
    $Res Function(_$WordResponseImpl) then,
  ) = __$$WordResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int id,
    @JsonKey(name: 'word_book_id') int wordBookId,
    @JsonKey(name: 'text') String text,
    @JsonKey(name: 'phonetic') String? phonetic,
    @JsonKey(name: 'meaning') String? meaning,
    @JsonKey(name: 'example') String? example,
  });
}

/// @nodoc
class __$$WordResponseImplCopyWithImpl<$Res>
    extends _$WordResponseCopyWithImpl<$Res, _$WordResponseImpl>
    implements _$$WordResponseImplCopyWith<$Res> {
  __$$WordResponseImplCopyWithImpl(
    _$WordResponseImpl _value,
    $Res Function(_$WordResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WordResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordBookId = null,
    Object? text = null,
    Object? phonetic = freezed,
    Object? meaning = freezed,
    Object? example = freezed,
  }) {
    return _then(
      _$WordResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        wordBookId: null == wordBookId
            ? _value.wordBookId
            : wordBookId // ignore: cast_nullable_to_non_nullable
                  as int,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        phonetic: freezed == phonetic
            ? _value.phonetic
            : phonetic // ignore: cast_nullable_to_non_nullable
                  as String?,
        meaning: freezed == meaning
            ? _value.meaning
            : meaning // ignore: cast_nullable_to_non_nullable
                  as String?,
        example: freezed == example
            ? _value.example
            : example // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordResponseImpl implements _WordResponse {
  const _$WordResponseImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'word_book_id') required this.wordBookId,
    @JsonKey(name: 'text') required this.text,
    @JsonKey(name: 'phonetic') this.phonetic,
    @JsonKey(name: 'meaning') this.meaning,
    @JsonKey(name: 'example') this.example,
  });

  factory _$WordResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordResponseImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'word_book_id')
  final int wordBookId;
  @override
  @JsonKey(name: 'text')
  final String text;
  @override
  @JsonKey(name: 'phonetic')
  final String? phonetic;
  @override
  @JsonKey(name: 'meaning')
  final String? meaning;
  @override
  @JsonKey(name: 'example')
  final String? example;

  @override
  String toString() {
    return 'WordResponse(id: $id, wordBookId: $wordBookId, text: $text, phonetic: $phonetic, meaning: $meaning, example: $example)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.wordBookId, wordBookId) ||
                other.wordBookId == wordBookId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.phonetic, phonetic) ||
                other.phonetic == phonetic) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.example, example) || other.example == example));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    wordBookId,
    text,
    phonetic,
    meaning,
    example,
  );

  /// Create a copy of WordResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordResponseImplCopyWith<_$WordResponseImpl> get copyWith =>
      __$$WordResponseImplCopyWithImpl<_$WordResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordResponseImplToJson(this);
  }
}

abstract class _WordResponse implements WordResponse {
  const factory _WordResponse({
    @JsonKey(name: 'id') required final int id,
    @JsonKey(name: 'word_book_id') required final int wordBookId,
    @JsonKey(name: 'text') required final String text,
    @JsonKey(name: 'phonetic') final String? phonetic,
    @JsonKey(name: 'meaning') final String? meaning,
    @JsonKey(name: 'example') final String? example,
  }) = _$WordResponseImpl;

  factory _WordResponse.fromJson(Map<String, dynamic> json) =
      _$WordResponseImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'word_book_id')
  int get wordBookId;
  @override
  @JsonKey(name: 'text')
  String get text;
  @override
  @JsonKey(name: 'phonetic')
  String? get phonetic;
  @override
  @JsonKey(name: 'meaning')
  String? get meaning;
  @override
  @JsonKey(name: 'example')
  String? get example;

  /// Create a copy of WordResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordResponseImplCopyWith<_$WordResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewRecordDto _$ReviewRecordDtoFromJson(Map<String, dynamic> json) {
  return _ReviewRecordDto.fromJson(json);
}

/// @nodoc
mixin _$ReviewRecordDto {
  @JsonKey(name: 'word_book_id')
  int get wordBookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'word_id')
  int get wordId => throw _privateConstructorUsedError;
  @JsonKey(name: 'repetition_count')
  int get repetitionCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'easiness_factor')
  double get easinessFactor => throw _privateConstructorUsedError;
  @JsonKey(name: 'interval')
  int get interval => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_review_at')
  DateTime get nextReviewAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_review_at')
  DateTime? get lastReviewAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'learned')
  bool get learned => throw _privateConstructorUsedError;
  @JsonKey(name: 'mastery')
  double get mastery => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_updated_at')
  DateTime get clientUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewRecordDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewRecordDtoCopyWith<ReviewRecordDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewRecordDtoCopyWith<$Res> {
  factory $ReviewRecordDtoCopyWith(
    ReviewRecordDto value,
    $Res Function(ReviewRecordDto) then,
  ) = _$ReviewRecordDtoCopyWithImpl<$Res, ReviewRecordDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'word_book_id') int wordBookId,
    @JsonKey(name: 'word_id') int wordId,
    @JsonKey(name: 'repetition_count') int repetitionCount,
    @JsonKey(name: 'easiness_factor') double easinessFactor,
    @JsonKey(name: 'interval') int interval,
    @JsonKey(name: 'next_review_at') DateTime nextReviewAt,
    @JsonKey(name: 'last_review_at') DateTime? lastReviewAt,
    @JsonKey(name: 'learned') bool learned,
    @JsonKey(name: 'mastery') double mastery,
    @JsonKey(name: 'client_updated_at') DateTime clientUpdatedAt,
  });
}

/// @nodoc
class _$ReviewRecordDtoCopyWithImpl<$Res, $Val extends ReviewRecordDto>
    implements $ReviewRecordDtoCopyWith<$Res> {
  _$ReviewRecordDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordBookId = null,
    Object? wordId = null,
    Object? repetitionCount = null,
    Object? easinessFactor = null,
    Object? interval = null,
    Object? nextReviewAt = null,
    Object? lastReviewAt = freezed,
    Object? learned = null,
    Object? mastery = null,
    Object? clientUpdatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            wordBookId: null == wordBookId
                ? _value.wordBookId
                : wordBookId // ignore: cast_nullable_to_non_nullable
                      as int,
            wordId: null == wordId
                ? _value.wordId
                : wordId // ignore: cast_nullable_to_non_nullable
                      as int,
            repetitionCount: null == repetitionCount
                ? _value.repetitionCount
                : repetitionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            easinessFactor: null == easinessFactor
                ? _value.easinessFactor
                : easinessFactor // ignore: cast_nullable_to_non_nullable
                      as double,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            nextReviewAt: null == nextReviewAt
                ? _value.nextReviewAt
                : nextReviewAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastReviewAt: freezed == lastReviewAt
                ? _value.lastReviewAt
                : lastReviewAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            learned: null == learned
                ? _value.learned
                : learned // ignore: cast_nullable_to_non_nullable
                      as bool,
            mastery: null == mastery
                ? _value.mastery
                : mastery // ignore: cast_nullable_to_non_nullable
                      as double,
            clientUpdatedAt: null == clientUpdatedAt
                ? _value.clientUpdatedAt
                : clientUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewRecordDtoImplCopyWith<$Res>
    implements $ReviewRecordDtoCopyWith<$Res> {
  factory _$$ReviewRecordDtoImplCopyWith(
    _$ReviewRecordDtoImpl value,
    $Res Function(_$ReviewRecordDtoImpl) then,
  ) = __$$ReviewRecordDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'word_book_id') int wordBookId,
    @JsonKey(name: 'word_id') int wordId,
    @JsonKey(name: 'repetition_count') int repetitionCount,
    @JsonKey(name: 'easiness_factor') double easinessFactor,
    @JsonKey(name: 'interval') int interval,
    @JsonKey(name: 'next_review_at') DateTime nextReviewAt,
    @JsonKey(name: 'last_review_at') DateTime? lastReviewAt,
    @JsonKey(name: 'learned') bool learned,
    @JsonKey(name: 'mastery') double mastery,
    @JsonKey(name: 'client_updated_at') DateTime clientUpdatedAt,
  });
}

/// @nodoc
class __$$ReviewRecordDtoImplCopyWithImpl<$Res>
    extends _$ReviewRecordDtoCopyWithImpl<$Res, _$ReviewRecordDtoImpl>
    implements _$$ReviewRecordDtoImplCopyWith<$Res> {
  __$$ReviewRecordDtoImplCopyWithImpl(
    _$ReviewRecordDtoImpl _value,
    $Res Function(_$ReviewRecordDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordBookId = null,
    Object? wordId = null,
    Object? repetitionCount = null,
    Object? easinessFactor = null,
    Object? interval = null,
    Object? nextReviewAt = null,
    Object? lastReviewAt = freezed,
    Object? learned = null,
    Object? mastery = null,
    Object? clientUpdatedAt = null,
  }) {
    return _then(
      _$ReviewRecordDtoImpl(
        wordBookId: null == wordBookId
            ? _value.wordBookId
            : wordBookId // ignore: cast_nullable_to_non_nullable
                  as int,
        wordId: null == wordId
            ? _value.wordId
            : wordId // ignore: cast_nullable_to_non_nullable
                  as int,
        repetitionCount: null == repetitionCount
            ? _value.repetitionCount
            : repetitionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        easinessFactor: null == easinessFactor
            ? _value.easinessFactor
            : easinessFactor // ignore: cast_nullable_to_non_nullable
                  as double,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        nextReviewAt: null == nextReviewAt
            ? _value.nextReviewAt
            : nextReviewAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastReviewAt: freezed == lastReviewAt
            ? _value.lastReviewAt
            : lastReviewAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        learned: null == learned
            ? _value.learned
            : learned // ignore: cast_nullable_to_non_nullable
                  as bool,
        mastery: null == mastery
            ? _value.mastery
            : mastery // ignore: cast_nullable_to_non_nullable
                  as double,
        clientUpdatedAt: null == clientUpdatedAt
            ? _value.clientUpdatedAt
            : clientUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewRecordDtoImpl implements _ReviewRecordDto {
  const _$ReviewRecordDtoImpl({
    @JsonKey(name: 'word_book_id') required this.wordBookId,
    @JsonKey(name: 'word_id') required this.wordId,
    @JsonKey(name: 'repetition_count') required this.repetitionCount,
    @JsonKey(name: 'easiness_factor') required this.easinessFactor,
    @JsonKey(name: 'interval') required this.interval,
    @JsonKey(name: 'next_review_at') required this.nextReviewAt,
    @JsonKey(name: 'last_review_at') this.lastReviewAt,
    @JsonKey(name: 'learned') required this.learned,
    @JsonKey(name: 'mastery') required this.mastery,
    @JsonKey(name: 'client_updated_at') required this.clientUpdatedAt,
  });

  factory _$ReviewRecordDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewRecordDtoImplFromJson(json);

  @override
  @JsonKey(name: 'word_book_id')
  final int wordBookId;
  @override
  @JsonKey(name: 'word_id')
  final int wordId;
  @override
  @JsonKey(name: 'repetition_count')
  final int repetitionCount;
  @override
  @JsonKey(name: 'easiness_factor')
  final double easinessFactor;
  @override
  @JsonKey(name: 'interval')
  final int interval;
  @override
  @JsonKey(name: 'next_review_at')
  final DateTime nextReviewAt;
  @override
  @JsonKey(name: 'last_review_at')
  final DateTime? lastReviewAt;
  @override
  @JsonKey(name: 'learned')
  final bool learned;
  @override
  @JsonKey(name: 'mastery')
  final double mastery;
  @override
  @JsonKey(name: 'client_updated_at')
  final DateTime clientUpdatedAt;

  @override
  String toString() {
    return 'ReviewRecordDto(wordBookId: $wordBookId, wordId: $wordId, repetitionCount: $repetitionCount, easinessFactor: $easinessFactor, interval: $interval, nextReviewAt: $nextReviewAt, lastReviewAt: $lastReviewAt, learned: $learned, mastery: $mastery, clientUpdatedAt: $clientUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewRecordDtoImpl &&
            (identical(other.wordBookId, wordBookId) ||
                other.wordBookId == wordBookId) &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.repetitionCount, repetitionCount) ||
                other.repetitionCount == repetitionCount) &&
            (identical(other.easinessFactor, easinessFactor) ||
                other.easinessFactor == easinessFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.nextReviewAt, nextReviewAt) ||
                other.nextReviewAt == nextReviewAt) &&
            (identical(other.lastReviewAt, lastReviewAt) ||
                other.lastReviewAt == lastReviewAt) &&
            (identical(other.learned, learned) || other.learned == learned) &&
            (identical(other.mastery, mastery) || other.mastery == mastery) &&
            (identical(other.clientUpdatedAt, clientUpdatedAt) ||
                other.clientUpdatedAt == clientUpdatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    wordBookId,
    wordId,
    repetitionCount,
    easinessFactor,
    interval,
    nextReviewAt,
    lastReviewAt,
    learned,
    mastery,
    clientUpdatedAt,
  );

  /// Create a copy of ReviewRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewRecordDtoImplCopyWith<_$ReviewRecordDtoImpl> get copyWith =>
      __$$ReviewRecordDtoImplCopyWithImpl<_$ReviewRecordDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewRecordDtoImplToJson(this);
  }
}

abstract class _ReviewRecordDto implements ReviewRecordDto {
  const factory _ReviewRecordDto({
    @JsonKey(name: 'word_book_id') required final int wordBookId,
    @JsonKey(name: 'word_id') required final int wordId,
    @JsonKey(name: 'repetition_count') required final int repetitionCount,
    @JsonKey(name: 'easiness_factor') required final double easinessFactor,
    @JsonKey(name: 'interval') required final int interval,
    @JsonKey(name: 'next_review_at') required final DateTime nextReviewAt,
    @JsonKey(name: 'last_review_at') final DateTime? lastReviewAt,
    @JsonKey(name: 'learned') required final bool learned,
    @JsonKey(name: 'mastery') required final double mastery,
    @JsonKey(name: 'client_updated_at') required final DateTime clientUpdatedAt,
  }) = _$ReviewRecordDtoImpl;

  factory _ReviewRecordDto.fromJson(Map<String, dynamic> json) =
      _$ReviewRecordDtoImpl.fromJson;

  @override
  @JsonKey(name: 'word_book_id')
  int get wordBookId;
  @override
  @JsonKey(name: 'word_id')
  int get wordId;
  @override
  @JsonKey(name: 'repetition_count')
  int get repetitionCount;
  @override
  @JsonKey(name: 'easiness_factor')
  double get easinessFactor;
  @override
  @JsonKey(name: 'interval')
  int get interval;
  @override
  @JsonKey(name: 'next_review_at')
  DateTime get nextReviewAt;
  @override
  @JsonKey(name: 'last_review_at')
  DateTime? get lastReviewAt;
  @override
  @JsonKey(name: 'learned')
  bool get learned;
  @override
  @JsonKey(name: 'mastery')
  double get mastery;
  @override
  @JsonKey(name: 'client_updated_at')
  DateTime get clientUpdatedAt;

  /// Create a copy of ReviewRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewRecordDtoImplCopyWith<_$ReviewRecordDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewRecordSyncRequest _$ReviewRecordSyncRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ReviewRecordSyncRequest.fromJson(json);
}

/// @nodoc
mixin _$ReviewRecordSyncRequest {
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records => throw _privateConstructorUsedError;

  /// Serializes this ReviewRecordSyncRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewRecordSyncRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewRecordSyncRequestCopyWith<ReviewRecordSyncRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewRecordSyncRequestCopyWith<$Res> {
  factory $ReviewRecordSyncRequestCopyWith(
    ReviewRecordSyncRequest value,
    $Res Function(ReviewRecordSyncRequest) then,
  ) = _$ReviewRecordSyncRequestCopyWithImpl<$Res, ReviewRecordSyncRequest>;
  @useResult
  $Res call({@JsonKey(name: 'records') List<ReviewRecordDto> records});
}

/// @nodoc
class _$ReviewRecordSyncRequestCopyWithImpl<
  $Res,
  $Val extends ReviewRecordSyncRequest
>
    implements $ReviewRecordSyncRequestCopyWith<$Res> {
  _$ReviewRecordSyncRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewRecordSyncRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? records = null}) {
    return _then(
      _value.copyWith(
            records: null == records
                ? _value.records
                : records // ignore: cast_nullable_to_non_nullable
                      as List<ReviewRecordDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewRecordSyncRequestImplCopyWith<$Res>
    implements $ReviewRecordSyncRequestCopyWith<$Res> {
  factory _$$ReviewRecordSyncRequestImplCopyWith(
    _$ReviewRecordSyncRequestImpl value,
    $Res Function(_$ReviewRecordSyncRequestImpl) then,
  ) = __$$ReviewRecordSyncRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'records') List<ReviewRecordDto> records});
}

/// @nodoc
class __$$ReviewRecordSyncRequestImplCopyWithImpl<$Res>
    extends
        _$ReviewRecordSyncRequestCopyWithImpl<
          $Res,
          _$ReviewRecordSyncRequestImpl
        >
    implements _$$ReviewRecordSyncRequestImplCopyWith<$Res> {
  __$$ReviewRecordSyncRequestImplCopyWithImpl(
    _$ReviewRecordSyncRequestImpl _value,
    $Res Function(_$ReviewRecordSyncRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewRecordSyncRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? records = null}) {
    return _then(
      _$ReviewRecordSyncRequestImpl(
        records: null == records
            ? _value._records
            : records // ignore: cast_nullable_to_non_nullable
                  as List<ReviewRecordDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewRecordSyncRequestImpl implements _ReviewRecordSyncRequest {
  const _$ReviewRecordSyncRequestImpl({
    @JsonKey(name: 'records') required final List<ReviewRecordDto> records,
  }) : _records = records;

  factory _$ReviewRecordSyncRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewRecordSyncRequestImplFromJson(json);

  final List<ReviewRecordDto> _records;
  @override
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  String toString() {
    return 'ReviewRecordSyncRequest(records: $records)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewRecordSyncRequestImpl &&
            const DeepCollectionEquality().equals(other._records, _records));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_records));

  /// Create a copy of ReviewRecordSyncRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewRecordSyncRequestImplCopyWith<_$ReviewRecordSyncRequestImpl>
  get copyWith =>
      __$$ReviewRecordSyncRequestImplCopyWithImpl<
        _$ReviewRecordSyncRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewRecordSyncRequestImplToJson(this);
  }
}

abstract class _ReviewRecordSyncRequest implements ReviewRecordSyncRequest {
  const factory _ReviewRecordSyncRequest({
    @JsonKey(name: 'records') required final List<ReviewRecordDto> records,
  }) = _$ReviewRecordSyncRequestImpl;

  factory _ReviewRecordSyncRequest.fromJson(Map<String, dynamic> json) =
      _$ReviewRecordSyncRequestImpl.fromJson;

  @override
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records;

  /// Create a copy of ReviewRecordSyncRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewRecordSyncRequestImplCopyWith<_$ReviewRecordSyncRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReviewRecordSyncResponse _$ReviewRecordSyncResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ReviewRecordSyncResponse.fromJson(json);
}

/// @nodoc
mixin _$ReviewRecordSyncResponse {
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_time')
  DateTime get serverTime => throw _privateConstructorUsedError;

  /// Serializes this ReviewRecordSyncResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewRecordSyncResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewRecordSyncResponseCopyWith<ReviewRecordSyncResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewRecordSyncResponseCopyWith<$Res> {
  factory $ReviewRecordSyncResponseCopyWith(
    ReviewRecordSyncResponse value,
    $Res Function(ReviewRecordSyncResponse) then,
  ) = _$ReviewRecordSyncResponseCopyWithImpl<$Res, ReviewRecordSyncResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'records') List<ReviewRecordDto> records,
    @JsonKey(name: 'server_time') DateTime serverTime,
  });
}

/// @nodoc
class _$ReviewRecordSyncResponseCopyWithImpl<
  $Res,
  $Val extends ReviewRecordSyncResponse
>
    implements $ReviewRecordSyncResponseCopyWith<$Res> {
  _$ReviewRecordSyncResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewRecordSyncResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? records = null, Object? serverTime = null}) {
    return _then(
      _value.copyWith(
            records: null == records
                ? _value.records
                : records // ignore: cast_nullable_to_non_nullable
                      as List<ReviewRecordDto>,
            serverTime: null == serverTime
                ? _value.serverTime
                : serverTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewRecordSyncResponseImplCopyWith<$Res>
    implements $ReviewRecordSyncResponseCopyWith<$Res> {
  factory _$$ReviewRecordSyncResponseImplCopyWith(
    _$ReviewRecordSyncResponseImpl value,
    $Res Function(_$ReviewRecordSyncResponseImpl) then,
  ) = __$$ReviewRecordSyncResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'records') List<ReviewRecordDto> records,
    @JsonKey(name: 'server_time') DateTime serverTime,
  });
}

/// @nodoc
class __$$ReviewRecordSyncResponseImplCopyWithImpl<$Res>
    extends
        _$ReviewRecordSyncResponseCopyWithImpl<
          $Res,
          _$ReviewRecordSyncResponseImpl
        >
    implements _$$ReviewRecordSyncResponseImplCopyWith<$Res> {
  __$$ReviewRecordSyncResponseImplCopyWithImpl(
    _$ReviewRecordSyncResponseImpl _value,
    $Res Function(_$ReviewRecordSyncResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewRecordSyncResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? records = null, Object? serverTime = null}) {
    return _then(
      _$ReviewRecordSyncResponseImpl(
        records: null == records
            ? _value._records
            : records // ignore: cast_nullable_to_non_nullable
                  as List<ReviewRecordDto>,
        serverTime: null == serverTime
            ? _value.serverTime
            : serverTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewRecordSyncResponseImpl implements _ReviewRecordSyncResponse {
  const _$ReviewRecordSyncResponseImpl({
    @JsonKey(name: 'records') required final List<ReviewRecordDto> records,
    @JsonKey(name: 'server_time') required this.serverTime,
  }) : _records = records;

  factory _$ReviewRecordSyncResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewRecordSyncResponseImplFromJson(json);

  final List<ReviewRecordDto> _records;
  @override
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  @override
  String toString() {
    return 'ReviewRecordSyncResponse(records: $records, serverTime: $serverTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewRecordSyncResponseImpl &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.serverTime, serverTime) ||
                other.serverTime == serverTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_records),
    serverTime,
  );

  /// Create a copy of ReviewRecordSyncResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewRecordSyncResponseImplCopyWith<_$ReviewRecordSyncResponseImpl>
  get copyWith =>
      __$$ReviewRecordSyncResponseImplCopyWithImpl<
        _$ReviewRecordSyncResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewRecordSyncResponseImplToJson(this);
  }
}

abstract class _ReviewRecordSyncResponse implements ReviewRecordSyncResponse {
  const factory _ReviewRecordSyncResponse({
    @JsonKey(name: 'records') required final List<ReviewRecordDto> records,
    @JsonKey(name: 'server_time') required final DateTime serverTime,
  }) = _$ReviewRecordSyncResponseImpl;

  factory _ReviewRecordSyncResponse.fromJson(Map<String, dynamic> json) =
      _$ReviewRecordSyncResponseImpl.fromJson;

  @override
  @JsonKey(name: 'records')
  List<ReviewRecordDto> get records;
  @override
  @JsonKey(name: 'server_time')
  DateTime get serverTime;

  /// Create a copy of ReviewRecordSyncResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewRecordSyncResponseImplCopyWith<_$ReviewRecordSyncResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
