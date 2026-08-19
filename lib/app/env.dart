/// 环境配置入口。
///
/// 通过 `--dart-define` 在编译期注入，运行期不可变。
/// 业务层只能通过 [Env.apiBaseUrl] 等字段间接读取，
/// 严禁直接访问 `String.fromEnvironment`。
library;

import 'app_environment.dart';

/// 全局环境配置。
///
/// 设计原则：
/// 1. 运行期不可变，首次访问时求值（AOT 下底层常量会被编译器折叠）。
///    因 `Environment.fromName` 是普通方法，无法用 `static const`，
///    改用 `static final`，结果与 const 等价但求值时机为懒加载。
/// 2. development 允许缺省 `API_BASE_URL`（用本机模拟器地址），
///    staging / production 必须显式传入，否则 fail fast。
/// 3. 不混入 `isDebug` 这种与构建模式相关的概念，
///    需要判断构建模式时使用 `kDebugMode`（来自 foundation）。
class Env {
  Env._();

  /// 当前环境。
  ///
  /// 通过 `--dart-define=APP_ENV=xxx` 注入；缺省时为 development。
  static final Environment current = Environment.fromName(
    String.fromEnvironment('APP_ENV'),
  );

  /// API 基地址。
  ///
  /// 优先使用 `--dart-define=API_BASE_URL=xxx`；
  /// 缺省时只有 development 允许回退到本机地址，
  /// staging / production 缺值会在 [_resolveApiBaseUrl] 中抛异常。
  static final String apiBaseUrl = _resolveApiBaseUrl(
    String.fromEnvironment('API_BASE_URL'),
    current,
  );

  /// 语义化环境判断，取代旧的 `isDebug`,减少歧义。
  static final bool isDevelopment = current == Environment.development;
  static final bool isStaging = current == Environment.staging;
  static final bool isProduction = current == Environment.production;

  /// 解析 API 基地址。
  ///
  /// - development：允许用默认 `http://10.0.2.2:8000/api`，便于模拟器访问本机 FastAPI
  /// - staging / production：必须显式传入，否则启动期即抛异常，
  ///   防止线上包静默连到开发服务器
  static String _resolveApiBaseUrl(String defined, Environment env) {
    if (defined.isNotEmpty) return defined;

    switch (env) {
      case Environment.development:
        // Android 模拟器内 10.0.2.2 映射到宿主机 localhost
        return 'http://10.0.2.2:8000/api';
      case Environment.staging:
        throw StateError(
          'API_BASE_URL must be provided for staging environment. '
          'Use --dart-define=API_BASE_URL=...',
        );
      case Environment.production:
        throw StateError(
          'API_BASE_URL must be provided for production environment. '
          'Use --dart-define=API_BASE_URL=...',
        );
    }
  }
}
//打包时
//flutter build apk --flavor production --release --split-per-abi --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.memora.app/api