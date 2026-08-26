import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/built_in_word_books.dart';
import '../providers/current_word_book_providers.dart';
import '../state/current_word_book_state.dart';
import '../widgets/word_book_tile.dart';

/// 词库选择页（doc 18 / 19 / 20 / 21 / 23）。
///
/// - 顶部展示"当前词库"（从 [CurrentWordBookState] 读取，非硬编码）
/// - 列表从 [BuiltInWordBooks.all] 渲染，不读 Asset（doc 20 / 21）
/// - 点击词库 → 切换 + SnackBar 反馈 + 返回（doc 23）
class WordBookSelectionPage extends ConsumerStatefulWidget {
  const WordBookSelectionPage({super.key});

  @override
  ConsumerState<WordBookSelectionPage> createState() =>
      _WordBookSelectionPageState();
}

class _WordBookSelectionPageState extends ConsumerState<WordBookSelectionPage> {
  @override
  void initState() {
    super.initState();
    // 进入页面时恢复用户上次选择（幂等，doc 10 / Commit 1）
    Future.microtask(() {
      ref.read(currentWordBookControllerProvider.notifier).initialize();
    });
  }

  /// 切换词库：成功 → SnackBar + 返回首页；失败 → 错误提示（doc 23 / 13）。
  Future<void> _handleSelect(BuiltInWordBookConfig config) async {
    final controller = ref.read(currentWordBookControllerProvider.notifier);
    await controller.selectWordBook(config.id);
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
    ).showSnackBar(SnackBar(content: Text('已切换至 ${config.name}')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentWordBookControllerProvider);
    final currentName =
        BuiltInWordBooks.findById(state.currentWordBookId)?.name ??
        state.currentWordBookId;

    return Scaffold(
      appBar: AppBar(title: const Text('词库'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCurrentBook(state, currentName),
          const SizedBox(height: 24),
          const Text(
            '内置词库',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final config in BuiltInWordBooks.all)
            WordBookTile(
              config: config,
              isSelected: config.id == state.currentWordBookId,
              onTap: () => _handleSelect(config),
            ),
        ],
      ),
    );
  }

  /// 当前词库展示卡片（doc 19 / 22）。
  Widget _buildCurrentBook(CurrentWordBookState state, String currentName) {
    final colorScheme = Theme.of(context).colorScheme;

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
}
