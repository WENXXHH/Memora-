import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/auth/state/auth_state.dart';
import '../features/sync/providers/sync_providers.dart';

/// 应用启动引导组件（doc 15 入口 1：登录恢复后自动同步）。
///
/// 作用：在不依赖另一个 Controller 的前提下（原则 15：Controller 不依赖
/// Controller），桥接认证状态与同步流程。检测到首次进入
/// [AuthStatus.authenticated] 时调用 [SyncController.syncIfNeeded]。
///
/// 设计要点：
/// - 不直接在 AuthController 中引用 SyncController（避免形成反向耦合）
/// - 使用 `ref.listen`：在 authentication 第一次变为 true 时触发同步
/// - 同步失败不影响首页渲染（原则 13 / doc 16：网络错误不退登、不阻塞）
///
/// 第三天自动同步场景覆盖：
/// 1. App 启动 splash → restoreSession → authenticated → syncIfNeeded
/// 2. 手动登录 → authenticated → syncIfNeeded
/// 3. 杀进程恢复 → restoreSession 成功 → syncIfNeeded
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
  /// - 已 authenticated 后再次收到 authenticated（token 刷新、
  ///   路由 guard 重渲染）不会重复触发
  ///   → 保障重复同步幂等（doc 18 第 8 条）
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
