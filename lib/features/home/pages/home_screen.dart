import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/services/word_book_summary.dart';
import '../../../providers/repository_providers.dart';
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
/// - 切换词库后自动重新加载
/// 支持四种 UI 状态：加载中、正常数据、空数据（首次启动）、错误。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

/// 首页状态类
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

  /// 词库名解析 Future 缓存（按 wordBookId 失效，避免每次 build 重复查询）。
  String? _nameFutureBookId;
  Future<WordBookSummary?>? _nameFuture;

  Future<WordBookSummary?> _nameFutureFor(String wordBookId) {
    if (_nameFutureBookId != wordBookId) {
      _nameFutureBookId = wordBookId;
      _nameFuture = ref.read(wordBookRegistryProvider).findById(wordBookId);
    }
    return _nameFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final wordBookId = ref.watch(currentWordBookIdProvider);
    final homeState = ref.watch(homeControllerProvider(wordBookId));

    // 切换词库后刷新统计，避免首页仍显示旧词库数据
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

  /// 当前词库展示，点击进入词库选择页。
  Widget _buildCurrentWordBookBar(String wordBookId) {
    final colorScheme = Theme.of(context).colorScheme;

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
              // 词库名：通过 Registry 解析（含自建词库真实名称）；
              // Flexible + ellipsis 防止长名（尤其自建词库）横向溢出。
              Flexible(
                child: FutureBuilder<WordBookSummary?>(
                  future: _nameFutureFor(wordBookId),
                  builder: (context, snapshot) {
                    final name = snapshot.data?.name ?? wordBookId;
                    return Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    );
                  },
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
