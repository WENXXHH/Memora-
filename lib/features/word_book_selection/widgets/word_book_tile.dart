import 'package:flutter/material.dart';

import '../../../core/utils/built_in_word_books.dart';

/// 词库列表项组件（doc 19 / 20 / 21）。
///
/// 只展示 Catalog 元数据（id + displayName），不读取 Asset 资源。
/// 当前选中项显示勾选标记并加粗名称。
class WordBookTile extends StatelessWidget {
  const WordBookTile({
    super.key,
    required this.config,
    required this.isSelected,
    required this.onTap,
  });

  /// 词库元数据（来自 [BuiltInWordBooks.all]，非用户输入）。
  final BuiltInWordBookConfig config;

  /// 是否为当前选中的词库。
  final bool isSelected;

  /// 点击回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.menu_book,
          color: isSelected ? colorScheme.primary : null,
        ),
        title: Text(
          config.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : null,
          ),
        ),
        // 目前全部为内置词库；未来接入自建词库后再区分来源
        subtitle: const Text('内置词库'),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
