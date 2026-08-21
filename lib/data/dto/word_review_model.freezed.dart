// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WordReview _$WordReviewFromJson(Map<String, dynamic> json) {
  return _WordReview.fromJson(json);
}

/// @nodoc
mixin _$WordReview {
  String get wordId => throw _privateConstructorUsedError;
  String get wordBookId => throw _privateConstructorUsedError;
  int get repetitionCount => throw _privateConstructorUsedError;
  double get easinessFactor => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  DateTime get nextReviewDate => throw _privateConstructorUsedError;
  DateTime? get lastReviewDate => throw _privateConstructorUsedError;
  bool get learned => throw _privateConstructorUsedError;
  double get mastery => throw _privateConstructorUsedError;

  /// Serializes this WordReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordReviewCopyWith<WordReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordReviewCopyWith<$Res> {
  factory $WordReviewCopyWith(
    WordReview value,
    $Res Function(WordReview) then,
  ) = _$WordReviewCopyWithImpl<$Res, WordReview>;
  @useResult
  $Res call({
    String wordId,
    String wordBookId,
    int repetitionCount,
    double easinessFactor,
    int interval,
    DateTime nextReviewDate,
    DateTime? lastReviewDate,
    bool learned,
    double mastery,
  });
}

/// @nodoc
class _$WordReviewCopyWithImpl<$Res, $Val extends WordReview>
    implements $WordReviewCopyWith<$Res> {
  _$WordReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? wordBookId = null,
    Object? repetitionCount = null,
    Object? easinessFactor = null,
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? lastReviewDate = freezed,
    Object? learned = null,
    Object? mastery = null,
  }) {
    return _then(
      _value.copyWith(
            wordId: null == wordId
                ? _value.wordId
                : wordId // ignore: cast_nullable_to_non_nullable
                      as String,
            wordBookId: null == wordBookId
                ? _value.wordBookId
                : wordBookId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            nextReviewDate: null == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastReviewDate: freezed == lastReviewDate
                ? _value.lastReviewDate
                : lastReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            learned: null == learned
                ? _value.learned
                : learned // ignore: cast_nullable_to_non_nullable
                      as bool,
            mastery: null == mastery
                ? _value.mastery
                : mastery // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordReviewImplCopyWith<$Res>
    implements $WordReviewCopyWith<$Res> {
  factory _$$WordReviewImplCopyWith(
    _$WordReviewImpl value,
    $Res Function(_$WordReviewImpl) then,
  ) = __$$WordReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String wordId,
    String wordBookId,
    int repetitionCount,
    double easinessFactor,
    int interval,
    DateTime nextReviewDate,
    DateTime? lastReviewDate,
    bool learned,
    double mastery,
  });
}

/// @nodoc
class __$$WordReviewImplCopyWithImpl<$Res>
    extends _$WordReviewCopyWithImpl<$Res, _$WordReviewImpl>
    implements _$$WordReviewImplCopyWith<$Res> {
  __$$WordReviewImplCopyWithImpl(
    _$WordReviewImpl _value,
    $Res Function(_$WordReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WordReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? wordBookId = null,
    Object? repetitionCount = null,
    Object? easinessFactor = null,
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? lastReviewDate = freezed,
    Object? learned = null,
    Object? mastery = null,
  }) {
    return _then(
      _$WordReviewImpl(
        wordId: null == wordId
            ? _value.wordId
            : wordId // ignore: cast_nullable_to_non_nullable
                  as String,
        wordBookId: null == wordBookId
            ? _value.wordBookId
            : wordBookId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        nextReviewDate: null == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastReviewDate: freezed == lastReviewDate
            ? _value.lastReviewDate
            : lastReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        learned: null == learned
            ? _value.learned
            : learned // ignore: cast_nullable_to_non_nullable
                  as bool,
        mastery: null == mastery
            ? _value.mastery
            : mastery // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordReviewImpl implements _WordReview {
  const _$WordReviewImpl({
    required this.wordId,
    required this.wordBookId,
    required this.repetitionCount,
    required this.easinessFactor,
    required this.interval,
    required this.nextReviewDate,
    required this.lastReviewDate,
    required this.learned,
    required this.mastery,
  });

  factory _$WordReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordReviewImplFromJson(json);

  @override
  final String wordId;
  @override
  final String wordBookId;
  @override
  final int repetitionCount;
  @override
  final double easinessFactor;
  @override
  final int interval;
  @override
  final DateTime nextReviewDate;
  @override
  final DateTime? lastReviewDate;
  @override
  final bool learned;
  @override
  final double mastery;

  @override
  String toString() {
    return 'WordReview(wordId: $wordId, wordBookId: $wordBookId, repetitionCount: $repetitionCount, easinessFactor: $easinessFactor, interval: $interval, nextReviewDate: $nextReviewDate, lastReviewDate: $lastReviewDate, learned: $learned, mastery: $mastery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordReviewImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.wordBookId, wordBookId) ||
                other.wordBookId == wordBookId) &&
            (identical(other.repetitionCount, repetitionCount) ||
                other.repetitionCount == repetitionCount) &&
            (identical(other.easinessFactor, easinessFactor) ||
                other.easinessFactor == easinessFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.lastReviewDate, lastReviewDate) ||
                other.lastReviewDate == lastReviewDate) &&
            (identical(other.learned, learned) || other.learned == learned) &&
            (identical(other.mastery, mastery) || other.mastery == mastery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    wordId,
    wordBookId,
    repetitionCount,
    easinessFactor,
    interval,
    nextReviewDate,
    lastReviewDate,
    learned,
    mastery,
  );

  /// Create a copy of WordReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordReviewImplCopyWith<_$WordReviewImpl> get copyWith =>
      __$$WordReviewImplCopyWithImpl<_$WordReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordReviewImplToJson(this);
  }
}

abstract class _WordReview implements WordReview {
  const factory _WordReview({
    required final String wordId,
    required final String wordBookId,
    required final int repetitionCount,
    required final double easinessFactor,
    required final int interval,
    required final DateTime nextReviewDate,
    required final DateTime? lastReviewDate,
    required final bool learned,
    required final double mastery,
  }) = _$WordReviewImpl;

  factory _WordReview.fromJson(Map<String, dynamic> json) =
      _$WordReviewImpl.fromJson;

  @override
  String get wordId;
  @override
  String get wordBookId;
  @override
  int get repetitionCount;
  @override
  double get easinessFactor;
  @override
  int get interval;
  @override
  DateTime get nextReviewDate;
  @override
  DateTime? get lastReviewDate;
  @override
  bool get learned;
  @override
  double get mastery;

  /// Create a copy of WordReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordReviewImplCopyWith<_$WordReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
