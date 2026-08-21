/// 鉴权拦截器：自动注入 JSON Web Token（JWT）。
///
/// Token 来源：独立的 Hive Box（`auth`），不与业务 Box 混用。
/// 401 时清空本地 Token 并发出全局事件，由路由层跳转登录页。
library;

import 'package:dio/dio.dart';
import 'package:hive_ce/hive_ce.dart';

import '../network_exception.dart';

/// Box 中存储 access token 的 key。
const String kAccessTokenKey = 'access_token';

///  401 触发的全局未授权回调。
typedef UnauthorizedCallback = void Function();

/// 鉴权拦截器。
///
/// 职责：
/// 1. 请求发出前从 Hive 读取 Token，附加 `Authorization: Bearer xxx`
/// 2. 收到 401 时清空本地 Token 并触发 [onUnauthorized] 回调
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.authBox,
    this.onUnauthorized,
  });

  /// 存储 JWT 的 Hive Box。
  final Box<String> authBox;

  /// 401 触发的回调，通常由路由层注册以跳转登录页。
  final UnauthorizedCallback? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authBox.get(kAccessTokenKey);
    // 只有登录/注册端点是公开的，不需要 Token
    // /auth/me 需要 Token，不能跳过（用于启动恢复会话）
    final isPublicAuthEndpoint =
        options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');
    if (token != null && token.isNotEmpty && !isPublicAuthEndpoint) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = mapDioException(err);
    if (mapped.type == NetworkErrorType.unauthorized) {
      // 只有登录/注册的 401 是凭证错误，不触发登出
      // /auth/me 的 401 是 Token 过期，需要清除本地凭证
      final isPublicAuthEndpoint =
          err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/register');
      if (!isPublicAuthEndpoint) {
        authBox.delete(kAccessTokenKey);
        onUnauthorized?.call();
      }
    }
    handler.next(err);
  }
}
