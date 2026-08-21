import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/app/router.dart';
import 'package:memora/app/theme.dart';

/// 应用根组件
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //读取并监听 routerProvider 提供的路由对象。
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Memora',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,//不要显示右上角 DEBUG 横幅。
    );
  }
}
