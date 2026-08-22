import '../../data/dto/word_review_model.dart';
import 'merge_result.dart';

/// 复习记录同步合并器（纯函数，无副作用）。
///
/// 输入 local + remote 两端记录列表，按联合 Key `$wordBookId:$wordId`
/// 对齐后比较 [WordReview.clientUpdatedAt]，执行 Last Write Wins 合并。
///
/// 前置条件：remote 记录在进入 merger 前已通过 ID 映射表
/// 将后端 int ID 转为 Flutter String ID（详见 doc 0 ID 边界转换策略）。
class ReviewSyncMerger {
  const ReviewSyncMerger._();

  /// epoch 时间戳，用于 clientUpdatedAt 为 null 时兜底（视为最旧）。
  static final DateTime _epoch =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// 合并 local 与 remote 记录列表。
  static MergeResult merge({
    required List<WordReview> local,
    required List<WordReview> remote,
  }) {
    final localMap = <String, WordReview>{
      for (final r in local) _key(r): r,
    };
    final remoteMap = <String, WordReview>{
      for (final r in remote) _key(r): r,
    };

    final allKeys = {...localMap.keys, ...remoteMap.keys};

    final mergedRecords = <WordReview>[];
    final recordsToUpload = <WordReview>[];
    final recordsToWriteLocal = <WordReview>[];
    var localWinCount = 0;
    var remoteWinCount = 0;
    var conflictCount = 0;

    for (final key in allKeys) {
      final localReview = localMap[key];
      final remoteReview = remoteMap[key];

      if (localReview == null && remoteReview != null) {
        // 仅远端存在
        mergedRecords.add(remoteReview);
        recordsToWriteLocal.add(remoteReview);
        remoteWinCount++;
      } else if (localReview != null && remoteReview == null) {
        // 仅本地存在
        mergedRecords.add(localReview);
        recordsToUpload.add(localReview);
        localWinCount++;
      } else if (localReview != null && remoteReview != null) {
        // 两端都存在 → 比较 clientUpdatedAt
        conflictCount++;
        final localTime = localReview.clientUpdatedAt ?? _epoch;
        final remoteTime = remoteReview.clientUpdatedAt ?? _epoch;

        if (localTime.isAfter(remoteTime)) {
          // 本地更新
          mergedRecords.add(localReview);
          recordsToUpload.add(localReview);
          localWinCount++;
        } else {
          // 远端更新或时间相同（相同时间远端优先，避免重复上传）
          mergedRecords.add(remoteReview);
          recordsToWriteLocal.add(remoteReview);
          remoteWinCount++;
        }
      }
    }

    return MergeResult(
      mergedRecords: mergedRecords,
      recordsToUpload: recordsToUpload,
      recordsToWriteLocal: recordsToWriteLocal,
      localWinCount: localWinCount,
      remoteWinCount: remoteWinCount,
      conflictCount: conflictCount,
    );
  }

  static String _key(WordReview r) => '${r.wordBookId}:${r.wordId}';
}
