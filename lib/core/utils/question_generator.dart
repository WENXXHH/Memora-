/// 选择题生成器（纯函数 + 注入 Random）。
///
/// 原则 17：QuestionGenerator 保持纯函数并注入 Random。
/// - 生产环境用 `Random()`
/// - 测试环境用 `Random(42)` 保证结果可重复
/// - 不进 DI 容器，调用方持有 Random 实例
library;

import 'dart:math';

import '../../data/dto/word_model.dart';
import '../../data/dto/multiple_choice_question.dart';

/// 选择题生成器。
///
/// 职责：
/// 1. 从词库中为指定单词生成一道四选一选择题
/// 2. 干扰项来自词库的其他单词（题目=待复习词，干扰项=整个词库）
/// 3. 处理 4 种边界情况（§2.5）：
///    - 词库不足 4 个不同释义 → 返回 null
///    - 多个单词释义相同 → 按释义文本去重
///    - 正确答案不进入干扰项 → 按 word.id + meaning 去重
///    - Fisher-Yates 打乱选项顺序
class QuestionGenerator {
  QuestionGenerator(this._random);

  final Random _random;

  /// 每道题的选项数（1 正确 + 3 干扰项）。
  static const int optionCount = 4;

  /// 为 [correctWord] 生成一道选择题。
  ///
  /// [allWords] 是当前词库的全部单词（干扰项池）。
  /// 返回 null 表示词库可用选项不足（边界情况 1）。
  MultipleChoiceQuestion? build({
    required Word correctWord,
    required List<Word> allWords,
  }) {
    // 正确答案的释义文本
    final correctMeaning = _formatMeaning(correctWord);

    // 步骤 1：过滤候选干扰项
    // - 排除正确单词本身（按 id）
    // - 排除与正确答案释义相同的单词（边界情况 3：正确答案不进入干扰项）
    final candidates = allWords.where((w) {
      if (w.id == correctWord.id) return false;
      if (_formatMeaning(w) == correctMeaning) return false;
      return true;
    }).toList();

    // 步骤 2：按释义文本去重（边界情况 2：多个单词释义相同）
    // 保留每个释义的第一个出现者
    final seen = <String>{correctMeaning}; // 正确答案也加入去重集
    final uniqueCandidates = <Word>[];
    for (final word in candidates) {
      final meaning = _formatMeaning(word);
      if (seen.add(meaning)) {
        uniqueCandidates.add(word);
      }
    }

    // 步骤 3：检查是否有足够的干扰项（边界情况 1）
    // 需要 optionCount - 1 = 3 个不同释义的干扰项
    if (uniqueCandidates.length < optionCount - 1) {
      return null; // 词库可用选项不足
    }

    // 步骤 4：随机抽取 3 个干扰项（Fisher-Yates 部分打乱）
    _shuffle(uniqueCandidates, _random);
    final distractors = uniqueCandidates.take(optionCount - 1).toList();

    // 步骤 5：组合正确答案 + 干扰项，Fisher-Yates 打乱
    final options = <String>[correctMeaning];
    for (final d in distractors) {
      options.add(_formatMeaning(d));
    }
    _shuffle(options, _random);

    // 步骤 6：找到正确答案在打乱后的位置
    final correctIndex = options.indexOf(correctMeaning);

    return MultipleChoiceQuestion(
      correctWord: correctWord,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// 格式化单词释义为显示文本。
  ///
  /// 多词性合并为 "v. 放弃、抛弃；n. 放纵" 格式。
  /// 此文本同时作为去重 key（Bug 8 防御）。
  String _formatMeaning(Word word) {
    return word.meaning
        .map((m) => '${m.pos} ${m.definitions.join('、')}')
        .join('；');
  }

  /// Fisher-Yates 原地打乱算法。
  void _shuffle<T>(List<T> list, Random random) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
