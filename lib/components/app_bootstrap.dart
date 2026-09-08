import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/auth/state/auth_state.dart';
import '../features/sync/providers/sync_providers.dart';

/// 应用启动引导组件
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 确保不在 initState 期间改 Provider 状态
    Future.microtask(_installAuthListener);
  }

  /// 安装认证状态监听：认证成功"边沿"时触发一次同步。
  ///
  /// 使用 `ref.listen` 的 prev/next 比较天然提供"边沿检测"：
  /// - prev == unauthenticated/unknown/checking → next = authenticated
  ///   时才触发一次同步
  /// - 已 authenticated 后再次收到 authenticated不会重复触发
  ///   → 保障重复同步幂等
  void _installAuthListener() {
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      final prevStatus = prev?.status;
      final nextStatus = next.status;
      if (nextStatus == AuthStatus.authenticated &&
          prevStatus != AuthStatus.authenticated) {
        // 进入 authenticated → 自动同步一次
        ref.read(syncControllerProvider.notifier).syncIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 仅作为监听器容器，不增加任何 UI 层
    return widget.child;
  }
}
