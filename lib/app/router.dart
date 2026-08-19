import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/pages/home_screen.dart';
import '../features/vocabulary/pages/word_list_page.dart';
import '../features/vocabulary/pages/word_detail_page.dart';
import '../features/learning/pages/learning_page.dart';
import '../components/PlaceholderPage.dart';
import '../components/bottom_navigation_shell.dart';
import '../domain/enums/learning_enums.dart';
import '../data/dto/word_model.dart';

/// 路由配置Provider
/// 使用 StatefulShellRoute 实现底部Tab导航，支持页面状态保持

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
          return BottomNavigationShell(navigationShell: navigationShell);
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

          /// 我的分支
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
