import 'package:flutter/material.dart';

import '../../../domain/services/word_book_summary.dart';

/// 词库列表项组件（doc 19 / 20 / 21 / 66）。
///
/// 只展示统一展示模型 [WordBookSummary]（id + name + kind），
/// 不读取 Asset 资源、不感知底层内置/自建数据模型（doc 9）。
/// 副标题按来源类型展示"内置词库 / 自建词库"（doc 66），
/// 当前选中项显示勾选标记并加粗名称。
class WordBookTile extends StatelessWidget {
  const WordBookTile({
    super.key,
    required this.book,
    required this.isSelected,
    required this.onTap,
  });

  /// 词库轻量展示数据（来自 [WordBookRegistry.getAll]，非用户输入）。
  final WordBookSummary book;

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
          book.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : null,
          ),
        ),
        // 来源类型展示（doc 66）：内置词库 / 自建词库
        subtitle: Text(book.kind == WordBookKind.builtIn ? '内置词库' : '自建词库'),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
