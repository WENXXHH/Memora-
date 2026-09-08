import 'package:flutter/material.dart';

/// 删除词库的二次确认对话框。
class CustomWordBookDeleteDialog extends StatelessWidget {
  const CustomWordBookDeleteDialog({
    super.key,
    required this.bookName,
    required this.onCancel,
    required this.onConfirm,
  });

  /// 待删除的词库名（可能为空，仅影响提示文案）。
  final String bookName;

  /// 取消回调。
  final VoidCallback onCancel;

  /// 确认删除回调。
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('删除词库？'),
      content: Text(
        '「$bookName」中的所有单词及本地学习进度都会被删除，'
        '此操作不可撤销。',
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('取消')),
        FilledButton(onPressed: onConfirm, child: const Text('删除')),
      ],
    );
  }
}
