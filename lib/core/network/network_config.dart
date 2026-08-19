/// 网络层固定参数。
///
/// 与 [Env] 不同：这里存放的是与"环境"无关的工程参数，
/// 不论 dev / staging / production 都保持一致，
/// 因此不应通过 `--dart-define` 注入，避免误改。
library;

/// 网络层固定配置。
///
/// 修改这些参数会影响所有环境的网络行为，
/// 调整前请评估对后端和服务端稳定性的影响。
class NetworkConfig {
  NetworkConfig._();

  /// 普通请求连接超时（毫秒）。
  static const int connectTimeout = 15_000;

  /// 普通请求接收超时（毫秒）。
  static const int receiveTimeout = 30_000;

  /// 普通请求发送超时（毫秒）。
  static const int sendTimeout = 15_000;

  /// 失败重试次数（不含首次请求）。
  ///
  /// 仅对幂等 GET 请求生效，POST/PUT/DELETE 不重试，
  /// 避免在网络抖动时造成重复写入。
  static const int retryCount = 3;

  /// 重试基础间隔（毫秒），实际间隔按指数退避计算。
  static const int retryBaseDelay = 500;
}
