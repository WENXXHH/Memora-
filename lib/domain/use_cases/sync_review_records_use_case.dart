import '../services/word_book_id_map.dart';
import '../services/word_id_map.dart';
import '../services/review_sync_merger.dart';
import '../../data/dto/review_record_dto.dart';
import '../../data/dto/word_review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/review_sync_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../../core/network/network_exception.dart';

/// 同步操作结果。
///
/// Controller 根据此结果更新 [SyncState]。
class SyncResult {
  const SyncResult.success({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.conflictCount,
    required this.unmappedCount,
  }) : success = true,
       errorMessage = null;

  const SyncResult.failure(this.errorMessage)
    : success = false,
      uploadedCount = 0,
      downloadedCount = 0,
      conflictCount = 0,
      unmappedCount = 0;

  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictCount;
  final int unmappedCount;
  final String? errorMessage;
}

/// 学习记录同步 UseCase（doc 12 完整流程）。
///
/// 协调本地 Repository + 远端 Repository + ReviewSyncMerger：
/// ```
/// 读取 Hive → 构建 ID 映射 → GET /records → DTO→Domain → merge
/// → recordsToUpload → POST /records/sync → 响应→Domain → 写回 Hive
/// ```
///
/// 原则 12：网络失败前不清空、不重建 Hive（Bug 6 防御）。
/// 原则 11：同步幂等 — 相同输入产生相同结果，不制造重复记录。
/// doc 3：写回 Hive 时保留服务器记录的 clientUpdatedAt，不刷新为 now()。
class SyncReviewRecordsUseCase {
  SyncReviewRecordsUseCase(
    this._localReviewRepo,
    this._wordRepo,
    this._syncRepo,
  );

  final ReviewRepository _localReviewRepo;
  final WordRepository _wordRepo;
  final ReviewSyncRepository _syncRepo;

  /// 执行同步。
  ///
  /// [wordBookId] 当前同步的词库标识（如 "cet6"）。
  /// 第六周只处理内置 CET-6 词库，单词库同步。
  Future<SyncResult> execute(String wordBookId) async {
    try {
      // 1. 构建 ID 映射表（doc 0）
      final remoteBooks = await _syncRepo.fetchWordBooks();
      final bookMap = WordBookIdMap.fromBooks(remoteBooks);

      final remoteBookId = bookMap.stringToInt(wordBookId);
      if (remoteBookId == null) {
        return SyncResult.failure('词库映射缺失: $wordBookId');
      }

      final remoteWords = await _syncRepo.fetchWords(remoteBookId);
      final localWords = await _wordRepo.getWords(wordBookId);
      final wordMap = WordIdMap.fromWords(
        remoteWords: remoteWords,
        localWords: localWords,
      );

      // 2. 拉取远端记录 → 转为 String 域
      final remoteResponse = await _syncRepo.fetchRecords();
      final remoteReviews = remoteResponse.records
          .map((dto) => dto.toDomain(bookMap, wordMap))
          .whereType<WordReview>() // 过滤映射缺失的记录
          .toList();

      // 3. 读取本地记录
      final localReviews = await _localReviewRepo.getAllReviews(wordBookId);

      // 4. 合并（纯函数，String 域）
      final mergeResult = ReviewSyncMerger.merge(
        local: localReviews,
        remote: remoteReviews,
      );

      // 5. 上传需要同步的记录
      var uploadedCount = 0;
      var unmappedCount = 0;
      List<WordReview> recordsToWrite = mergeResult.recordsToWriteLocal;

      if (mergeResult.recordsToUpload.isNotEmpty) {
        final uploadDtos = <ReviewRecordDto>[];
        for (final review in mergeResult.recordsToUpload) {
          final dto = reviewRecordDtoFromDomain(review, bookMap, wordMap);
          if (dto != null) {
            uploadDtos.add(dto);
          } else {
            unmappedCount++;
          }
        }

        if (uploadDtos.isNotEmpty) {
          final syncResponse = await _syncRepo.syncRecords(uploadDtos);
          // 服务器返回 canonical records，写回 Hive（保留原始 clientUpdatedAt，doc 3）
          final serverRecords = syncResponse.records
              .map((dto) => dto.toDomain(bookMap, wordMap))
              .whereType<WordReview>()
              .toList();
          recordsToWrite = serverRecords;
          uploadedCount = uploadDtos.length;
        }
      }

      // 6. 写回 Hive（Bug 6：失败前不清空，仅在确认结果后写入）
      await _localReviewRepo.saveWordReviews(recordsToWrite);

      return SyncResult.success(
        uploadedCount: uploadedCount,
        downloadedCount: recordsToWrite.length,
        conflictCount: mergeResult.conflictCount,
        unmappedCount: unmappedCount,
      );
    } on NetworkException catch (e) {
      // 网络错误：保留 Token 和 Hive（原则 13：不断网退登）
      return SyncResult.failure(e.message);
    } catch (e) {
      return SyncResult.failure('同步失败: $e');
    }
  }
}
