/// 拼写答案匹配器（纯函数，不依赖 Flutter / Riverpod / Hive）。
///
/// 拼写模式第一版只允许 trim + toLowerCase（doc §6 / §7）：
/// - "abandon" / "ABANDON" / "Abandon" / "  abandon" / "abandon  " 均判正确
/// - 错一个字母 / 少一个字母 / 多一个字母 / 内部多空格 均判错误
/// - 不做模糊匹配、编辑距离、忽略标点等"智能容错"，
///   否则拼写复习模式本身失去意义。
library;

abstract final class SpellingAnswerMatcher {
  /// 规范化输入：先 trim（去前后空格）再 toLowerCase（统一大小写）。
  static String normalize(String value) {
    return value.trim().toLowerCase();
  }

  /// 判断用户输入是否等于正确答案（规范化后比较）。
  static bool isCorrect({
    required String input,
    required String answer,
  }) {
    return normalize(input) == normalize(answer);
  }
}
