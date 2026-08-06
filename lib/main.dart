import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import 'app/MyApp.dart';
import 'services/dependency_injection.dart';
import 'services/hive_initializer.dart';
import 'services/tts_service.dart';

/// 应用入口函数
///
/// 执行顺序：
/// 1. WidgetsFlutterBinding.ensureInitialized() - 确保 Flutter 引擎初始化
/// 2. HiveInitializer.initialize() - 初始化 Hive 引擎并打开 reviews Box
/// 3. getIt.registerSingleton() - 将 Box 注册到 DI 容器
/// 4. configureDependencies() - 初始化依赖注入（get_it + injectable）
/// 5. runApp() - 启动应用，使用 ProviderScope 包裹以支持 Riverpod
///
/// 初始化失败时展示友好错误页，而非直接红屏崩溃。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. 初始化 Hive 引擎，打开 reviews Box
    final reviewsBox = await HiveInitializer.initialize();

    // 2. 将已打开的 Box 注册到 DI 容器
    //    必须在 configureDependencies() 之前完成，
    //    这样 injectable 生成的 ReviewLocalDataSource 工厂才能解析 Box<Map>
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(reviewsBox);

    // 3. 初始化依赖注入（injectable 扫描）
    configureDependencies();

    // 4. 预初始化 TTS 引擎（设置语言、语速等默认参数）
    //    不等待完成，避免阻塞启动；首次发音时会自动完成初始化
    getIt.get<TtsService>().initialize();

    // 5. 启动应用，ProviderScope 提供 Riverpod 状态管理能力
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
