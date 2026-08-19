/// 网络层统一异常。
///
/// 把 [DioException] 转成业务层可读的语义化错误，
/// 避免 UI 层直接依赖 Dio 类型，方便未来替换 HTTP 客户端。
library;

import 'package:dio/dio.dart';

/// 网络请求业务异常。
///
/// - [type] 用于 UI 决定提示文案与重试按钮显示策略
/// - [statusCode] 可能为 null（如连接超时、DNS 失败等无响应场景）
class NetworkException implements Exception {
  NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  /// 面向用户的简短文案（已本地化）。
  final String message;

  /// 错误类别，便于 UI 分支处理。
  final NetworkErrorType type;

  /// HTTP 状态码，无响应时为 null。
  final int? statusCode;

  /// 原始异常，便于日志上报，不应展示给用户。
  final Object? originalError;

  @override
  String toString() => 'NetworkException($type, $statusCode): $message';
}

/// 网络错误类别。
enum NetworkErrorType {
  /// 连接失败（超时、DNS、网络断开）
  connection,

  /// 401 未授权，需重新登录
  unauthorized,

  /// 403 无权限
  forbidden,

  /// 404 资源不存在
  notFound,

  /// 5xx 服务端错误
  server,

  /// 请求被取消
  cancelled,

  /// 其他无法归类的错误
  unknown,
}

/// 把 [DioException] 转成 [NetworkException]。
///
/// 作为 [ErrorInterceptor] 的核心映射逻辑，
/// 单独导出便于单元测试。
NetworkException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return NetworkException(
        message: '网络连接失败，请检查网络后重试',
        type: NetworkErrorType.connection,
        originalError: e,
      );
    case DioExceptionType.transformTimeout:
      // 响应体转换阶段超时，按连接失败处理
      return NetworkException(
        message: '网络连接失败，请检查网络后重试',
        type: NetworkErrorType.connection,
        originalError: e,
      );
    case DioExceptionType.badCertificate:
      return NetworkException(
        message: '证书校验失败',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
    case DioExceptionType.cancel:
      return NetworkException(
        message: '请求已取消',
        type: NetworkErrorType.cancelled,
        originalError: e,
      );
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode ?? 0;
      switch (code) {
        case 401:
          return NetworkException(
            message: '登录已过期，请重新登录',
            type: NetworkErrorType.unauthorized,
            statusCode: code,
            originalError: e,
          );
        case 403:
          return NetworkException(
            message: '暂无权限执行此操作',
            type: NetworkErrorType.forbidden,
            statusCode: code,
            originalError: e,
          );
        case 404:
          return NetworkException(
            message: '请求的资源不存在',
            type: NetworkErrorType.notFound,
            statusCode: code,
            originalError: e,
          );
        case >= 500 && <= 599:
          return NetworkException(
            message: '服务器开小差了，请稍后再试',
            type: NetworkErrorType.server,
            statusCode: code,
            originalError: e,
          );
        default:
          return NetworkException(
            message: '请求失败（$code）',
            type: NetworkErrorType.unknown,
            statusCode: code,
            originalError: e,
          );
      }
    case DioExceptionType.unknown:
      return NetworkException(
        message: '未知网络错误',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
  }
}
