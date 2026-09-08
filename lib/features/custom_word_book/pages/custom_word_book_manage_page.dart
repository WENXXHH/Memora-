import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/custom_word_book_model.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/custom_word_book_providers.dart';
import '../state/custom_word_book_management_state.dart';
import '../widgets/custom_word_book_delete_dialog.dart';
import '../widgets/custom_word_book_error_view.dart';
import '../widgets/custom_word_book_list_empty_view.dart';
import '../widgets/custom_word_book_tile.dart';

/// 自建词库管理页。
///
/// - 列出全部自建词库，AppBar 提供"新建"入口
/// - 每条支持重命名（进表单页）与删除（二次确认）
/// - 删除的是当前词库时回退默认 CET-6
/// - watch 管理控制器 State，表单页操作后自动刷新
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

  /// 删除流程：二次确认 → 级联删除 → 当前词库回退 → 反馈。
  Future<void> _handleDelete(CustomWordBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomWordBookDeleteDialog(
        bookName: book.name,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
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

    // 删除的是当前词库 → 回退默认
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
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CustomWordBookManagementState state) {
    // 加载失败且无数据：给出错误态 + 重试
    if (state.errorMessage != null && state.wordBooks.isEmpty) {
      return CustomWordBookErrorView(
        errorMessage: state.errorMessage!,
        onRetry: () => ref
            .read(customWordBookManagementControllerProvider.notifier)
            .load(),
      );
    }

    // 首次加载中
    if (state.isLoading && state.wordBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 空列表
    if (state.wordBooks.isEmpty) {
      return CustomWordBookListEmptyView(onCreate: _handleCreate);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final book in state.wordBooks)
          CustomWordBookTile(
            book: book,
            onOpen: () => _handleOpenDetail(book),
            onRename: () => _handleRename(book),
            onDelete: () => _handleDelete(book),
          ),
      ],
    );
  }

  /// 打开词库详情页（单词管理）。
  void _handleOpenDetail(CustomWordBook book) {
    context.push('/word-books/detail?id=${book.id}');
  }
}
