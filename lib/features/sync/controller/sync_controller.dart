import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/sync_review_records_use_case.dart';
import '../state/sync_state.dart';

/// 同步控制器。
///
/// 职责：
/// 1. 管理 [SyncState] 四态机（idle / syncing / success / error）
/// 2. 防并发同步（doc 14：status == syncing 时直接返回）
/// 3. 防重复自动同步：同一 App 会话内已有成功结果则 syncIfNeeded 跳过
/// 4. 调用 [SyncReviewRecordsUseCase] 执行完整同步流程
///
/// 多设备场景下的鲁棒性（第三天多设备冲突日）：
/// - syncIfNeeded 只在 idle+无成功记录时触发，保证"登录后自动一次、
///   Profile 手动同步不限次数"的幂等策略（doc 18 第 8 条"第二次同步
///   结果稳定"）。
/// - 网络失败不清空 Hive、不退登（UseCase 保证，原则 13 / doc 16）。
/// - 每次同步完成写入 lastSyncedAt，供 App 恢复后判断是否需要同步。
class SyncController extends StateNotifier<SyncState> {
  SyncController(this._useCase, {this.wordBookId = 'cet6'})
    : super(const SyncState(status: SyncStatus.idle));

  final SyncReviewRecordsUseCase _useCase;

  /// 当前同步的词库标识。
  /// 第六周只处理内置 CET-6 词库，默认 "cet6"。
  final String wordBookId;

  /// 距离上次成功同步过短就触发 syncIfNeeded 认为可跳过的阈值。
  ///
  /// 仅用于 syncIfNeeded 的自动触发去重。Profile 页用户点"立即同步"
  /// （调用 [sync]）时不受此阈值限制，确保调试、冲突验证时的可控性。
  static const Duration autoSyncDedupeWindow = Duration(minutes: 5);

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
        // 保留上一次成功同步时间，下次 auto sync 不会被误判为"还未同步过"
        lastSyncedAt: state.lastSyncedAt,
      );
    }
  }

  /// 条件同步：登录恢复或 App 启动后自动调用。
  ///
  /// 跳过条件（保证自动同步的幂等与稳定，防止反复请求）：
  /// 1. syncing 中：并发防御
  /// 2. 已经同步成功过，且仍处于 [autoSyncDedupeWindow] 窗口内
  ///    → 视为无需重复同步（doc 18 第 8 条：相同输入再次同步结果稳定）
  /// 3. unauthenticated 后重新 login（lastSyncedAt 会保留，这是有意行为；
  ///    同一账号短时间内重复 login 不重复同步，登出后不变更 lastSyncedAt，
  ///    但 Profile 手动 sync 不受限制）
  ///
  /// 如果需要强制同步，调用 [sync]（例如手动"立即同步"按钮）。
  Future<void> syncIfNeeded() async {
    if (state.isSyncing) return;

    final now = DateTime.now().toUtc();
    if (state.status == SyncStatus.success && state.lastSyncedAt != null) {
      final elapsed = now.difference(state.lastSyncedAt!);
      if (elapsed <= autoSyncDedupeWindow) {
        // 窗口期内自动同步跳过，保持现有成功状态
        return;
      }
    }

    // error 或 idle 或已过期的 success → 执行同步
    await sync();
  }

  /// 登出时重置同步状态。
  ///
  /// 不是必须调用（不同步不崩溃），但在 A/B 两账号切换登录、或登出后
  /// 重新登录不同账号时，应重置 lastSyncedAt 与统计字段，防止：
  /// - 上一个账号的同步成功信息泄漏到下个账号（显示"5 分钟前同步过"）
  /// - user 变更后 syncIfNeeded 被错误地 dedupe 跳过
  void reset() {
    state = const SyncState(status: SyncStatus.idle);
  }

  /// 从 error 态恢复到 idle（用户点击"重试"时调用）。
  void resetToIdle() {
    state = SyncState(
      status: SyncStatus.idle,
      lastSyncedAt: state.lastSyncedAt,
    );
  }
}
