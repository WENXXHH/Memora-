import 'package:flutter/material.dart';

/// 自建单词 / 词库表单页的提交按钮：
/// 提交中禁用并展示转圈，其余展示按钮文案。
class CustomWordFormSubmitButton extends StatelessWidget {
  const CustomWordFormSubmitButton({
    super.key,
    required this.submitting,
    required this.label,
    required this.onSubmit,
  });

  /// 是否提交中（提交中禁用并展示转圈）。
  final bool submitting;

  /// 按钮文案。
  final String label;

  /// 提交回调。
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: submitting ? null : onSubmit,
      child: submitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
