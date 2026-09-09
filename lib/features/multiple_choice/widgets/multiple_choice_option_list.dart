import 'package:flutter/material.dart';

import 'option_button.dart';

/// 选择题选项列表：把 4 个中文释义渲染为 [OptionButton]。
class MultipleChoiceOptionList extends StatelessWidget {
  const MultipleChoiceOptionList({
    super.key,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  /// 4 个选项的中文释义文本。
  final List<String> options;

  /// 正确答案在 [options] 中的索引（0-3）。
  final int correctIndex;

  /// 用户选中的选项索引（未作答为 null）。
  final int? selectedIndex;

  /// 当前题是否已作答。
  final bool hasAnswered;

  /// 点击某选项的回调，参数为选项索引（仅在未作答时触发）。
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final optionText = entry.value;
        final isCorrect = index == correctIndex;
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OptionButton(
            text: optionText,
            index: index,
            isCorrect: isCorrect,
            isSelected: isSelected,
            hasAnswered: hasAnswered,
            onTap: () => onSelect(index),
          ),
        );
      }).toList(),
    );
  }
}
