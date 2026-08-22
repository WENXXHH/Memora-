import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/domain/services/review_sync_merger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordReview makeReview({
    required String wordId,
    String wordBookId = 'cet6',
    int repetitionCount = 1,
    double easinessFactor = 2.5,
    int interval = 1,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    bool learned = false,
    double mastery = 0.0,
    DateTime? clientUpdatedAt,
  }) {
    final now = DateTime(2026, 8, 22);
    return WordReview(
      wordId: wordId,
      wordBookId: wordBookId,
      repetitionCount: repetitionCount,
      easinessFactor: easinessFactor,
      interval: interval,
      nextReviewDate: nextReviewDate ?? now,
      lastReviewDate: lastReviewDate,
      learned: learned,
      mastery: mastery,
      clientUpdatedAt: clientUpdatedAt,
    );
  }

  group('ReviewSyncMerger.merge', () {
    test('两端均为空 → 结果为空', () {
      final result = ReviewSyncMerger.merge(local: [], remote: []);

      expect(result.mergedRecords, isEmpty);
      expect(result.recordsToUpload, isEmpty);
      expect(result.recordsToWriteLocal, isEmpty);
      expect(result.localWinCount, 0);
      expect(result.remoteWinCount, 0);
      expect(result.conflictCount, 0);
    });

    test('仅本地存在 → 全部上传，无本地写入', () {
      final local = [
        makeReview(wordId: '1', clientUpdatedAt: DateTime(2026, 8, 20)),
        makeReview(wordId: '2', clientUpdatedAt: DateTime(2026, 8, 21)),
      ];

      final result = ReviewSyncMerger.merge(local: local, remote: []);

      expect(result.mergedRecords.length, 2);
      expect(result.recordsToUpload.length, 2);
      expect(result.recordsToWriteLocal, isEmpty);
      expect(result.localWinCount, 2);
      expect(result.remoteWinCount, 0);
      expect(result.conflictCount, 0);
    });

    test('仅远端存在 → 全部写入本地，无上传', () {
      final remote = [
        makeReview(wordId: '1', clientUpdatedAt: DateTime(2026, 8, 20)),
        makeReview(wordId: '2', clientUpdatedAt: DateTime(2026, 8, 21)),
      ];

      final result = ReviewSyncMerger.merge(local: [], remote: remote);

      expect(result.mergedRecords.length, 2);
      expect(result.recordsToUpload, isEmpty);
      expect(result.recordsToWriteLocal.length, 2);
      expect(result.localWinCount, 0);
      expect(result.remoteWinCount, 2);
      expect(result.conflictCount, 0);
    });

    test('两端存在同一记录，本地更新 → 上传本地，不写入本地', () {
      final t1 = DateTime(2026, 8, 20);
      final t2 = DateTime(2026, 8, 21);
      final local = [makeReview(wordId: '1', repetitionCount: 3, clientUpdatedAt: t2)];
      final remote = [makeReview(wordId: '1', repetitionCount: 1, clientUpdatedAt: t1)];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      expect(result.mergedRecords.length, 1);
      expect(result.mergedRecords.first.repetitionCount, 3);
      expect(result.recordsToUpload.length, 1);
      expect(result.recordsToUpload.first.repetitionCount, 3);
      expect(result.recordsToWriteLocal, isEmpty);
      expect(result.localWinCount, 1);
      expect(result.remoteWinCount, 0);
      expect(result.conflictCount, 1);
    });

    test('两端存在同一记录，远端更新 → 写入远端，不上传', () {
      final t1 = DateTime(2026, 8, 20);
      final t2 = DateTime(2026, 8, 21);
      final local = [makeReview(wordId: '1', repetitionCount: 1, clientUpdatedAt: t1)];
      final remote = [makeReview(wordId: '1', repetitionCount: 3, clientUpdatedAt: t2)];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      expect(result.mergedRecords.length, 1);
      expect(result.mergedRecords.first.repetitionCount, 3);
      expect(result.recordsToUpload, isEmpty);
      expect(result.recordsToWriteLocal.length, 1);
      expect(result.recordsToWriteLocal.first.repetitionCount, 3);
      expect(result.localWinCount, 0);
      expect(result.remoteWinCount, 1);
      expect(result.conflictCount, 1);
    });

    test('两端时间戳相同 → 远端优先，写入远端，不上传', () {
      final t = DateTime(2026, 8, 21, 12, 0);
      final local = [makeReview(wordId: '1', repetitionCount: 2, clientUpdatedAt: t)];
      final remote = [makeReview(wordId: '1', repetitionCount: 5, clientUpdatedAt: t)];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      expect(result.mergedRecords.first.repetitionCount, 5);
      expect(result.recordsToUpload, isEmpty);
      expect(result.recordsToWriteLocal.length, 1);
      expect(result.remoteWinCount, 1);
      expect(result.conflictCount, 1);
    });

    test('混合场景：仅本地 + 仅远端 + 冲突', () {
      final tOld = DateTime(2026, 8, 19);
      final tMid = DateTime(2026, 8, 20);
      final tNew = DateTime(2026, 8, 21);

      final local = [
        makeReview(wordId: '1', clientUpdatedAt: tNew), // 仅本地
        makeReview(wordId: '2', clientUpdatedAt: tNew), // 本地更新
        makeReview(wordId: '3', clientUpdatedAt: tOld), // 远端更新
      ];
      final remote = [
        makeReview(wordId: '2', clientUpdatedAt: tMid), // 冲突：本地更新
        makeReview(wordId: '3', clientUpdatedAt: tNew), // 冲突：远端更新
        makeReview(wordId: '4', clientUpdatedAt: tNew), // 仅远端
      ];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      expect(result.mergedRecords.length, 4);
      expect(result.recordsToUpload.length, 2); // word 1 (仅本地) + word 2 (本地更新)
      expect(result.recordsToWriteLocal.length, 2); // word 3 (远端更新) + word 4 (仅远端)
      expect(result.localWinCount, 2); // word 1 + word 2
      expect(result.remoteWinCount, 2); // word 3 + word 4
      expect(result.conflictCount, 2); // word 2 + word 3
    });

    test('不同词库的相同 wordId 不冲突（联合 Key 含 wordBookId）', () {
      final local = [
        makeReview(wordId: '1', wordBookId: 'cet6', clientUpdatedAt: DateTime(2026, 8, 21)),
      ];
      final remote = [
        makeReview(wordId: '1', wordBookId: 'cet4', clientUpdatedAt: DateTime(2026, 8, 21)),
      ];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      expect(result.mergedRecords.length, 2);
      expect(result.conflictCount, 0);
      expect(result.recordsToUpload.length, 1);
      expect(result.recordsToWriteLocal.length, 1);
    });

    test('clientUpdatedAt 为 null 视为 epoch（最旧）', () {
      final local = [makeReview(wordId: '1', repetitionCount: 1, clientUpdatedAt: null)];
      final remote = [
        makeReview(wordId: '1', repetitionCount: 5, clientUpdatedAt: DateTime(2026, 8, 1)),
      ];

      final result = ReviewSyncMerger.merge(local: local, remote: remote);

      // 本地 null → epoch，远端 2026-08-01 更新 → 远端胜利
      expect(result.mergedRecords.first.repetitionCount, 5);
      expect(result.remoteWinCount, 1);
    });
  });
}
