// Freezed 2.x 在工厂构造参数上使用 @JsonKey 会触发 invalid_annotation_target
// 警告，但生成的代码正确（与 auth_models.dart 一致），可安全忽略。
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/services/word_book_id_map.dart';
import '../../domain/services/word_id_map.dart';
import 'word_review_model.dart';

part 'review_record_dto.freezed.dart';
part 'review_record_dto.g.dart';

/// 词库响应（GET /word-books 返回项）。
///
/// 后端 WordBook 模型的 JSON 快照，仅含同步所需的 id 和 name。
/// 通过 name 与 Flutter 端 wordBookId（如 "cet6"）按规范化匹配。
@freezed
class WordBookResponse with _$WordBookResponse {
  const factory WordBookResponse({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'is_builtin') @Default(false) bool isBuiltin,
    @JsonKey(name: 'owner_user_id') int? ownerUserId,
  }) = _WordBookResponse;

  factory WordBookResponse.fromJson(Map<String, dynamic> json) =>
      _$WordBookResponseFromJson(json);
}

/// 单词响应（GET /word-books/{id}/words 返回项）。
///
/// 通过 text 与 Flutter 端 Word.word 匹配，构建 String↔int wordId 映射。
@freezed
class WordResponse with _$WordResponse {
  const factory WordResponse({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'word_book_id') required int wordBookId,
    @JsonKey(name: 'text') required String text,
    @JsonKey(name: 'phonetic') String? phonetic,
    @JsonKey(name: 'meaning') String? meaning,
    @JsonKey(name: 'example') String? example,
  }) = _WordResponse;

  factory WordResponse.fromJson(Map<String, dynamic> json) =>
      _$WordResponseFromJson(json);
}

/// 学习记录同步项（对应后端 ReviewRecordSyncItem）。
///
/// HTTP 层使用后端 int 主键（wordBookId / wordId），
/// 通过 [WordBookIdMap] 和 [WordIdMap] 与 Flutter String 域互转（doc 0）。
///
/// 使用 [ReviewRecordDtoX] 扩展进行域模型转换，映射缺失时返回 null，
/// 由 UseCase 统计 unmappedCount 并跳过，不阻塞其他记录同步。
@freezed
class ReviewRecordDto with _$ReviewRecordDto {
  const factory ReviewRecordDto({
    @JsonKey(name: 'word_book_id') required int wordBookId,
    @JsonKey(name: 'word_id') required int wordId,
    @JsonKey(name: 'repetition_count') required int repetitionCount,
    @JsonKey(name: 'easiness_factor') required double easinessFactor,
    @JsonKey(name: 'interval') required int interval,
    @JsonKey(name: 'next_review_at') required DateTime nextReviewAt,
    @JsonKey(name: 'last_review_at') DateTime? lastReviewAt,
    @JsonKey(name: 'learned') required bool learned,
    @JsonKey(name: 'mastery') required double mastery,
    @JsonKey(name: 'client_updated_at') required DateTime clientUpdatedAt,
  }) = _ReviewRecordDto;

  factory ReviewRecordDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewRecordDtoFromJson(json);
}

/// DTO → 域模型转换扩展。
///
/// 独立扩展而非私有构造函数，避免 Freezed + json_serializable 冲突。
extension ReviewRecordDtoX on ReviewRecordDto {
  /// DTO → 域模型。映射缺失时返回 null（远端记录引用了已删除的词库或单词）。
  WordReview? toDomain(WordBookIdMap bookMap, WordIdMap wordMap) {
    final localBookId = bookMap.intToString(wordBookId);
    final localWordId = wordMap.intToString(wordId);
    if (localBookId == null || localWordId == null) return null;
    return WordReview(
      wordBookId: localBookId,
      wordId: localWordId,
      repetitionCount: repetitionCount,
      easinessFactor: easinessFactor,
      interval: interval,
      nextReviewDate: nextReviewAt,
      lastReviewDate: lastReviewAt,
      learned: learned,
      mastery: mastery,
      clientUpdatedAt: clientUpdatedAt,
    );
  }
}

/// 域模型 → DTO 转换辅助。
///
/// 静态方法形式，映射缺失时返回 null（本地词库在后端尚不存在）。
ReviewRecordDto? reviewRecordDtoFromDomain(
  WordReview review,
  WordBookIdMap bookMap,
  WordIdMap wordMap,
) {
  final wordBookId = bookMap.stringToInt(review.wordBookId);
  final wordId = wordMap.stringToInt(review.wordId);
  if (wordBookId == null || wordId == null) return null;
  return ReviewRecordDto(
    wordBookId: wordBookId,
    wordId: wordId,
    repetitionCount: review.repetitionCount,
    easinessFactor: review.easinessFactor,
    interval: review.interval,
    nextReviewAt: review.nextReviewDate,
    lastReviewAt: review.lastReviewDate,
    learned: review.learned,
    mastery: review.mastery,
    clientUpdatedAt: review.clientUpdatedAt!,
  );
}

/// POST /records/sync 请求体。
@freezed
class ReviewRecordSyncRequest with _$ReviewRecordSyncRequest {
  const factory ReviewRecordSyncRequest({
    @JsonKey(name: 'records') required List<ReviewRecordDto> records,
  }) = _ReviewRecordSyncRequest;

  factory ReviewRecordSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRecordSyncRequestFromJson(json);
}

/// GET /records 和 POST /records/sync 响应体。
///
/// records：服务器最终 canonical records（含时间戳保护后的结果）。
/// serverTime：仅用于日志诊断，不参与客户端冲突解决。
@freezed
class ReviewRecordSyncResponse with _$ReviewRecordSyncResponse {
  const factory ReviewRecordSyncResponse({
    @JsonKey(name: 'records') required List<ReviewRecordDto> records,
    @JsonKey(name: 'server_time') required DateTime serverTime,
  }) = _ReviewRecordSyncResponse;

  factory ReviewRecordSyncResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewRecordSyncResponseFromJson(json);
}
