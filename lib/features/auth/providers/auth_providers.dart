/// 认证相关 Riverpod Provider。
///
/// 由于 AuthRemoteDataSource / AuthRepository 依赖 Dio（来自 Riverpod dioProvider，
/// 而非 getIt），不使用 @injectable，改由本文件手动组装依赖链。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/storage/hive_initializer.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/sources/auth_remote_data_source.dart';
import '../../../providers/network_providers.dart';
import '../../../providers/repository_providers.dart';
import '../controller/auth_controller.dart';
import '../state/auth_state.dart';

/// Token 存储 Provider。
///
/// 从 getIt 取已打开的 auth Box，包装成 [TokenStorage]。
/// 复用 [kAccessTokenKey] 常量，不引入 flutter_secure_storage。
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final authBox = ref.read(getItProvider).get<Box<String>>(
    instanceName: HiveInitializer.authBoxName,
  );
  return TokenStorage(authBox);
});

/// 远程认证数据源 Provider。
///
/// 从 [dioProvider] 获取统一配置的 Dio 实例。
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDataSource(dio);
});

/// 认证仓库 Provider。
///
/// 组装 [AuthRemoteDataSource] + [TokenStorage]。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

/// 认证状态控制器 Provider。
///
/// 不是 autoDispose：认证状态需在整个 App 生命周期内保持。
/// 在构造时向 [UnauthorizedController] 注册监听，接收 401 事件。
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      final unauthorizedController = ref.read(unauthorizedControllerProvider);
      final controller = AuthController(authRepository);

      // 注册 401 事件监听：AuthInterceptor → UnauthorizedController → AuthController
      unauthorizedController.addListener(controller.handleUnauthorized);

      // 控制器销毁时移除监听，防止内存泄漏
      ref.onDispose(() {
        unauthorizedController.removeListener(controller.handleUnauthorized);
      });

      return controller;
    });
