import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/auth/state/auth_state.dart';
import '../features/home/pages/home_screen.dart';
import '../features/vocabulary/pages/word_list_page.dart';
import '../features/vocabulary/pages/word_detail_page.dart';
import '../features/learning/pages/learning_page.dart';
import '../features/listening_quiz/pages/listening_quiz_page.dart';
import '../features/multiple_choice/pages/multiple_choice_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/spelling_quiz/pages/spelling_quiz_page.dart';
import '../components/bottom_navigation_shell.dart';
import '../domain/enums/learning_enums.dart';
import '../data/dto/word_model.dart';

/// 路由配置 Provider。
///
/// 使用 StatefulShellRoute 实现底部 Tab 导航，支持页面状态保持。
/// 集成路由守卫（§3.5 splash + redirect 模式）：
/// - unknown/checking → /splash（避免未登录用户看到首页一瞬）
/// - unauthenticated → /login
/// - authenticated + 在登录页 → /home
///
/// 使用 [refreshListenable] 监听认证状态变化，触发 redirect 重新求值。
final routerProvider = Provider<GoRouter>((ref) {
  // 路由刷新通知器：认证状态变化时通知 GoRouter 重新执行 redirect
  final refreshNotifier = _GoRouterRefreshNotifier();

  // 监听认证状态，状态变化时触发 redirect 重新求值
  ref.listen(authControllerProvider, (_, _) {
    refreshNotifier.notify();
  });

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final matchedLocation = state.matchedLocation;

      // 认证相关路由
      const isSplashRoute = '/splash';
      final isLoginRoute = matchedLocation == '/login';
      final isRegisterRoute = matchedLocation == '/register';
      final isAuthRoute = isLoginRoute || isRegisterRoute;

      switch (status) {
        case AuthStatus.unknown:
        case AuthStatus.checking:
          // 启动期/检查中：重定向到 splash，避免未登录看到首页闪烁
          return matchedLocation == isSplashRoute ? null : '/splash';

        case AuthStatus.unauthenticated:
          // 未认证：允许在登录页和注册页停留
          if (isLoginRoute || isRegisterRoute) return null;
          // 注册成功后状态回到 unauthenticated，自动跳到登录页
          return '/login';

        case AuthStatus.authenticated:
          // 已认证：在登录/注册/splash 页则跳回首页
          if (isAuthRoute || matchedLocation == '/splash') {
            return '/home';
          }
          return null;

        case AuthStatus.authenticating:
          // 正在登录/注册中：允许停留在当前表单页
          return null;

        case AuthStatus.error:
          // 错误态：允许停留在当前页（splash 显示重试，表单页显示错误）
          return null;
      }
    },
    routes: [
      /// 闪屏页：启动恢复会话期间显示
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      /// 登录页
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      /// 注册页
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

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

      /// 选择题复习页（全屏覆盖，无底部导航）
      /// §5.3：独立 GoRoute，不混入底部 Tab
      GoRoute(
        path: '/choice',
        name: 'choice',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          return MultipleChoicePage(wordBookId: wordBookId);
        },
      ),

      /// 听音辨词复习页（全屏覆盖，无底部导航）
      /// 独立 GoRoute，与选择题同级；复用同一套 SM-2 + Hive
      GoRoute(
        path: '/listening-quiz',
        name: 'listening-quiz',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          return ListeningQuizPage(wordBookId: wordBookId);
        },
      ),

      /// 拼写复习页（全屏覆盖，无底部导航）
      /// 独立 GoRoute，与选择题 / 听音辨词同级；复用同一套 SM-2 + Hive
      GoRoute(
        path: '/spelling-quiz',
        name: 'spelling-quiz',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          return SpellingQuizPage(wordBookId: wordBookId);
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

      /// 底部 Tab 导航壳路由
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
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// GoRouter 刷新通知器。
///
/// 当认证状态变化时，通过 [notifyListeners] 触发 GoRouter 重新执行 redirect。
/// 参考 go_router + Riverpod 集成模式。
class _GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
