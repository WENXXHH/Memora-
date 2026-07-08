/// 当前运行环境
enum Environment {
  development,
  staging,
  production,
}

/// 环境配置类
class Env {
  /// 当前环境（默认开发环境）
  static const Environment current = Environment.development;

  /// API基础地址（预留，后期接入真实后端）
  static const String apiBaseUrl = 'http://localhost:8000/api';

  /// 请求超时时间（秒）
  static const int requestTimeout = 30;

  /// 重试次数
  static const int retryCount = 3;

  /// 是否启用日志（仅开发环境）
  static bool get isDebug => current == Environment.development;

  /// 是否生产环境
  static bool get isProduction => current == Environment.production;
}