import 'package:flutter/material.dart';

/// 自建词库管理页的词库列表为空时的空状态视图：提示 + "新建词库"按钮。
class CustomWordBookListEmptyView extends StatelessWidget {
  const CustomWordBookListEmptyView({super.key, required this.onCreate});

  /// "新建词库"按钮回调。
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 48, color: colorScheme.outline),
          const SizedBox(height: 12),
          const Text('还没有自建词库', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('新建词库'),
          ),
        ],
      ),
    );
  }
}
