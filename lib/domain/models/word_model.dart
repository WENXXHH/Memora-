import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_model.freezed.dart';
part 'word_model.g.dart';

/// 单词释义条目（支持多词性多释义）
@freezed
class MeaningEntry with _$MeaningEntry {
  const factory MeaningEntry({
    /// 词性：v.（动词）、n.（名词）、adj.（形容词）、adv.（副词）等
    required String pos,

    /// 该词性下的多个中文释义
    required List<String> definitions,
  }) = _MeaningEntry;

  factory MeaningEntry.fromJson(Map<String, dynamic> json) =>
      _$MeaningEntryFromJson(json);
}

/// 单词数据模型
///
/// 对应 cet-6.json 的数据结构，支持：
/// - 多词性多释义（meaning字段为结构化数组）
/// - 多例句（example字段为数组）
/// - 词库隔离（wordBookId字段）
@freezed
class Word with _$Word {
  const factory Word({
    /// 单词唯一标识
    required String id,

    /// 英文单词
    required String word,

    /// 音标（英式发音）
    required String phonetic,

    /// 释义列表（支持多词性）
    required List<MeaningEntry> meaning,

    /// 例句列表（与词性对应）
    required List<String> example,

    /// 音频文件路径（预留，后期接入TTS）
    required String audio,

    /// 词库ID（用于多词库隔离，如 cet6、cet4、自定义词库ID）
    required String wordBookId,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
