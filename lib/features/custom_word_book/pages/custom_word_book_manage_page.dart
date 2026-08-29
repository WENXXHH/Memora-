import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dto/custom_word_book_model.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/custom_word_book_providers.dart';
import '../state/custom_word_book_management_state.dart';

/// 自建词库管理页（doc 39 / 63）。
///
/// - 列出全部自建词库，AppBar 提供"新建"入口
/// - 每条支持重命名（进表单页）与删除（二次确认，doc 17）
/// - 删除的是当前词库时回退默认 CET-6（doc 35 / 62 / 71）
/// - watch 管理控制器 State，表单页操作后自动刷新（doc 65）
class CustomWordBookManagePage extends ConsumerStatefulWidget {
  const CustomWordBookManagePage({super.key});

  @override
  ConsumerState<CustomWordBookManagePage> createState() =>
      _CustomWordBookManagePageState();
}

class _CustomWordBookManagePageState
    extends ConsumerState<CustomWordBookManagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customWordBookManagementControllerProvider.notifier).load();
    });
  }

  /// 删除流程：二次确认 → 级联删除 → 当前词库回退 → 反馈（doc 17 / 35）。
  Future<void> _handleDelete(CustomWordBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除词库？'),
        content: Text(
          '「${book.name}」中的所有单词及本地学习进度都会被删除，'
          '此操作不可撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(customWordBookManagementControllerProvider.notifier)
        .delete(book.id);
    if (!mounted) return;

    if (!ok) {
      final error = ref
          .read(customWordBookManagementControllerProvider)
          .errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? '删除失败，请重试')));
      return;
    }

    // 删除的是当前词库 → 回退默认（doc 35 / 71）
    final currentId = ref
        .read(currentWordBookControllerProvider)
        .currentWordBookId;
    if (currentId == book.id) {
      await ref
          .read(currentWordBookControllerProvider.notifier)
          .resetToDefault();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除「${book.name}」')));
  }

  /// 重命名：进入表单页（编辑模式）。
  void _handleRename(CustomWordBook book) {
    context.push('/word-books/form?id=${book.id}');
  }

  /// 新建：进入表单页（创建模式）。
  void _handleCreate() {
    context.push('/word-books/form');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customWordBookManagementControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的词库'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建词库',
            onPressed: _handleCreate,
          ),
        ],
      ),
      body: _buildBody(state, colorScheme),
    );
  }

  Widget _buildBody(
    CustomWordBookManagementState state,
    ColorScheme colorScheme,
  ) {
    // 加载失败且无数据：给出错误态 + 重试
    if (state.errorMessage != null && state.wordBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref
                  .read(customWordBookManagementControllerProvider.notifier)
                  .load(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 首次加载中
    if (state.isLoading && state.wordBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 空列表
    if (state.wordBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            const Text('还没有自建词库', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _handleCreate,
              icon: const Icon(Icons.add),
              label: const Text('新建词库'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final book in state.wordBooks) _buildTile(book, colorScheme),
      ],
    );
  }

  /// 打开词库详情页（单词管理）。
  void _handleOpenDetail(CustomWordBook book) {
    context.push('/word-books/detail?id=${book.id}');
  }

  Widget _buildTile(CustomWordBook book, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.menu_book, color: colorScheme.primary),
        title: Text(book.name),
        subtitle: const Text('自建词库'),
        // 点击进入详情页管理单词（doc 38 / 39）
        onTap: () => _handleOpenDetail(book),
        trailing: PopupMenuButton<String>(
          tooltip: '更多操作',
          onSelected: (value) {
            switch (value) {
              case 'rename':
                _handleRename(book);
              case 'delete':
                _handleDelete(book);
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
