import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import 'app/MyApp.dart';
import 'app/dependency_injection.dart';
import 'core/storage/hive_initializer.dart';
import 'core/services/tts/tts_service.dart';

/// 应用入口函数
Future<void> main() async {
  //确保 Flutter 引擎初始化
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化 Hive 引擎，打开 reviews Box 与 auth Box
    final boxes = await HiveInitializer.initialize();

    // 将已打开的 Box 注册到 DI 容器
    //    同时注册 auth Box，供 AuthInterceptor 读取 JWT
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(boxes.reviews);
    getIt.registerSingleton<Box<String>>(
      boxes.auth,
      instanceName: HiveInitializer.authBoxName,
    );
    getIt.registerSingleton<Box<String>>(
      boxes.settings,
      instanceName: HiveInitializer.settingsBoxName,
    );
    // 自建词库 Box 需要独立实例名，与默认的 reviews Box 区分；
    // CustomWordBookLocalSource 通过 @Named 注入它（doc 24 / 25）。
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(
      boxes.customWordBooks,
      instanceName: HiveInitializer.customWordBooksBoxName,
    );

    // 初始化依赖注入（injectable 扫描）
    configureDependencies();

    // 预初始化 TTS 引擎（设置语言、语速等默认参数）
    //    不等待完成，避免阻塞启动；首次发音时会自动完成初始化
    getIt.get<TtsService>().initialize();

    // 启动应用，ProviderScope 提供 Riverpod 状态管理能力
    runApp(const ProviderScope(child: MyApp()));
  } catch (error, stackTrace) {
    debugPrint('[Hive] 初始化失败: $error\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('本地数据初始化失败'),
                const SizedBox(height: 8),
                const Text('请尝试重新启动应用', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('重新尝试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
