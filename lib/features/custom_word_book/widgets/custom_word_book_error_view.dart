import 'package:flutter/material.dart';

/// 词库详情加载失败的错误态视图：错误提示 + 重试按钮。
class CustomWordBookErrorView extends StatelessWidget {
  const CustomWordBookErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  /// 错误提示文案。
  final String errorMessage;

  /// 重试回调。
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
