import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/pages/home_screen.dart';
import '../features/vocabulary/pages/word_list_page.dart';
import '../features/vocabulary/pages/word_detail_page.dart';
import '../features/learning/pages/learning_page.dart';
import '../features/learning/state/learning_state.dart';
import '../components/PlaceholderPage.dart';
import '../data/models/word_model.dart';

/// 路由配置Provider
///
/// 使用 StatefulShellRoute 实现底部Tab导航，支持页面状态保持
/// 遵循《Flutter项目规范v1.0》中路由规范要求
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      /// 单词详情页（全屏覆盖，无底部导航）
      GoRoute(
        path: '/detail',
        name: 'detail',
        builder: (context, state) {
          final word = state.extra as Word;
          return WordDetailPage(word: word);
        },
      ),
      /// 学习页（全屏覆盖，无底部导航）
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          final mode = state.uri.queryParameters['mode'] == 'review'
              ? LearningMode.review
              : LearningMode.newWord;
          return LearningPage(wordBookId: wordBookId, mode: mode);
        },
      ),
      /// 词库页（全屏覆盖，无底部导航）
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          final title = state.uri.queryParameters['title'] ?? '词库';
          return WordListPage(wordBookId: wordBookId, title: title);
        },
      ),
      /// 底部Tab导航壳路由
      ///
      /// 使用 StatefulShellRoute.indexedStack 保持页面状态
      /// 包含两个分支：首页和我的
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _BottomNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          /// 首页分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          /// 我的分支（占位，第5周完善）
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const PlaceholderPage(title: '我的'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 底部导航壳组件
///
/// 封装 StatefulNavigationShell，提供统一的底部Tab栏
/// 使用 Material 3 NavigationBar 组件
class _BottomNavigationShell extends StatelessWidget {
  const _BottomNavigationShell({
    required this.navigationShell,
  });

  /// StatefulNavigationShell 实例，用于管理底部导航状态
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面内容区域
      body: navigationShell,
      // 底部导航栏
      bottomNavigationBar: NavigationBar(
        // 当前选中的Tab索引
        selectedIndex: navigationShell.currentIndex,
        // Tab切换回调
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // 如果点击当前Tab，则刷新页面
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // 导航目标（首页和我的）
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}