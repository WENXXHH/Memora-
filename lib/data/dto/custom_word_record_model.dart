import 'package:freezed_annotation/freezed_annotation.dart';

import 'word_model.dart';

part 'custom_word_record_model.freezed.dart';
part 'custom_word_record_model.g.dart';

/// 自建单词持久化记录（doc 10 / 11）。
///
/// 持久化层使用 CustomWordRecord，Repository 对外统一转换为
/// 现有 [Word]，使 Learning / MultipleChoice / Listening / Spelling
/// 等学习 Controller 完全不需要理解"自建"（doc 10）。
///
/// 字段以现有 [Word] 模型为兼容基准：
/// - wordId 使用 uuid（doc 19），不随内容变化
/// - word 保存 trim + lowercase 标准化结果（doc 44）
@freezed
class CustomWordRecord with _$CustomWordRecord {
  const factory CustomWordRecord({
    /// 单词 ID（uuid，doc 19），一旦创建不再变化。
    required String id,

    /// 所属自建词库 Domain ID（custom_<uuid>）。
    required String wordBookId,

    /// 英文单词（trim + lowercase 标准化，doc 44）。
    required String word,

    /// 音标（可选，缺省为空串）。
    required String phonetic,

    /// 释义列表（表单只输入中文，生成一条默认 MeaningEntry，doc 12）。
    required List<MeaningEntry> meaning,

    /// 例句列表（表单可选输入单条）。
    required List<String> example,

    /// 创建时间（本地）。
    required DateTime createdAt,

    /// 最后修改时间（本地）。
    required DateTime updatedAt,
  }) = _CustomWordRecord;

  factory CustomWordRecord.fromJson(Map<String, dynamic> json) =>
      _$CustomWordRecordFromJson(json);
}

/// CustomWordRecord → [Word] 的转换扩展（doc 10）。
///
/// 用 extension 而非类内方法：freezed 会把类内带方法体的成员
/// 当作抽象声明，导致生成类缺失实现。
extension CustomWordRecordX on CustomWordRecord {
  /// 转换为现有 [Word]（doc 10）。
  ///
  /// 自建单词无音频资源，audio 置空串；学习模式可走 TTS 兜底。
  Word toWord() {
    return Word(
      id: id,
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      audio: '',
      wordBookId: wordBookId,
    );
  }
}
