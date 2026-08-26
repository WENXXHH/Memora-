import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/built_in_word_books.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/home_providers.dart';
import '../state/home_state.dart';
import '../widgets/today_task_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/statistics_card.dart';

/// 首页
///
/// 应用主页面，展示学习概览和快速入口。
/// 数据跟随当前词库（currentWordBookIdProvider）加载与刷新：
/// - 首次进入按当前词库加载
/// - 切换词库后自动重新加载（doc 24 / 40）
/// 支持四种 UI 状态：加载中、正常数据、空数据（首次启动）、错误。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

/// 首页状态类
///
/// 继承 ConsumerState，支持通过 ref 访问 Riverpod Provider
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 首次进入按当前词库加载（Future.microtask 确保 build 完成后异步加载）
    _loadDataFor(ref.read(currentWordBookIdProvider));
  }

  /// 为指定词库异步加载首页数据
  void _loadDataFor(String wordBookId) {
    Future.microtask(() {
      ref.read(homeControllerProvider(wordBookId).notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordBookId = ref.watch(currentWordBookIdProvider);
    final homeState = ref.watch(homeControllerProvider(wordBookId));

    // 切换词库后刷新统计，避免首页仍显示旧词库数据（doc 24 / 40 / Bug 3）
    ref.listen(currentWordBookIdProvider, (previous, next) {
      if (previous != next) _loadDataFor(next);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memora'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCurrentWordBookBar(wordBookId),
          Expanded(child: _buildBody(homeState, wordBookId)),
        ],
      ),
    );
  }

  /// 当前词库展示（doc 22 最小 UI），点击进入词库选择页。
  Widget _buildCurrentWordBookBar(String wordBookId) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = BuiltInWordBooks.findById(wordBookId)?.name ?? wordBookId;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () => context.push('/word-books'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('当前词库', style: TextStyle(fontSize: 14)),
              const Spacer(),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据状态构建不同内容
  Widget _buildBody(HomeState homeState, String wordBookId) {
    // 状态 1：加载中
    if (homeState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 状态 2：加载失败
    if (homeState.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('数据加载失败'),
            const SizedBox(height: 8),
            Text(
              homeState.errorMessage ?? '未知错误',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDataFor(wordBookId),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 状态 3 或 4：空数据或正常数据，共用布局
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 24),
          if (homeState.reviewCount == 0 && homeState.learnedCount == 0)
            _buildEmptyTip(),
          TodayTaskCard(
            reviewCount: homeState.reviewCount,
            learnedCount: homeState.learnedCount,
          ),
          const SizedBox(height: 24),
          QuickActions(wordBookId: wordBookId),
          const SizedBox(height: 24),
          StatisticsCard(
            totalWords: homeState.totalWords,
            masteredWords: homeState.masteredWords,
            streakDays: homeState.streakDays,
          ),
        ],
      ),
    );
  }

  /// 空数据提示
  Widget _buildEmptyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_stories, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('还没有学习记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 4),
          Text(
            '开始学习第一个单词吧',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建欢迎语 Widget
  Widget _buildGreeting() {
    return const Text(
      '你好，学习者！',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
