import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/user_data_space_service.dart';
import '../state/auth_state.dart';

/// 认证状态控制器。
///
/// 职责：
/// 1. 管理 [AuthState] 7 态机
/// 2. 调用 [AuthRepository] 执行登录/注册/登出/恢复会话
/// 3. 区分"密码错误"与"网络错误"——前者设为 error 态，后者保留 Token
/// 4. 认证态变化时同步切换本地数据所有者空间（见 [UserDataSpaceService]），
///    保证游客 / 各账号的复习数据互不可见
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authRepository, this._userDataSpace)
    : super(const AuthState.unknown());

  final AuthRepository _authRepository;
  final UserDataSpaceService _userDataSpace;

  /// 启动时恢复会话。
  ///
  /// 流程：
  /// - 无 Token → unauthenticated
  /// - 有 Token + /auth/me 成功 → authenticated
  /// - 有 Token + 401 → 删 Token → unauthenticated
  /// - 有 Token + 网络错误 → 不删 Token → error
  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    try {
      final result = await _authRepository.restoreSession();

      if (result.isValid && result.user != null) {
        // 恢复成功：对齐数据所有者空间（幂等，guest 空间为空时是 no-op）
        await _userDataSpace.switchToUser(result.user!.id.toString());
        state = AuthState.authenticated(result.user!);
      } else {
        // noToken 或 invalidToken → 都需要登录
        state = const AuthState.unauthenticated();
      }
    } on NetworkException catch (e) {
      // 网络错误（超时/断网）：不删 Token，显示错误让用户重试
      // Token 仍保留在本地，下次恢复时可再次尝试验证
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    }
  }

  /// 登录。
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
      // 先把 guest 空间学习成果迁入该用户空间并切换 owner，
      // 再置 authenticated（AppBootstrap 会在 authenticated 边沿触发同步，
      // 此时必须已读到切换后的空间）
      await _userDataSpace.switchToUser(user.id.toString());
      state = AuthState.authenticated(user);
    } on NetworkException catch (e) {
      // 登录接口的 401 是「密码错误」，不是「Token 过期」
      final message = e.statusCode == 401 ? '用户名或密码错误，请重新输入' : e.message;
      state = AuthState(status: AuthStatus.error, errorMessage: message);
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
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    }
  }

  /// 登出。
  ///
  /// 清除本地 Token，数据所有者空间切回 guest（该账号数据保留在
  /// 自己的命名空间里，重新登录自动恢复），状态回到 unauthenticated。
  /// 路由守卫自动重定向到 /login。
  Future<void> logout() async {
    await _authRepository.logout();
    await _userDataSpace.switchToGuest();
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

  /// 进入游客模式。
  ///
  /// 由登录页「游客模式」入口调用：跳过登录，直接进入主界面。
  /// 游客可使用全部离线学习功能（本地 Hive 持久化），
  /// 但登录 / 云同步仍需要正式账号。
  /// 数据所有者空间切回 guest（幂等）。
  Future<void> enterGuestMode() async {
    await _userDataSpace.switchToGuest();
    state = const AuthState.guest();
  }
}
