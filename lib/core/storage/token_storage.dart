/// Token 本地持久化封装。
///
/// 复用现有 Hive `auth` Box（`Box<String>`）和 `kAccessTokenKey` 常量，
/// 不引入 flutter_secure_storage，遵循第五周原则 11：
/// "Token 使用安全存储，不放入普通 Hive"——此处 `auth` Box 独立于业务 Box，
/// 语义上已与 `reviews` Box 分离。
library;

import 'package:hive_ce/hive_ce.dart';

import '../network/interceptors/auth_interceptor.dart';

/// Token 读写抽象。
///
/// 由 [AuthRepository] 持有，负责 JWT 的本地存取与清除。
/// 拦截器（[AuthInterceptor]）直接读 Box，不走这里，避免循环依赖。
class TokenStorage {
  TokenStorage(this._authBox);

  final Box<String> _authBox;

  /// 读取已保存的 access token，不存在时返回 null。
  String? readToken() => _authBox.get(kAccessTokenKey);

  /// 保存 access token（覆盖写入）。
  Future<void> saveToken(String token) async {
    await _authBox.put(kAccessTokenKey, token);
  }

  /// 清除本地 access token（登出 / 401 失效时调用）。
  Future<void> deleteToken() async {
    await _authBox.delete(kAccessTokenKey);
  }

  /// 是否存在已保存的 token（用于启动恢复判断）。
  bool get hasToken {
    final token = _authBox.get(kAccessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
