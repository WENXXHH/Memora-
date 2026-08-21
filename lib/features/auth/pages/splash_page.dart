import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

/// 启动闪屏页。
///
/// 路由守卫在 `status == unknown` 时重定向到此页。
/// 此页面触发 [AuthController.restoreSession]，完成后根据状态自动跳转：
/// - authenticated → /home
/// - unauthenticated → /login
/// - error（网络故障）→ 显示重试按钮
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 确保在 build 完成后再触发状态修改
    // 避免在 widget tree 构建期间修改状态（原则：State 修改不能在 build 中发生）
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Logo
            Icon(
              Icons.menu_book,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Memora',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),

            if (authState.status == AuthStatus.checking ||
                authState.status == AuthStatus.unknown)
              const CircularProgressIndicator()
            else if (authState.status == AuthStatus.error) ...[
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                authState.errorMessage ?? '网络连接失败',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(authControllerProvider.notifier)
                      .restoreSession();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
