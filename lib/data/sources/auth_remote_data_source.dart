/// 认证远程数据源。
///
/// 直接对接后端 `/api/v1/auth/*` 端点：
/// - POST /v1/auth/register  注册
/// - POST /v1/auth/login     登录（返回 JWT + user）
/// - GET  /v1/auth/me         获取当前用户（用于启动恢复）
///
/// 不使用 @injectable 注册：因为依赖 Dio（由 Riverpod dioProvider 提供，
/// 而非 getIt），改由 [authRemoteDataSourceProvider] 手动组装。
library;

import 'package:dio/dio.dart';

import '../dto/auth_models.dart';
import '../../core/network/network_exception.dart';

/// 远程认证数据源。
///
/// Dio 实例的 baseUrl 已配置为 `http://.../api`，
/// 此处只需使用相对路径 `/v1/auth/...`。
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// 注册新用户。
  ///
  /// 成功返回 201 + [RemoteUser]。
  /// 用户名/邮箱重复时后端返回 409，会被 [ErrorInterceptor] 映射为
  /// [NetworkException]（type=unknown, statusCode=409）。
  Future<RemoteUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/register',
        data: RegisterRequest(
          username: username,
          email: email,
          password: password,
        ).toJson(),
      );
      return RemoteUser.fromJson(response.data!);
    } on DioException catch (e) {
      // ErrorInterceptor 已把异常包装成 NetworkException
      throw e.error is NetworkException ? e.error! : e;
    }
  }

  /// 登录。
  ///
  /// 成功返回 [TokenResponse]（含 access_token + user）。
  /// 密码错误时后端返回 401。
  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: LoginRequest(
          username: username,
          password: password,
        ).toJson(),
      );
      return TokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }

  /// 获取当前登录用户信息（GET /auth/me）。
  ///
  /// 用于启动时验证已保存的 Token 是否仍然有效。
  /// 401 → Token 已过期/无效；网络错误 → 暂时无网络。
  Future<RemoteUser> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/auth/me');
      return RemoteUser.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }
}
