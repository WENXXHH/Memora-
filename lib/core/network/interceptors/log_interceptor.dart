/// 日志拦截器：仅在非 production 环境输出请求/响应摘要。
///
/// 关键原因：
/// - production 下打印响应体可能泄露用户数据到 Logcat
/// - 大量日志会拖慢真机调试性能
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../app/env.dart';

/// 开发期日志拦截器。
///
/// production 环境下直接 next，不做任何处理。
class LogInterceptorImpl extends Interceptor {
  LogInterceptorImpl();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Env.isProduction) {
      handler.next(options);
      return;
    }
    debugPrint(
      '[HTTP] → ${options.method} ${options.uri}\n'
      '      headers=${options.headers}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Env.isProduction) {
      handler.next(response);
      return;
    }
    debugPrint(
      '[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Env.isProduction) {
      handler.next(err);
      return;
    }
    debugPrint(
      '[HTTP] ✗ ${err.type} ${err.requestOptions.uri}\n'
      '      ${err.message}',
    );
    handler.next(err);
  }
}
