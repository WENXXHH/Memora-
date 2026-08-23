import '../../data/dto/review_record_dto.dart';

/// 词库 ID 双向映射表（String ↔ int）。
///
/// 解决 Flutter 端 wordBookId（String，如 "cet6"）与后端 WordBook 主键
/// （int，如 1）的类型不匹配问题（doc 0 ID 边界转换策略）。
///
/// 构建规则：按后端 [WordBookResponse.name] 规范化后匹配。
/// 例如 "CET-6" → 规范化为 "cet6" → 与 Flutter "cet6" 匹配。
///
/// 映射表在单次同步内稳定，不持久化。第六周只处理内置 CET-6 词库。
class WordBookIdMap {
  WordBookIdMap._(this._stringToInt, this._intToString);

  final Map<String, int> _stringToInt;
  final Map<int, String> _intToString;

  /// 从后端词库列表构建映射。
  ///
  /// 匹配规则：规范化 name（小写 + 移除非字母数字字符）作为 Flutter 端 key。
  /// 例如 "CET-6" → "cet6"，"CET_4" → "cet4"。
  factory WordBookIdMap.fromBooks(List<WordBookResponse> remoteBooks) {
    final stringToInt = <String, int>{};
    final intToString = <int, String>{};
    for (final book in remoteBooks) {
      final key = _normalizeName(book.name);
      stringToInt[key] = book.id;
      intToString[book.id] = key;
    }
    return WordBookIdMap._(stringToInt, intToString);
  }

  /// String wordBookId → int（映射缺失时返回 null）。
  int? stringToInt(String wordBookId) => _stringToInt[wordBookId];

  /// int wordBookId → String（映射缺失时返回 null）。
  String? intToString(int wordBookId) => _intToString[wordBookId];

  /// 规范化词库名称：小写 + 仅保留字母数字。
  /// "CET-6" → "cet6"，"CET_4" → "cet4"，"TOEFL" → "toefl"。
  static String _normalizeName(String name) {
    final lowered = name.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lowered.runes) {
      if ((char >= 0x30 && char <= 0x39) || // 0-9
          (char >= 0x61 && char <= 0x7A)) { // a-z
        buffer.writeCharCode(char);
      }
    }
    return buffer.toString();
  }
}
