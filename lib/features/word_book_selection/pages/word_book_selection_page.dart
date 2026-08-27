import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/services/word_book_summary.dart';
import '../../../providers/repository_providers.dart';
import '../providers/current_word_book_providers.dart';
import '../state/current_word_book_state.dart';
import '../widgets/word_book_tile.dart';

/// 词库选择页（doc 18 / 19 / 20 / 21 / 23 / 37 / 65）。
///
/// - 顶部展示"当前词库"（从 [CurrentWordBookState] 读取，非硬编码）
/// - 列表从 [WordBookRegistry.getAll] 动态渲染（doc 37），
///   按来源分组展示"内置词库 / 我的词库"（doc 37）
/// - 管理页操作后返回时重新拉取列表，保证"返回后不是旧列表"（doc 65）
/// - 点击词库 → 切换 + SnackBar 反馈 + 返回（doc 23）
class WordBookSelectionPage extends ConsumerStatefulWidget {
  const WordBookSelectionPage({super.key});

  @override
  ConsumerState<WordBookSelectionPage> createState() =>
      _WordBookSelectionPageState();
}

class _WordBookSelectionPageState extends ConsumerState<WordBookSelectionPage> {
  late Future<List<WordBookSummary>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = ref.read(wordBookRegistryProvider).getAll();
    // 进入页面时恢复用户上次选择（幂等，doc 10 / Commit 1）
    Future.microtask(() {
      ref.read(currentWordBookControllerProvider.notifier).initialize();
    });
  }

  /// 进入管理页；返回后刷新列表（doc 65：自建词库增删后选择页必须刷新）。
  Future<void> _openManage() async {
    await context.push('/word-books/manage');
    if (!mounted) return;
    setState(() {
      _booksFuture = ref.read(wordBookRegistryProvider).getAll();
    });
  }

  /// 切换词库：成功 → SnackBar + 返回首页；失败 → 错误提示（doc 23 / 13）。
  Future<void> _handleSelect(WordBookSummary book) async {
    final controller = ref.read(currentWordBookControllerProvider.notifier);
    await controller.selectWordBook(book.id);
    if (!mounted) return;

    final state = ref.read(currentWordBookControllerProvider);
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已切换至 ${book.name}')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentWordBookControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('词库'),
        centerTitle: true,
        // 自建词库管理入口（doc 38）：右上角进入管理页
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '管理自建词库',
            onPressed: _openManage,
          ),
        ],
      ),
      body: FutureBuilder<List<WordBookSummary>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;
          return _buildList(state, books);
        },
      ),
    );
  }

  /// 词库列表：按来源分组（doc 37），自建区为空时不展示。
  Widget _buildList(CurrentWordBookState state, List<WordBookSummary> books) {
    final builtIn = [
      for (final book in books)
        if (book.kind == WordBookKind.builtIn) book,
    ];
    final customs = [
      for (final book in books)
        if (book.kind == WordBookKind.custom) book,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCurrentBook(state, books),
        const SizedBox(height: 24),
        _buildSectionHeader('内置词库'),
        for (final book in builtIn)
          WordBookTile(
            book: book,
            isSelected: book.id == state.currentWordBookId,
            onTap: () => _handleSelect(book),
          ),
        if (customs.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('我的词库'),
          for (final book in customs)
            WordBookTile(
              book: book,
              isSelected: book.id == state.currentWordBookId,
              onTap: () => _handleSelect(book),
            ),
        ],
      ],
    );
  }

  /// 分组标题。
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 当前词库展示卡片（doc 19 / 22）。
  ///
  /// 名称从已加载列表按 ID 反查：当前词库可能是自建词库，
  /// 不能只查内置目录（doc 34）。
  Widget _buildCurrentBook(
    CurrentWordBookState state,
    List<WordBookSummary> books,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName =
        _findName(books, state.currentWordBookId) ?? state.currentWordBookId;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.bookmark_outline, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Expanded(child: Text('当前词库', style: TextStyle(fontSize: 16))),
            Text(
              currentName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 按 ID 从词库列表反查展示名；找不到时返回 null（由调用方兜底）。
  String? _findName(List<WordBookSummary> books, String id) {
    for (final book in books) {
      if (book.id == id) return book.name;
    }
    return null;
  }
}
