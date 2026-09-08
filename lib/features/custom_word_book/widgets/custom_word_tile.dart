import 'package:flutter/material.dart';

import '../../../domain/models/custom_word_record_model.dart';

/// 词库详情页中的单条单词卡片：展示单词、音标与释义，
/// 并提供编辑 / 删除入口。
class CustomWordTile extends StatelessWidget {
  const CustomWordTile({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  /// 单词记录。
  final CustomWordRecord record;

  /// 编辑回调。
  final VoidCallback onEdit;

  /// 删除回调。
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final definitions = record.meaning
        .expand((entry) => entry.definitions)
        .join('；');
    final subtitle = [
      if (record.phonetic.isNotEmpty) record.phonetic,
      definitions,
    ].join('  ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.translate, color: colorScheme.primary),
        title: Text(record.word),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '编辑',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
