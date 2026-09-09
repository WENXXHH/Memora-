import 'package:flutter/material.dart';

/// 登出按钮：登出中禁用并显示小号转圈进度，否则显示"登出"。
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  /// 是否正在登出（禁用按钮并显示转圈进度）。
  final bool isLoading;

  /// 点击登出的回调。
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
      label: const Text('登出'),
    );
  }
}
