/// Dio 工厂：集中创建配置好的 [Dio] 实例。
///
/// 设计原则：
/// - Feature 层不直接 new Dio，统一走 [dioProvider]
/// - 拦截器顺序：Log → Auth → Error（请求方向 Log 先记录、Auth 注入 Token；
///   响应方向 Error 先转换异常再交给 Auth 处理 401）
library;

import 'package:dio/dio.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../app/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'network_config.dart';

/// 工厂方法：组装 [Dio] 实例。
///
/// [authBox] 由调用方通过 DI 注入，避免本文件直接依赖 getIt，
/// 便于在测试中传入 fake Box。
Dio createDio({
  required Box<String> authBox,
  UnauthorizedCallback? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: NetworkConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: NetworkConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: NetworkConfig.sendTimeout),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // 拦截器顺序很重要：
  // 请求方向按 add 顺序执行 → Log 先打印，Auth 后注入
  // 响应/错误方向按倒序执行 → Error 先转换，Auth 后处理 401
  dio.interceptors.add(LogInterceptorImpl());
  dio.interceptors.add(ErrorInterceptor());
  dio.interceptors.add(
    AuthInterceptor(authBox: authBox, onUnauthorized: onUnauthorized),
  );

  return dio;
}
