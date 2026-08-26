import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memora/features/home/widgets/quick_actions.dart';

/// 词库切换入口传参测试（doc 48 / 62 入口）。
///
/// 核心断言：QuickActions 使用页面传入的 [wordBookId] 拼接路由参数，
/// 当前词库为 CET-4 时五个学习类入口全部携带 wordBookId=cet4，
/// 不存在硬编码 CET-6 的入口。
void main() {
  GoRouter buildRouter(String wordBookId) => GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            Scaffold(body: QuickActions(wordBookId: wordBookId)),
      ),
      GoRoute(path: '/learning', builder: (context, state) => const Scaffold()),
      GoRoute(path: '/choice', builder: (context, state) => const Scaffold()),
      GoRoute(
        path: '/listening-quiz',
        builder: (context, state) => const Scaffold(),
      ),
      GoRoute(
        path: '/spelling-quiz',
        builder: (context, state) => const Scaffold(),
      ),
    ],
  );

  /// 点击指定入口并断言跳转路径携带 wordBookId，随后重置回首页。
  Future<void> expectPush(
    WidgetTester tester,
    GoRouter router,
    String label,
    String expectedPath,
  ) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      expectedPath,
      reason: '$label 应跳转到 $expectedPath',
    );
    router.go('/home');
    await tester.pumpAndSettle();
  }

  testWidgets('当前词库 CET-4 时学习类入口全部携带 wordBookId=cet4', (tester) async {
    final router = buildRouter('cet4');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await expectPush(tester, router, '学习新词', '/learning?wordBookId=cet4');
    await expectPush(
      tester,
      router,
      '复习旧词',
      '/learning?mode=review&wordBookId=cet4',
    );
    await expectPush(tester, router, '选择题复习', '/choice?wordBookId=cet4');
    await expectPush(tester, router, '听音辨词', '/listening-quiz?wordBookId=cet4');
    await expectPush(tester, router, '拼写复习', '/spelling-quiz?wordBookId=cet4');
  });

  testWidgets('当前词库 CET-6 时学习类入口携带 wordBookId=cet6', (tester) async {
    final router = buildRouter('cet6');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await expectPush(tester, router, '学习新词', '/learning?wordBookId=cet6');
    await expectPush(tester, router, '选择题复习', '/choice?wordBookId=cet6');
  });
}
