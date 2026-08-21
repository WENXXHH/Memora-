import 'word_model.dart';

/// 选择题题目模型。
///
/// 一道四选一选择题由以下部分组成：
/// - [correctWord]：被考查的单词（UI 展示英文拼写 + 音标）
/// - [options]：4 个中文释义选项（1 个正确 + 3 个干扰项）
/// - [correctIndex]：正确答案在 [options] 中的索引
///
/// 干扰项来自当前词库的其他单词，已按释义去重（Bug 8 防御）。
class MultipleChoiceQuestion {
  const MultipleChoiceQuestion({
    required this.correctWord,
    required this.options,
    required this.correctIndex,
  });

  /// 被考查的单词。
  final Word correctWord;

  /// 4 个选项的中文释义文本。
  final List<String> options;

  /// 正确答案在 [options] 中的索引（0-3）。
  final int correctIndex;

  /// 正确答案的释义文本。
  String get correctAnswer => options[correctIndex];
}
