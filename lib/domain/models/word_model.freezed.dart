// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MeaningEntry _$MeaningEntryFromJson(Map<String, dynamic> json) {
  return _MeaningEntry.fromJson(json);
}

/// @nodoc
mixin _$MeaningEntry {
  /// 词性：v.（动词）、n.（名词）、adj.（形容词）、adv.（副词）等
  String get pos => throw _privateConstructorUsedError;

  /// 该词性下的多个中文释义
  List<String> get definitions => throw _privateConstructorUsedError;

  /// Serializes this MeaningEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeaningEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeaningEntryCopyWith<MeaningEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeaningEntryCopyWith<$Res> {
  factory $MeaningEntryCopyWith(
    MeaningEntry value,
    $Res Function(MeaningEntry) then,
  ) = _$MeaningEntryCopyWithImpl<$Res, MeaningEntry>;
  @useResult
  $Res call({String pos, List<String> definitions});
}

/// @nodoc
class _$MeaningEntryCopyWithImpl<$Res, $Val extends MeaningEntry>
    implements $MeaningEntryCopyWith<$Res> {
  _$MeaningEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeaningEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pos = null, Object? definitions = null}) {
    return _then(
      _value.copyWith(
            pos: null == pos
                ? _value.pos
                : pos // ignore: cast_nullable_to_non_nullable
                      as String,
            definitions: null == definitions
                ? _value.definitions
                : definitions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeaningEntryImplCopyWith<$Res>
    implements $MeaningEntryCopyWith<$Res> {
  factory _$$MeaningEntryImplCopyWith(
    _$MeaningEntryImpl value,
    $Res Function(_$MeaningEntryImpl) then,
  ) = __$$MeaningEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pos, List<String> definitions});
}

/// @nodoc
class __$$MeaningEntryImplCopyWithImpl<$Res>
    extends _$MeaningEntryCopyWithImpl<$Res, _$MeaningEntryImpl>
    implements _$$MeaningEntryImplCopyWith<$Res> {
  __$$MeaningEntryImplCopyWithImpl(
    _$MeaningEntryImpl _value,
    $Res Function(_$MeaningEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeaningEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pos = null, Object? definitions = null}) {
    return _then(
      _$MeaningEntryImpl(
        pos: null == pos
            ? _value.pos
            : pos // ignore: cast_nullable_to_non_nullable
                  as String,
        definitions: null == definitions
            ? _value._definitions
            : definitions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeaningEntryImpl implements _MeaningEntry {
  const _$MeaningEntryImpl({
    required this.pos,
    required final List<String> definitions,
  }) : _definitions = definitions;

  factory _$MeaningEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeaningEntryImplFromJson(json);

  /// 词性：v.（动词）、n.（名词）、adj.（形容词）、adv.（副词）等
  @override
  final String pos;

  /// 该词性下的多个中文释义
  final List<String> _definitions;

  /// 该词性下的多个中文释义
  @override
  List<String> get definitions {
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_definitions);
  }

  @override
  String toString() {
    return 'MeaningEntry(pos: $pos, definitions: $definitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeaningEntryImpl &&
            (identical(other.pos, pos) || other.pos == pos) &&
            const DeepCollectionEquality().equals(
              other._definitions,
              _definitions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pos,
    const DeepCollectionEquality().hash(_definitions),
  );

  /// Create a copy of MeaningEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeaningEntryImplCopyWith<_$MeaningEntryImpl> get copyWith =>
      __$$MeaningEntryImplCopyWithImpl<_$MeaningEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeaningEntryImplToJson(this);
  }
}

abstract class _MeaningEntry implements MeaningEntry {
  const factory _MeaningEntry({
    required final String pos,
    required final List<String> definitions,
  }) = _$MeaningEntryImpl;

  factory _MeaningEntry.fromJson(Map<String, dynamic> json) =
      _$MeaningEntryImpl.fromJson;

  /// 词性：v.（动词）、n.（名词）、adj.（形容词）、adv.（副词）等
  @override
  String get pos;

  /// 该词性下的多个中文释义
  @override
  List<String> get definitions;

  /// Create a copy of MeaningEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeaningEntryImplCopyWith<_$MeaningEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Word _$WordFromJson(Map<String, dynamic> json) {
  return _Word.fromJson(json);
}

/// @nodoc
mixin _$Word {
  /// 单词唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 英文单词
  String get word => throw _privateConstructorUsedError;

  /// 音标（英式发音）
  String get phonetic => throw _privateConstructorUsedError;

  /// 释义列表（支持多词性）
  List<MeaningEntry> get meaning => throw _privateConstructorUsedError;

  /// 例句列表（与词性对应）
  List<String> get example => throw _privateConstructorUsedError;

  /// 音频文件路径（预留，后期接入TTS）
  String get audio => throw _privateConstructorUsedError;

  /// 词库ID（用于多词库隔离，如 cet6、cet4、自定义词库ID）
  String get wordBookId => throw _privateConstructorUsedError;

  /// Serializes this Word to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordCopyWith<Word> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordCopyWith<$Res> {
  factory $WordCopyWith(Word value, $Res Function(Word) then) =
      _$WordCopyWithImpl<$Res, Word>;
  @useResult
  $Res call({
    String id,
    String word,
    String phonetic,
    List<MeaningEntry> meaning,
    List<String> example,
    String audio,
    String wordBookId,
  });
}

/// @nodoc
class _$WordCopyWithImpl<$Res, $Val extends Word>
    implements $WordCopyWith<$Res> {
  _$WordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? phonetic = null,
    Object? meaning = null,
    Object? example = null,
    Object? audio = null,
    Object? wordBookId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
            audio: null == audio
                ? _value.audio
                : audio // ignore: cast_nullable_to_non_nullable
                      as String,
            wordBookId: null == wordBookId
                ? _value.wordBookId
                : wordBookId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordImplCopyWith<$Res> implements $WordCopyWith<$Res> {
  factory _$$WordImplCopyWith(
    _$WordImpl value,
    $Res Function(_$WordImpl) then,
  ) = __$$WordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String word,
    String phonetic,
    List<MeaningEntry> meaning,
    List<String> example,
    String audio,
    String wordBookId,
  });
}

/// @nodoc
class __$$WordImplCopyWithImpl<$Res>
    extends _$WordCopyWithImpl<$Res, _$WordImpl>
    implements _$$WordImplCopyWith<$Res> {
  __$$WordImplCopyWithImpl(_$WordImpl _value, $Res Function(_$WordImpl) _then)
    : super(_value, _then);

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? phonetic = null,
    Object? meaning = null,
    Object? example = null,
    Object? audio = null,
    Object? wordBookId = null,
  }) {
    return _then(
      _$WordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
        audio: null == audio
            ? _value.audio
            : audio // ignore: cast_nullable_to_non_nullable
                  as String,
        wordBookId: null == wordBookId
            ? _value.wordBookId
            : wordBookId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordImpl implements _Word {
  const _$WordImpl({
    required this.id,
    required this.word,
    required this.phonetic,
    required final List<MeaningEntry> meaning,
    required final List<String> example,
    required this.audio,
    required this.wordBookId,
  }) : _meaning = meaning,
       _example = example;

  factory _$WordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordImplFromJson(json);

  /// 单词唯一标识
  @override
  final String id;

  /// 英文单词
  @override
  final String word;

  /// 音标（英式发音）
  @override
  final String phonetic;

  /// 释义列表（支持多词性）
  final List<MeaningEntry> _meaning;

  /// 释义列表（支持多词性）
  @override
  List<MeaningEntry> get meaning {
    if (_meaning is EqualUnmodifiableListView) return _meaning;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meaning);
  }

  /// 例句列表（与词性对应）
  final List<String> _example;

  /// 例句列表（与词性对应）
  @override
  List<String> get example {
    if (_example is EqualUnmodifiableListView) return _example;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_example);
  }

  /// 音频文件路径（预留，后期接入TTS）
  @override
  final String audio;

  /// 词库ID（用于多词库隔离，如 cet6、cet4、自定义词库ID）
  @override
  final String wordBookId;

  @override
  String toString() {
    return 'Word(id: $id, word: $word, phonetic: $phonetic, meaning: $meaning, example: $example, audio: $audio, wordBookId: $wordBookId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.phonetic, phonetic) ||
                other.phonetic == phonetic) &&
            const DeepCollectionEquality().equals(other._meaning, _meaning) &&
            const DeepCollectionEquality().equals(other._example, _example) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.wordBookId, wordBookId) ||
                other.wordBookId == wordBookId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    word,
    phonetic,
    const DeepCollectionEquality().hash(_meaning),
    const DeepCollectionEquality().hash(_example),
    audio,
    wordBookId,
  );

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      __$$WordImplCopyWithImpl<_$WordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordImplToJson(this);
  }
}

abstract class _Word implements Word {
  const factory _Word({
    required final String id,
    required final String word,
    required final String phonetic,
    required final List<MeaningEntry> meaning,
    required final List<String> example,
    required final String audio,
    required final String wordBookId,
  }) = _$WordImpl;

  factory _Word.fromJson(Map<String, dynamic> json) = _$WordImpl.fromJson;

  /// 单词唯一标识
  @override
  String get id;

  /// 英文单词
  @override
  String get word;

  /// 音标（英式发音）
  @override
  String get phonetic;

  /// 释义列表（支持多词性）
  @override
  List<MeaningEntry> get meaning;

  /// 例句列表（与词性对应）
  @override
  List<String> get example;

  /// 音频文件路径（预留，后期接入TTS）
  @override
  String get audio;

  /// 词库ID（用于多词库隔离，如 cet6、cet4、自定义词库ID）
  @override
  String get wordBookId;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
