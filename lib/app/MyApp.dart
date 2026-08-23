import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/app/router.dart';
import 'package:memora/app/theme.dart';
import 'package:memora/components/app_bootstrap.dart';

/// 应用根组件。
///
/// ProviderScope（main.dart 注入）之后的第一层 Widget。
/// 通过 [AppBootstrap] 安装全局监听（auth → sync 自动同步），
/// 保持 MaterialApp 纯净，不把业务监听写进路由框架内部。
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 读取并监听 routerProvider 提供的路由对象。
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Memora',
      theme: AppTheme.lightTheme,
      // AppBootstrap 包装 MaterialApp：在 App 生命周期内常驻监听 AuthState
      // 变化，进入 authenticated 时自动执行同步（doc 15 入口 1）。
      builder: (context, child) => AppBootstrap(child: child!),
      routerConfig: router,
      debugShowCheckedModeBanner: false, // 不要显示右上角 DEBUG 横幅。
    );
  }
}
