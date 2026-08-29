import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dto/custom_word_record_model.dart';
import '../../../providers/repository_providers.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/custom_word_book_providers.dart';

/// 自建词库详情页（doc 39 / 23）。
///
/// - 展示词库名与单词列表，AppBar 提供"添加单词"
/// - 每条单词支持编辑（进单词表单页）与删除（二次确认，doc 23）
/// - ⋮ 菜单提供"重命名词库 / 删除词库"；删除词库级联删单词与 Review，
///   若删除的是当前词库则回退 CET-6 并回到词库选择页（doc 71）
/// - 单词列表按词库隔离（autoDispose.family，doc 64）
class CustomWordBookDetailPage extends ConsumerStatefulWidget {
  const CustomWordBookDetailPage({super.key, required this.wordBookId});

  /// 自建词库 Domain ID。
  final String wordBookId;

  @override
  ConsumerState<CustomWordBookDetailPage> createState() =>
      _CustomWordBookDetailPageState();
}

class _CustomWordBookDetailPageState
    extends ConsumerState<CustomWordBookDetailPage> {
  String? _bookName;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // 加载单词列表（幂等）
      ref
          .read(
            customWordManagementControllerProvider(widget.wordBookId).notifier,
          )
          .load();
      // 异步加载词库名用于 AppBar 标题
      _loadBookName();
    });
  }

  Future<void> _loadBookName() async {
    final book = await ref
        .read(customWordBookRepositoryProvider)
        .getById(widget.wordBookId);
    if (book != null && mounted) {
      setState(() => _bookName = book.name);
    }
  }

  /// 删除单词：二次确认后级联删除其 Review（doc 23）。
  Future<void> _handleDeleteWord(CustomWordRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除单词？'),
        content: Text('删除「${record.word}」？该单词的学习进度也会被删除。'),
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
        .read(
          customWordManagementControllerProvider(widget.wordBookId).notifier,
        )
        .delete(record.id);
    if (!mounted) return;
    if (!ok) {
      final error = ref
          .read(customWordManagementControllerProvider(widget.wordBookId))
          .errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? '删除失败，请重试')));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除「${record.word}」')));
  }

  /// 编辑单词：进入单词表单页（编辑模式）。
  void _handleEditWord(CustomWordRecord record) {
    context.push(
      '/word-books/word-form?wordBookId=${widget.wordBookId}&wordId=${record.id}',
    );
  }

  /// 添加单词：进入单词表单页（新增模式）。
  void _handleAddWord() {
    context.push('/word-books/word-form?wordBookId=${widget.wordBookId}');
  }

  /// 重命名词库：进入词库表单页（编辑模式）。
  void _handleRenameBook() {
    context.push('/word-books/form?id=${widget.wordBookId}');
  }

  /// 删除词库：级联删除单词 / Review，若为当前词库回退 CET-6（doc 71）。
  Future<void> _handleDeleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除词库？'),
        content: Text(
          '「${_bookName ?? ''}」中的所有单词及本地学习进度都会被删除，'
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
        .delete(widget.wordBookId);
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
    if (currentId == widget.wordBookId) {
      await ref
          .read(currentWordBookControllerProvider.notifier)
          .resetToDefault();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除「${_bookName ?? ''}」')));
    context.go('/word-books');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bookName ?? '词库详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加单词',
            onPressed: _handleAddWord,
          ),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            onSelected: (value) {
              switch (value) {
                case 'renameBook':
                  _handleRenameBook();
                case 'deleteBook':
                  _handleDeleteBook();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'renameBook', child: Text('重命名词库')),
              PopupMenuItem(value: 'deleteBook', child: Text('删除词库')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(
      customWordManagementControllerProvider(widget.wordBookId),
    );

    // 加载失败且无数据：错误态 + 重试
    if (state.errorMessage != null && state.words.isEmpty) {
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
                  .read(
                    customWordManagementControllerProvider(
                      widget.wordBookId,
                    ).notifier,
                  )
                  .load(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 首次加载中
    if (state.isLoading && state.words.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 空列表
    if (state.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_note, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('还没有单词，点击右上角添加', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _handleAddWord,
              icon: const Icon(Icons.add),
              label: const Text('添加单词'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [for (final record in state.words) _buildWordTile(record)],
    );
  }

  Widget _buildWordTile(CustomWordRecord record) {
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
              onPressed: () => _handleEditWord(record),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除',
              onPressed: () => _handleDeleteWord(record),
            ),
          ],
        ),
      ),
    );
  }
}
