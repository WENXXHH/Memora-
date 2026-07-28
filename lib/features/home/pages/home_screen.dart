import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../state/home_state.dart';
import '../widgets/today_task_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/statistics_card.dart';

/// 首页
///
/// 应用主页面，展示学习概览和快速入口。
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
    // 使用 Future.microtask 确保在 build 完成后异步加载数据
    _loadData();
  }

  /// 异步加载首页数据
  void _loadData() {
    Future.microtask(() {
      ref.read(homeControllerProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 ref.watch 监听首页状态变化
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memora'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(homeState),
    );
  }

  /// 根据状态构建不同内容
  Widget _buildBody(HomeState homeState) {
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
              onPressed: _loadData,
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
          // 欢迎语
          _buildGreeting(),
          const SizedBox(height: 24),
          // 状态 3：空数据提示（首次启动无复习记录）
          if (homeState.reviewCount == 0 && homeState.learnedCount == 0)
            _buildEmptyTip(),
          // 今日任务卡片
          TodayTaskCard(
            reviewCount: homeState.reviewCount,
            learnedCount: homeState.learnedCount,
          ),
          const SizedBox(height: 24),
          // 快速入口：空数据时也能点击"学习新词"
          const QuickActions(),
          const SizedBox(height: 24),
          // 学习统计卡片
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
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_stories, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('还没有学习记录',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 4),
          Text('开始学习第一个单词吧',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
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
