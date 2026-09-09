import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import 'app/my_app.dart';
import 'app/dependency_injection.dart';
import 'core/storage/hive_initializer.dart';
import 'core/services/tts/tts_service.dart';
import 'data/services/user_data_space_service.dart';

/// 应用入口函数
Future<void> main() async {
  //确保 Flutter 引擎初始化
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化 Hive 引擎，打开 reviews Box 与 auth Box
    final boxes = await HiveInitializer.initialize();

    // 把 reviews Box 放进 getIt 对象仓库
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(boxes.reviews);
    // 把 auth Box 放进去，并贴上 auth 名字标签
    getIt.registerSingleton<Box<String>>(
      boxes.auth,
      instanceName: HiveInitializer.authBoxName,
    );
    //把 settings Box 放进去，并贴上 settings 标签
    getIt.registerSingleton<Box<String>>(
      boxes.settings,
      instanceName: HiveInitializer.settingsBoxName,
    );
    // 自建词库 Box 需要独立实例名，与默认的 reviews Box 区分；
    // CustomWordBookLocalSource 通过 @Named 注入它。
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(
      boxes.customWordBooks,
      instanceName: HiveInitializer.customWordBooksBoxName,
    );
    // 自建单词 Box，同样独立实例名。
    getIt.registerSingleton<Box<Map<dynamic, dynamic>>>(
      boxes.customWords,
      instanceName: HiveInitializer.customWordsBoxName,
    );

    // 初始化依赖注入
    configureDependencies();

    // 一次性迁移：把旧格式复习记录（无账号命名空间前缀）归入 guest 空间，
    // 之后登录账号时由 UserDataSpaceService 把游客成果迁入对应账号空间
    await getIt.get<UserDataSpaceService>().migrateLegacyKeysToGuest();

    // 预初始化 TTS 引擎
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
