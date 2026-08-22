import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../sync/state/sync_state.dart';

/// 个人中心页。
///
/// 展示当前登录用户信息，提供学习记录同步和登出入口。
/// 登出后 AuthController 状态变为 unauthenticated，
/// 路由守卫自动重定向到 /login。
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await ref.read(authControllerProvider.notifier).logout();
    // 状态变为 unauthenticated 后路由守卫自动跳转 /login，无需手动导航
  }

  Future<void> _handleSync() async {
    await ref.read(syncControllerProvider.notifier).sync();
    if (!mounted) return;

    final syncState = ref.read(syncControllerProvider);
    if (!mounted) return;

    final message = switch (syncState.status) {
      SyncStatus.success =>
        '同步完成\n上传 ${syncState.uploadedCount} 条 · 下载 ${syncState.downloadedCount} 条',
      SyncStatus.error => '同步失败：${syncState.errorMessage}',
      _ => null,
    };

    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  String _formatSyncedTime(DateTime? time) {
    if (time == null) return '从未同步';
    final local = time.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;
    final syncState = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的'), centerTitle: true, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(
                Icons.person,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.username ?? '未知用户',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // 同步学习进度卡片
            _SyncCard(
              syncState: syncState,
              onSync: _handleSync,
              syncedTimeText: _formatSyncedTime(syncState.lastSyncedAt),
            ),

            const SizedBox(height: 48),
            FilledButton.tonalIcon(
              onPressed: _isLoggingOut ? null : _handleLogout,
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('登出'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 同步状态卡片（doc 15 入口 2：ProfilePage "立即同步"）。
class _SyncCard extends StatelessWidget {
  const _SyncCard({
    required this.syncState,
    required this.onSync,
    required this.syncedTimeText,
  });

  final SyncState syncState;
  final VoidCallback onSync;
  final String syncedTimeText;

  @override
  Widget build(BuildContext context) {
    final isSyncing = syncState.isSyncing;
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
            if (syncState.status == SyncStatus.error &&
                syncState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                syncState.errorMessage!,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
