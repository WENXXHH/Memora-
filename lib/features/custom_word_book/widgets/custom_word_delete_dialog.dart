import 'package:flutter/material.dart';

/// 删除单词的二次确认对话框。
class CustomWordDeleteDialog extends StatelessWidget {
  const CustomWordDeleteDialog({
    super.key,
    required this.word,
    required this.onCancel,
    required this.onConfirm,
  });

  /// 待删除的单词。
  final String word;

  /// 取消回调。
  final VoidCallback onCancel;

  /// 确认删除回调。
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除单词？'),
      content: Text('删除「$word」？该单词的学习进度也会被删除。'),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('取消')),
        FilledButton(onPressed: onConfirm, child: const Text('删除')),
      ],
    );
  }
}
