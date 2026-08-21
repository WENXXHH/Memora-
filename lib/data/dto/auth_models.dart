// Freezed 2.x 在工厂构造参数上使用 @JsonKey 会触发 invalid_annotation_target
// 警告，但生成的代码正确（已验证 auth_models.g.dart），可安全忽略。
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// 注册请求体
///
/// 客户端校验只是改善体验，服务端必须重新验证全部规则。
/// 字段命名使用 camelCase，通过 [JsonKey] 映射到后端 snake_case。
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    /// 用户名：3-50 字符
    @JsonKey(name: 'username') required String username,

    /// 邮箱：必须是合法邮箱格式
    @JsonKey(name: 'email') required String email,

    /// 密码：6-128 字符
    @JsonKey(name: 'password') required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

/// 登录请求体
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    @JsonKey(name: 'username') required String username,
    @JsonKey(name: 'password') required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// 用户信息响应
///
/// 后端 UserResponse 绝不含 password / password_hash。
@freezed
class RemoteUser with _$RemoteUser {
  const factory RemoteUser({
    /// 用户唯一 ID（后端整数主键）
    @JsonKey(name: 'id') required int id,

    @JsonKey(name: 'username') required String username,

    @JsonKey(name: 'email') required String email,
  }) = _RemoteUser;

  factory RemoteUser.fromJson(Map<String, dynamic> json) =>
      _$RemoteUserFromJson(json);
}

/// 登录成功响应
///
/// access_token 字段名不可改：客户端 auth_interceptor.dart 用 'access_token' 常量读取。
@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    /// JWT access token
    @JsonKey(name: 'access_token') required String accessToken,

    /// Token 类型，固定为 "bearer"
    @JsonKey(name: 'token_type', defaultValue: 'bearer')
    required String tokenType,

    /// 当前登录用户信息（减少登录后再请求一次用户资料）
    @JsonKey(name: 'user') required RemoteUser user,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}
