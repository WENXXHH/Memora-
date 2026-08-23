/// 同步状态机（doc 14）。
///
/// 四态：idle / syncing / success / error
///
/// 防并发（doc 14）：Controller 首行检查 `status == syncing` 时直接返回，
/// 避免用户连续点击触发多个并发 HTTP 请求。
class SyncState {
  const SyncState({
    required this.status,
    this.lastSyncedAt,
    this.errorMessage,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictCount = 0,
  });

  final SyncStatus status;

  /// 上次成功同步时间（仅 success / idle 时有值）。
  final DateTime? lastSyncedAt;

  /// 错误信息（仅 error 态非 null）。
  final String? errorMessage;

  /// 本次同步上传的记录数。
  final int uploadedCount;

  /// 本次同步下载写入的记录数。
  final int downloadedCount;

  /// 本次同步的冲突数（两端都有同一记录）。
  final int conflictCount;

  bool get isSyncing => status == SyncStatus.syncing;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? errorMessage,
    int? uploadedCount,
    int? downloadedCount,
    int? conflictCount,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      conflictCount: conflictCount ?? this.conflictCount,
    );
  }
}

/// 同步状态枚举。
enum SyncStatus {
  /// 空闲，未同步或已完成。
  idle,

  /// 正在同步中。
  syncing,

  /// 同步成功。
  success,

  /// 同步失败。
  error,
}
