/// 学习记录同步远程数据源。
///
/// 直接对接后端同步相关端点：
/// - GET  /v1/word-books          词库列表（构建 ID 映射表）
/// - GET  /v1/word-books/{id}/words 单词列表（构建 ID 映射表）
/// - GET  /v1/records             拉取当前用户全部学习记录
/// - POST /v1/records/sync        批量上传学习记录（带时间戳保护）
///
/// 复用第五周 dioProvider + AuthInterceptor（原则 15：不创建第二套网络基础设施）。
/// Token 自动注入、401 自动跳登录由 AuthInterceptor 处理。
library;

import 'package:dio/dio.dart';

import '../../dto/review_record_dto.dart';
import '../../../core/network/network_exception.dart';

/// 同步远程数据源。
///
/// Dio 实例的 baseUrl 已配置为 `http://.../api`，
/// 此处使用相对路径 `/v1/...`，与 [AuthRemoteDataSource] 一致。
class ReviewSyncRemoteDataSource {
  ReviewSyncRemoteDataSource(this._dio);

  final Dio _dio;

  /// 获取当前用户可见的词库列表（GET /word-books）。
  ///
  /// 用于构建 [WordBookIdMap]：name → int id 映射。
  Future<List<WordBookResponse>> fetchWordBooks() async {
    try {
      final response = await _dio.get<List<dynamic>>('/v1/word-books');
      final data = response.data ?? [];
      return data
          .cast<Map<String, dynamic>>()
          .map(WordBookResponse.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }

  /// 获取指定词库的全部单词（GET /word-books/{bookId}/words）。
  ///
  /// 用于构建 [WordIdMap]：text → int id 映射。
  Future<List<WordResponse>> fetchWords(int bookId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/v1/word-books/$bookId/words');
      final data = response.data ?? [];
      return data
          .cast<Map<String, dynamic>>()
          .map(WordResponse.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }

  /// 拉取当前用户全部学习记录（GET /records）。
  ///
  /// 返回服务器当前 canonical records + server_time。
  /// server_time 仅用于日志诊断，不参与客户端冲突解决。
  Future<ReviewRecordSyncResponse> fetchRecords() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/records');
      return ReviewRecordSyncResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }

  /// 批量上传学习记录（POST /records/sync）。
  ///
  /// 后端逐条执行时间戳保护（doc 9）：
  /// incoming.client_updated_at > existing → UPDATE
  /// incoming.client_updated_at <= existing → IGNORE
  ///
  /// 返回服务器最终 canonical records（含合并后的最终状态）。
  Future<ReviewRecordSyncResponse> syncRecords(
    List<ReviewRecordDto> records,
  ) async {
    try {
      final request = ReviewRecordSyncRequest(records: records);
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/records/sync',
        data: request.toJson(),
      );
      return ReviewRecordSyncResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error is NetworkException ? e.error! : e;
    }
  }
}
