import 'package:flutter/material.dart';

import '../../../domain/models/custom_word_book_model.dart';

/// 自建词库管理页中的单条词库卡片：
/// 展示词库名，点击进入详情页，⋮ 菜单提供重命名 / 删除入口。
class CustomWordBookTile extends StatelessWidget {
  const CustomWordBookTile({
    super.key,
    required this.book,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  /// 词库数据。
  final CustomWordBook book;

  /// 点击进入详情页回调。
  final VoidCallback onOpen;

  /// 重命名回调。
  final VoidCallback onRename;

  /// 删除回调。
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.menu_book, color: colorScheme.primary),
        title: Text(book.name),
        subtitle: const Text('自建词库'),
        // 点击进入详情页管理单词
        onTap: onOpen,
        trailing: PopupMenuButton<String>(
          tooltip: '更多操作',
          onSelected: (value) {
            switch (value) {
              case 'rename':
                onRename();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'rename', child: Text('重命名')),
            PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
      ),
    );
  }
}
