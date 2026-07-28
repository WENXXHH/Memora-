import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/app/router.dart';
import 'package:memora/app/theme.dart';

/// 应用根组件
///
/// 使用 ConsumerWidget 监听路由配置，通过 MaterialApp.router 配置路由
/// 接入全局主题配置 AppTheme.lightTheme
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听路由配置变化
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Memora',
      // 使用全局主题配置中的亮色主题
      theme: AppTheme.lightTheme,
      // 使用 GoRouter 配置路由
      routerConfig: router,
      // 隐藏调试横幅
      debugShowCheckedModeBanner: false,
    );
  }
}
