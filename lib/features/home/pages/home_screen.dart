import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/home_controller.dart';
import '../widgets/today_task_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/statistics_card.dart';

/// 首页
///
/// 应用主页面，展示学习概览和快速入口
/// 使用 ConsumerStatefulWidget 监听 Riverpod 状态变化
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
    // 在页面初始化时调用控制器的 loadData 方法
    // 通过 ref.read 获取控制器实例并调用方法
    // 注意：此处使用 read 而非 watch，因为只需要调用一次，不需要监听变化
    ref.read(homeControllerProvider.notifier).loadData();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 ref.watch 监听首页状态变化
    // 当 HomeState 发生变化时，build 方法会自动重新执行
    final homeState = ref.watch(homeControllerProvider);

    // 使用 Scaffold 作为页面骨架
    return Scaffold(
      // 顶部导航栏
      appBar: AppBar(
        title: const Text('Memora'), // 应用名称
        centerTitle: true, // 标题居中
        elevation: 0, // 无阴影，扁平化设计
      ),
      // 根据加载状态切换显示内容
      body: homeState.isLoading 
          // 加载中：显示圆形加载动画
          ? const Center(child: CircularProgressIndicator())
          // 加载完成：显示页面内容
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16), // 整体内边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 内容左对齐
                children: [
                  // 欢迎语
                  _buildGreeting(),
                  const SizedBox(height: 24), // 间距
                  // 今日任务卡片：展示待复习和已学习数量
                  TodayTaskCard(
                    reviewCount: homeState.reviewCount,
                    learnedCount: homeState.learnedCount,
                  ),
                  const SizedBox(height: 24), // 间距
                  // 快速入口：学习新词、复习旧词、词库三个按钮
                  const QuickActions(),
                  const SizedBox(height: 24), // 间距
                  // 学习统计卡片：总单词、已掌握、连续打卡天数
                  StatisticsCard(
                    totalWords: homeState.totalWords,
                    masteredWords: homeState.masteredWords,
                    streakDays: homeState.streakDays,
                  ),
                ],
              ),
            ),
    );
  }

  /// 构建欢迎语 Widget
  ///
  /// 显示友好的问候语，使用大字号加粗样式突出显示
  Widget _buildGreeting() {
    return const Text(
      '你好，学习者！',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}