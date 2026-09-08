import 'package:flutter/material.dart';

import '../../multiple_choice/widgets/option_button.dart';

/// 听音辨词选项列表（中文释义四选一）。
///
/// 题目、对错与选中状态由构造参数传入，点击通过 [onSelect] 上抛下标，
/// 不感知 Controller / 音频等页面逻辑。
class ListeningOptions extends StatelessWidget {
  const ListeningOptions({
    super.key,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  /// 各选项释义文本（A=0, B=1, C=2, D=3）。
  final List<String> options;

  /// 正确答案下标。
  final int correctIndex;

  /// 用户选中的下标（未作答时为 null）。
  final int? selectedIndex;

  /// 当前题是否已作答。
  final bool hasAnswered;

  /// 点击某选项的回调（携带下标，未作答时才触发）。
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
