import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/sync_review_records_use_case.dart';
import '../state/sync_state.dart';

/// 同步控制器。
///
/// 职责：
/// 1. 管理 [SyncState] 四态机（idle / syncing / success / error）
/// 2. 防止并发同步（doc 14：status == syncing 时直接返回）
/// 3. 调用 [SyncReviewRecordsUseCase] 执行完整同步流程
///
/// 原则 13：普通网络错误不退登（401 才走 AuthInterceptor 流程）。
/// Bug 6：同步失败不清空 Hive（UseCase 内部保证）。
class SyncController extends StateNotifier<SyncState> {
  SyncController(this._useCase, {this.wordBookId = 'cet6'})
    : super(const SyncState(status: SyncStatus.idle));

  final SyncReviewRecordsUseCase _useCase;

  /// 当前同步的词库标识。
  /// 第六周只处理内置 CET-6 词库，默认 "cet6"。
  final String wordBookId;

  /// 手动触发同步（ProfilePage "立即同步" 按钮调用）。
  ///
  /// 防并发：正在同步时直接返回。
  Future<void> sync() async {
    if (state.isSyncing) return;

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    final result = await _useCase.execute(wordBookId);

    if (result.success) {
      state = SyncState(
        status: SyncStatus.success,
        lastSyncedAt: DateTime.now().toUtc(),
        uploadedCount: result.uploadedCount,
        downloadedCount: result.downloadedCount,
        conflictCount: result.conflictCount,
      );
    } else {
      state = SyncState(
        status: SyncStatus.error,
        errorMessage: result.errorMessage,
        lastSyncedAt: state.lastSyncedAt,
      );
    }
  }

  /// 条件触发同步（登录恢复后调用，第三天接入）。
  ///
  /// 当前实现与 [sync] 相同，保留方法名以区分语义。
  /// 第三天会在 AppShell 监听 AuthStatus.authenticated 时调用此方法。
  Future<void> syncIfNeeded() async {
    if (state.isSyncing) return;
    if (state.status == SyncStatus.success) return; // 已同步过则跳过
    await sync();
  }

  /// 从 error 态恢复到 idle（用户点击"重试"时调用）。
  void resetToIdle() {
    state = const SyncState(status: SyncStatus.idle);
  }
}
