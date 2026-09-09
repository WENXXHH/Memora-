import 'package:flutter/material.dart';

/// 同步状态卡片（ProfilePage "立即同步"）。
///
/// 纯展示组件：仅接收展示数据与同步回调，不感知 sync 业务状态对象。
class SyncCard extends StatelessWidget {
  const SyncCard({
    super.key,
    required this.isSyncing,
    required this.onSync,
    required this.syncedTimeText,
    this.errorMessage,
  });

  /// 是否正在同步（控制按钮禁用/转圈与文案）。
  final bool isSyncing;

  /// 点击"立即同步"按钮的回调。
  final VoidCallback onSync;

  /// "上次同步：xx:xx" 中的时间文本（由页面格式化后传入）。
  final String syncedTimeText;

  /// 错误信息（仅同步失败时非空，用于展示错误行）。
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '同步学习进度',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '上次同步：$syncedTimeText',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: isSyncing ? null : onSync,
                  icon: isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(isSyncing ? '同步中' : '立即同步'),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
