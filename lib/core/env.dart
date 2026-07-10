/// 运行环境枚举
///
/// 定义应用支持的三种运行环境：
/// - development: 开发环境，用于本地开发和测试
/// - staging: 预发布环境，用于上线前验证
/// - production: 生产环境，面向用户的正式版本
enum Environment { development, staging, production }

/// 环境配置类
///
/// 集中管理所有环境相关的配置常量
/// 采用静态常量模式，无需实例化即可访问
///
/// 使用方式：
/// ```dart
/// if (Env.isDebug) {
///   print('Debug mode enabled');
/// }
/// final url = '${Env.apiBaseUrl}/words';
/// ```
class Env {
  /// 当前运行环境
  ///
  /// 默认值为 development，开发阶段使用
  /// 上线前需修改为 production
  static const Environment current = Environment.development;

  /// API 基础地址
  ///
  /// 预留字段，后期接入真实后端时使用
  /// 当前使用 Mock 数据，此配置暂未生效
  static const String apiBaseUrl = 'http://localhost:8000/api';

  /// 请求超时时间（单位：秒）
  ///
  /// 用于 Dio 网络请求的超时设置
  static const int requestTimeout = 30;

  /// 重试次数
  ///
  /// 网络请求失败时的最大重试次数
  static const int retryCount = 3;

  /// 是否为调试模式
  ///
  /// 返回 true 表示当前处于开发环境
  /// 可用于控制日志输出、调试工具等功能的开关
  static bool get isDebug => current == Environment.development;

  /// 是否为生产环境
  ///
  /// 返回 true 表示当前处于生产环境
  /// 可用于控制敏感信息的显示、性能优化等
  static bool get isProduction => current == Environment.production;
}
