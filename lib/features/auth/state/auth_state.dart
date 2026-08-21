import '../../../data/dto/auth_models.dart';

/// 认证状态机（6 态）。
///
/// 遵循第五周原则 14："AuthStatus 6 态"——不要把"登录失败/未登录/
/// Token 检查中"都表示成一个 `isLoading`。
///
/// 状态流转：
/// ```
/// App 启动 → unknown
///    ↓ restoreSession()
/// checking → ┌─ authenticated（有 Token 且有效）
///           ├─ unauthenticated（无 Token / Token 失效）
///           └─ error（网络错误，不删 Token）
///
/// 登录/注册 → authenticating
///    ├─ authenticated（成功）
///    └─ error（失败，如密码错）
/// ```
class AuthState {
  /// 当前认证状态。
  final AuthStatus status;

  /// 当前登录用户（仅 [AuthStatus.authenticated] 时非 null）。
  final RemoteUser? currentUser;

  /// 错误信息（仅 [AuthStatus.error] 时非 null）。
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
  ///
  /// 使用 sentinel 模式区分"未传参"和"显式传 null"，
  /// 参考 [learning_state.dart] 的实现方式。
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

/// 认证状态枚举（6 态）。
enum AuthStatus {
  /// App 刚启动，尚未检查 Token。
  unknown,

  /// 正在读取并验证 Token（调用 GET /auth/me）。
  checking,

  /// 没有有效登录。
  unauthenticated,

  /// 正在注册或登录中（网络请求进行中）。
  authenticating,

  /// 已登录，[AuthState.currentUser] 有值。
  authenticated,

  /// 本次认证操作失败（如密码错误、网络超时）。
  error,
}
