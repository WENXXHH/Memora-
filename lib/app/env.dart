/// 环境配置入口。
///
/// 通过 `--dart-define` 在编译期注入，运行期不可变。
/// 业务层只能通过 [Env.apiBaseUrl] 等字段间接读取，
/// 严禁直接访问 `String.fromEnvironment`。
library;

import 'package:flutter/foundation.dart' show kIsWeb;

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
/// 4. Web 平台不支持 `String.fromEnvironment`（Dart Web 限制），
///    通过 `kIsWeb` 在 const 上下文中跳过，Web 端一律使用默认值（development）。
class Env {
  Env._();

  // ---- 原始值（const 上下文，Web 端 kIsWeb=true 时编译器跳过 fromEnvironment） ----

  /// APP_ENV 原始字符串。Web 端恒为空，等价于默认 development。
  static const String _appEnvRaw = kIsWeb
      ? ''
      : String.fromEnvironment('APP_ENV');

  /// API_BASE_URL 原始字符串。Web 端恒为空，走 development 默认路径。
  static const String _apiBaseUrlRaw = kIsWeb
      ? ''
      : String.fromEnvironment('API_BASE_URL');

  // ---- 解析后的公开 API ----

  /// 当前环境。
  ///
  /// 通过 `--dart-define=APP_ENV=xxx` 注入；缺省时为 development。
  /// Web 端始终为 development（不支持 --dart-define）。
  static final Environment current = Environment.fromName(_appEnvRaw);

  /// API 基地址。
  ///
  /// 优先使用 `--dart-define=API_BASE_URL=xxx`；
  /// 缺省时只有 development 允许回退到本机地址，
  /// staging / production 缺值会在 [_resolveApiBaseUrl] 中抛异常。
  static final String apiBaseUrl = _resolveApiBaseUrl(_apiBaseUrlRaw, current);

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
        // 真机测试：使用电脑局域网 IP（同 WiFi 下）  http://192.168.2.43:8000/api
        // 模拟器：10.0.2.2 映射到宿主机 localhost  http://10.0.2.2:8000/api
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
