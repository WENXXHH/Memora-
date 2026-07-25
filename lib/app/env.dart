/// 环境配置中心

enum Environment { development, staging, production }

class Env {
  static const Environment current = Environment.development;
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const int requestTimeout = 30;
  static const int retryCount = 3;
  static bool get isDebug => current == Environment.development;
  static bool get isProduction => current == Environment.production;
}
