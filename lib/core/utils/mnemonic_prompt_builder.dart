import '../../domain/enums/learning_enums.dart';

/// AI Prompt 构建器（纯函数，无副作用）
///
/// 根据单词、释义、例句和用户反馈类型，
/// 构造结构化的助记 Prompt 文本。
///
/// 不依赖任何外部服务、网络、数据库或 UI 组件。
class MnemonicPromptBuilder {
  const MnemonicPromptBuilder();

  /// 反馈类型到中文标签的映射
  String _feedbackLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.known:
        return '认识';
      case FeedbackType.fuzzy:
        return '模糊';
      case FeedbackType.unknown:
        return '不认识';
    }
  }

  /// 构建助记 Prompt
  ///
  /// [word] 目标单词
  /// [meaning] 中文释义
  /// [example] 例句
  /// [feedbackType] 用户反馈类型
  String build({
    required String word,
    required String meaning,
    required String example,
    required FeedbackType feedbackType,
  }) {
    final feedbackLabel = _feedbackLabel(feedbackType);

    return '''
你是一名帮助中国大学生记忆英语单词的英语教师。

目标单词：$word
中文释义：$meaning
原例句：$example
用户反馈：$feedbackLabel

请生成简短助记内容，帮助学生记住这个单词。

要求：
1. 使用中文解释。
2. 不超过80个汉字。
3. 助记必须与单词拼写或语义相关。
4. 不得编造错误词义。
5. 不输出无关开场白。
6. 输出格式为：「联想：...」「例句：...」「提示：...」三部分。
''';
  }
}
