import 'package:flutter/material.dart';

/// 词库暂无单词时的空状态视图：提示 + "添加单词"按钮。
class CustomWordBookEmptyView extends StatelessWidget {
  const CustomWordBookEmptyView({super.key, required this.onAdd});

  /// "添加单词"按钮回调。
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('还没有单词，点击右上角添加', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('添加单词'),
          ),
        ],
      ),
    );
  }
}
