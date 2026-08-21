/// 错误转换拦截器：统一把 [DioException] 转成 [NetworkException]。
///
/// 业务层只需 catch [NetworkException]，无需直接依赖 Dio 类型。
library;

import 'package:dio/dio.dart';

import '../network_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 已经被上层包装过的不再二次包装
    if (err.error is NetworkException) {
      handler.next(err);
      return;
    }
    final mapped = mapDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        response: err.response,
        error: mapped,
        stackTrace: err.stackTrace,
        message: mapped.message,
      ),
    );
  }
}
