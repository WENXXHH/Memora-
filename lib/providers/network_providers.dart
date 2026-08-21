/// 网络层 Riverpod Provider。
///
/// 配合 get_it + Riverpod 双体系：
/// - Box 实例由 [HiveInitializer] 打开后注册到 getIt
/// - 这里通过 [getItProvider] 取出 Box，再用 Riverpod 暴露 Dio
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../core/network/dio_factory.dart';
import '../core/storage/hive_initializer.dart';
import 'repository_providers.dart';

/// 401 未授权事件桥接器。
///
/// 解决循环依赖：
/// - Dio 创建时需要 onUnauthorized 回调（network 层）
/// - AuthController 需要监听 401 事件（auth 层，创建时机晚于 Dio）
///
/// 方案：此 [ChangeNotifier] 定义在 network 层，作为中间事件总线。
/// dioProvider 将 `notify` 作为 onUnauthorized 注入 Dio；
/// AuthController 在构造时 `addListener` 注册自己的处理方法。
///
/// 原则 12：全项目只使用一个统一配置的 Dio。
/// 此桥接器不持有 Dio 引用，只转发事件。
final unauthorizedControllerProvider = Provider<UnauthorizedController>((ref) {
  final controller = UnauthorizedController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// 401 事件桥接器实现。
///
/// 当 AuthInterceptor 检测到 401（非 /auth/ 端点）时调用 [notify]，
/// 已注册的监听器（AuthController）收到通知后更新状态为 unauthenticated。
class UnauthorizedController extends ChangeNotifier {
  /// 触发未授权事件。
  void notify() {
    if (!hasListeners) return;
    notifyListeners();
  }
}

/// 全局 Dio Provider。
///
/// Feature 层通过 `ref.read(dioProvider)` 获取 Dio，
/// 不要在 Repository 内部 new Dio，否则无法被测试替换。
///
/// 401 跳转回调：通过 [UnauthorizedController] 桥接到 AuthController。
/// AuthInterceptor 在非 /auth/ 端点收到 401 时调用此回调，
/// AuthController 监听到事件后将状态设为 unauthenticated，路由守卫自动跳转 /login。
final dioProvider = Provider<Dio>((ref) {
  final authBox = ref.read(getItProvider).get<Box<String>>(
    instanceName: HiveInitializer.authBoxName,
  );
  // 读取 401 事件桥接器，将 notify 作为 onUnauthorized 回关注入 Dio
  final unauthorizedController = ref.read(unauthorizedControllerProvider);
  return createDio(
    authBox: authBox,
    onUnauthorized: unauthorizedController.notify,
  );
});
