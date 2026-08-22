import '../../data/dto/review_record_dto.dart';
import '../../data/dto/word_model.dart';

/// 单词 ID 双向映射表（String ↔ int）。
///
/// 解决 Flutter 端 wordId（String，如 "1"）与后端 Word 主键
/// （int，如 1）的命名空间不一致问题（doc 0 ID 边界转换策略）。
///
/// 构建规则：按英文单词文本（text/word）匹配。
/// - Flutter [Word.word]（如 "abandon"）↔ 后端 [WordResponse.text]（如 "abandon"）
/// - 匹配后建立 Flutter String id ↔ 后端 int id 映射
///
/// 即使两端自增 ID 起点不同，按文本匹配也能正确对齐。
/// 映射表在单次同步内稳定，不持久化。
class WordIdMap {
  WordIdMap._(this._stringToInt, this._intToString);

  final Map<String, int> _stringToInt;
  final Map<int, String> _intToString;

  /// 从后端单词列表 + 本地单词列表构建映射。
  ///
  /// 匹配规则：后端 [WordResponse.text] == 本地 [Word.word]。
  /// 匹配后建立 local.id (String) ↔ remote.id (int) 映射。
  factory WordIdMap.fromWords({
    required List<WordResponse> remoteWords,
    required List<Word> localWords,
  }) {
    final stringToInt = <String, int>{};
    final intToString = <int, String>{};

    // 后端 text → int id 的索引
    final remoteByText = <String, int>{
      for (final w in remoteWords) w.text: w.id,
    };

    for (final local in localWords) {
      final remoteId = remoteByText[local.word];
      if (remoteId != null) {
        stringToInt[local.id] = remoteId;
        intToString[remoteId] = local.id;
      }
    }
    return WordIdMap._(stringToInt, intToString);
  }

  /// String wordId → int（映射缺失时返回 null）。
  int? stringToInt(String wordId) => _stringToInt[wordId];

  /// int wordId → String（映射缺失时返回 null）。
  String? intToString(int wordId) => _intToString[wordId];
}
