import 'package:flutter/material.dart';

/// 选择题选项按钮。
///
/// 颜色规则（约束 18）：
/// - 未作答：普通背景
/// - 作答后：
///   - 正确选项 → 绿色
///   - 用户选中的错误选项 → 红色
///   - 其他选项 → 灰色（dimmed）
///
/// 不复用 [FeedbackButton]：显示内容（释义 vs 反馈文字）和颜色规则不同。
/// 动画模式（AnimatedScale + AnimatedContainer + InkWell）参考 feedback_button.dart。
class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isCorrect,
    required this.isSelected,
    required this.hasAnswered,
    required this.onTap,
  });

  /// 选项释义文本。
  final String text;

  /// 选项索引（A=0, B=1, C=2, D=3）。
  final int index;

  /// 此选项是否是正确答案。
  final bool isCorrect;

  /// 用户是否选中了此选项。
  final bool isSelected;

  /// 当前题是否已作答。
  final bool hasAnswered;

  /// 点击回调（仅在未作答时有效）。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final letter = String.fromCharCode(0x41 + index); // A, B, C, D

    // 颜色规则（约束 18）
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;
    IconData? icon;

    if (!hasAnswered) {
      // 未作答：普通背景
      backgroundColor = colorScheme.surfaceContainerHighest;
      foregroundColor = colorScheme.onSurface;
      borderColor = Colors.transparent;
    } else if (isCorrect) {
      // 正确答案 → 绿色
      backgroundColor = Colors.green.withValues(alpha: 0.15);
      foregroundColor = Colors.green.shade700;
      borderColor = Colors.green;
      icon = Icons.check_circle;
    } else if (isSelected) {
      // 用户选中的错误选项 → 红色
      backgroundColor = Colors.red.withValues(alpha: 0.15);
      foregroundColor = Colors.red.shade700;
      borderColor = Colors.red;
      icon = Icons.cancel;
    } else {
      // 其他选项 → 灰色（dimmed）
      backgroundColor = colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      );
      foregroundColor = colorScheme.onSurface.withValues(alpha: 0.4);
      borderColor = Colors.transparent;
    }

    return AnimatedScale(
      scale: isSelected && hasAnswered ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: hasAnswered ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  // 选项字母 A/B/C/D
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: foregroundColor.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 释义文本
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: foregroundColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // 对错图标（作答后显示）
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: foregroundColor, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
