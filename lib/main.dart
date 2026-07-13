import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/services/dependency_injection.dart';
import 'package:memora/app/MyApp.dart';

/// 应用入口函数
///
/// 执行顺序：
/// 1. WidgetsFlutterBinding.ensureInitialized() - 确保 Flutter 引擎初始化
/// 2. configureDependencies() - 初始化依赖注入（get_it + injectable）
/// 3. runApp() - 启动应用，使用 ProviderScope 包裹以支持 Riverpod
void main() {
  // 必须在使用 rootBundle 之前调用，否则会报 Binding has not yet been initialized 错误
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化依赖注入容器
  configureDependencies();
  // 启动应用，ProviderScope 提供 Riverpod 状态管理能力
  runApp(const ProviderScope(child: MyApp()));
}

