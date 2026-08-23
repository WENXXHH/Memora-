/// 同步仓库层。
///
/// 薄包装 [ReviewSyncRemoteDataSource]，统一暴露同步相关远端接口。
/// 不负责 ID 映射和域模型转换（映射表在 UseCase 中构建，doc 0/13）。
///
/// 职责边界：
/// - ReviewRepository → 本地 Hive 读写
/// - ReviewSyncRepository → 远端 HTTP 调用（返回 DTO）
/// - SyncReviewRecordsUseCase → 协调两者 + 映射 + 合并
library;

import '../dto/review_record_dto.dart';
import '../sources/remote/review_sync_remote_data_source.dart';
import '../../core/network/network_exception.dart';

class ReviewSyncRepository {
  ReviewSyncRepository(this._remoteDataSource);

  final ReviewSyncRemoteDataSource _remoteDataSource;

  /// 获取当前用户可见的词库列表。
  Future<List<WordBookResponse>> fetchWordBooks() async {
    try {
      return await _remoteDataSource.fetchWordBooks();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: '获取词库列表失败',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 获取指定词库的全部单词。
  Future<List<WordResponse>> fetchWords(int bookId) async {
    try {
      return await _remoteDataSource.fetchWords(bookId);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: '获取单词列表失败',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 拉取当前用户全部学习记录。
  Future<ReviewRecordSyncResponse> fetchRecords() async {
    try {
      return await _remoteDataSource.fetchRecords();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: '拉取学习记录失败',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 批量上传学习记录，返回服务器最终 canonical records。
  Future<ReviewRecordSyncResponse> syncRecords(
    List<ReviewRecordDto> records,
  ) async {
    try {
      return await _remoteDataSource.syncRecords(records);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: '同步学习记录失败',
        type: NetworkErrorType.unknown,
        originalError: e,
      );
    }
  }
}
