import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../sync/state/sync_state.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_user_header.dart';
import '../widgets/sync_card.dart';

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
    // 登出前先重置 SyncState（lastSyncedAt / 统计），防止：
    // - 上一个账号的同步成功信息泄漏到下个账号（显示"5 分钟前同步过"）
    // - user 变更后 syncIfNeeded 被错误 dedupe 跳过
    ref.read(syncControllerProvider.notifier).reset();
    await ref.read(authControllerProvider.notifier).logout();
    // 状态变为 unauthenticated 后路由守卫自动跳转 /login，无需手动导航
    if (mounted) {
      setState(() => _isLoggingOut = false);
    }
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
            ProfileUserHeader(
              username: user?.username,
              email: user?.email,
            ),
            const SizedBox(height: 32),

            // 同步学习进度卡片
            SyncCard(
              isSyncing: syncState.isSyncing,
              onSync: _handleSync,
              syncedTimeText: _formatSyncedTime(syncState.lastSyncedAt),
              errorMessage: syncState.errorMessage,
            ),

            const SizedBox(height: 48),
            LogoutButton(
              isLoading: _isLoggingOut,
              onPressed: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
