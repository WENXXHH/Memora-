import '../../data/dto/word_review_model.dart';

/// 同步合并结果。
///
/// - [mergedRecords]：合并后的全部记录（并集，冲突已解决）。
/// - [recordsToUpload]：本地胜利或本地独有，需上传到服务器。
/// - [recordsToWriteLocal]：远端胜利或远端独有，需写入 Hive。
/// - [localWinCount]：本地数据成为最终结果的记录数（含本地独有）。
/// - [remoteWinCount]：远端数据成为最终结果的记录数（含远端独有）。
/// - [conflictCount]：两端都存在同一记录的冲突次数。
class MergeResult {
  const MergeResult({
    required this.mergedRecords,
    required this.recordsToUpload,
    required this.recordsToWriteLocal,
    required this.localWinCount,
    required this.remoteWinCount,
    required this.conflictCount,
  });

  final List<WordReview> mergedRecords;
  final List<WordReview> recordsToUpload;
  final List<WordReview> recordsToWriteLocal;
  final int localWinCount;
  final int remoteWinCount;
  final int conflictCount;
}
