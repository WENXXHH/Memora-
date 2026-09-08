import '../../../data/dto/auth_models.dart';

/// 认证状态机（6 态）。
///
/// 状态流转：
/// ```
/// App 启动 → unknown
///    ↓ restoreSession()
/// checking → ┌─ authenticated（有 Token 且有效）
///            ├─ unauthenticated（无 Token / Token 失效）
///            └─ error（网络错误，不删 Token）
///
/// 登录/注册 → authenticating
///    ├─ authenticated（成功）
///    └─ error（失败，如密码错）
/// ```
class AuthState {
  /// 当前认证状态。
  final AuthStatus status;

  /// 当前登录用户。
  final RemoteUser? currentUser;

  /// 错误信息。
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.currentUser,
    this.errorMessage,
  });

  /// 工厂构造：App 刚启动，尚未检查 Token。
  const AuthState.unknown()
    : this(status: AuthStatus.unknown);

  /// 工厂构造：已认证。
  const AuthState.authenticated(RemoteUser user)
    : this(status: AuthStatus.authenticated, currentUser: user);

  /// 工厂构造：未认证。
  const AuthState.unauthenticated()
    : this(status: AuthStatus.unauthenticated);

  /// 创建一个副本，更新指定字段。
  AuthState copyWith({
    AuthStatus? status,
    Object? currentUser = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: identical(currentUser, _sentinel)
          ? this.currentUser
          : currentUser as RemoteUser?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"
const Object _sentinel = Object();

/// 认证状态枚举。
enum AuthStatus {
  /// App 刚启动，尚未检查 Token。
  unknown,

  /// 正在读取并验证 Token（调用 GET /auth/me）。
  checking,

  /// 没有有效登录。
  unauthenticated,

  /// 正在注册或登录中（网络请求进行中）。
  authenticating,

  /// 已登录。
  authenticated,

  /// 本次认证操作失败。
  error,
}
