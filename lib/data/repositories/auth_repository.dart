/// 认证仓库。
///
/// 职责：
/// 1. 封装 [AuthRemoteDataSource] 调用，面向业务层提供统一接口
/// 2. 登录成功后保存 Token / 登出清除 Token / 启动恢复会话
/// 3. 区分"Token 无效"（401）与"暂时无网络"——前者删 Token，后者保留
///
/// 原则 14：断网和 Token 失效不能混为一谈。
library;

import '../../core/network/network_exception.dart';
import '../../core/storage/token_storage.dart';
import '../dto/auth_models.dart';
import '../sources/auth_remote_data_source.dart';

/// 会话恢复结果。
///
/// 区分三种情况：
/// - [valid]：Token 有效，返回当前用户
/// - [noToken]：本地无 Token，需要登录
/// - [invalidToken]：Token 已过期/无效，已清除本地 Token
class RestoreSessionResult {
  const RestoreSessionResult._({this.user, required RestoreKind kind})
    : _kind = kind;

  final RemoteUser? user;
  final RestoreKind _kind;

  static const noToken = RestoreSessionResult._(kind: RestoreKind.noToken);
  static const invalidToken = RestoreSessionResult._(
    kind: RestoreKind.invalidToken,
  );

  factory RestoreSessionResult.valid(RemoteUser user) =>
      RestoreSessionResult._(user: user, kind: RestoreKind.valid);

  bool get isValid => _kind == RestoreKind.valid;
  bool get isNoToken => _kind == RestoreKind.noToken;
  bool get isInvalidToken => _kind == RestoreKind.invalidToken;
}

/// 会话恢复结果类别。
enum RestoreKind { valid, noToken, invalidToken }

class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  /// 注册新用户。
  ///
  /// 后端注册接口不返回 Token，注册后需用户手动登录。
  /// 用户名/邮箱重复 → 后端 409，调用方需 catch [NetworkException]。
  Future<RemoteUser> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );
  }

  /// 登录。
  ///
  /// 成功后保存 Token 到本地存储。
  /// 密码错误 → 后端 401，调用方需 catch [NetworkException]。
  Future<RemoteUser> login({
    required String username,
    required String password,
  }) async {
    final tokenResponse = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    await _tokenStorage.saveToken(tokenResponse.accessToken);
    return tokenResponse.user;
  }

  /// 登出：清除本地 Token。
  ///
  /// 不调用后端（JWT 无状态，本地清除即等效登出）。
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  /// 启动时恢复会话。
  ///
  /// 流程（遵循 §2.4 启动恢复）：
  /// ```
  /// 读 Token
  ///   ├─ 无 Token → noToken
  ///   └─ 有 Token → GET /auth/me
  ///        ├─ 成功 → valid(user)
  ///        ├─ 401 → 删 Token → invalidToken
  ///        └─ 网络错误 → 不删 Token → 抛异常（调用方显示离线/重试）
  /// ```
  Future<RestoreSessionResult> restoreSession() async {
    if (!_tokenStorage.hasToken) {
      return RestoreSessionResult.noToken;
    }

    try {
      final user = await _remoteDataSource.getCurrentUser();
      return RestoreSessionResult.valid(user);
    } on NetworkException catch (e) {
      if (e.type == NetworkErrorType.unauthorized) {
        // Token 已过期/无效：清除本地凭证
        await _tokenStorage.deleteToken();
        return RestoreSessionResult.invalidToken;
      }
      // 网络错误（超时/断网）：不删 Token，向上抛出
      // 调用方可显示"网络不可用，离线模式"或重试
      rethrow;
    }
  }
}
