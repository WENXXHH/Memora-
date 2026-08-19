/// 与 [Env] 分离：本文件只负责"字符串 → 枚举"的映射，
library;

/// 应用运行环境。
enum Environment {
  /// 本地开发，连本机 FastAPI（10.0.2.2:8000）
  development,

  /// 联调测试，连测试服务器
  staging,

  /// 正式发布，连接真正给用户的服务器
  production;

  /// 接收一个字符串，然后返回对应的 Environment 枚举。
  static Environment fromName(String? name) {
    switch (name) {
      case 'development':
      case null:
      case '':
        // 缺省（null 或空串）时仅允许 development，
        // 因为本地开发无需手动传 dart-define
        return Environment.development;
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        // 未知值直接抛异常：宁可启动失败也不要连错环境
        throw ArgumentError(
          'Unknown APP_ENV: "$name". '
          'Expected one of: development, staging, production.',
        );
    }
  }
}
