import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../state/auth_state.dart';

/// 认证状态控制器。
///
/// 职责：
/// 1. 管理 [AuthState] 6 态机
/// 2. 调用 [AuthRepository] 执行登录/注册/登出/恢复会话
/// 3. 区分"密码错误"与"网络错误"——前者设为 error 态，后者保留 Token
///
/// 原则 15：Controller 不依赖另一个 Controller。
/// 此处只依赖 AuthRepository，不直接访问 Dio 或其他 Controller。
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authRepository) : super(const AuthState.unknown());

  final AuthRepository _authRepository;

  /// 启动时恢复会话。
  ///
  /// 流程（§2.4）：
  /// - 无 Token → unauthenticated
  /// - 有 Token + /auth/me 成功 → authenticated
  /// - 有 Token + 401 → 删 Token → unauthenticated
  /// - 有 Token + 网络错误 → 不删 Token → error（显示离线/重试）
  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    try {
      final result = await _authRepository.restoreSession();

      if (result.isValid && result.user != null) {
        state = AuthState.authenticated(result.user!);
      } else {
        // noToken 或 invalidToken → 都需要登录
        state = const AuthState.unauthenticated();
      }
    } on NetworkException catch (e) {
      // 网络错误（超时/断网）：不删 Token，显示错误让用户重试
      // Token 仍保留在本地，下次恢复时可再次尝试验证
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 登录。
  ///
  /// 成功 → authenticated；密码错误 → error。
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      final user = await _authRepository.login(
        username: username,
        password: password,
      );
      state = AuthState.authenticated(user);
    } on NetworkException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 注册。
  ///
  /// 后端注册不返回 Token，成功后状态回到 unauthenticated，
  /// 由路由守卫自动重定向到 /login 让用户登录。
  /// 用户名/邮箱重复 → error 态。
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      // 注册成功：回到未认证态，路由守卫会将 /register 重定向到 /login
      state = const AuthState.unauthenticated();
    } on NetworkException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 登出。
  ///
  /// 清除本地 Token，状态回到 unauthenticated。
  /// 路由守卫自动重定向到 /login。
  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }

  /// 401 拦截器触发的未授权回调。
  ///
  /// 由 [UnauthorizedController] 转发调用（见 auth_providers.dart）。
  /// 当非 /auth/ 端点收到 401 时，AuthInterceptor 已删除本地 Token，
  /// 此处只需更新状态让路由守卫重定向到 /login。
  ///
  /// 注意：不会调用 repository.logout()，因为 Token 已被拦截器删除。
  void handleUnauthorized() {
    state = const AuthState.unauthenticated();
  }

  /// 从 error 态恢复到未认证（用户点击"重试"按钮时调用）。
  void resetToUnauthenticated() {
    state = const AuthState.unauthenticated();
  }
}
