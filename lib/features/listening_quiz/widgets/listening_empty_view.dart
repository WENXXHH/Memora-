import 'package:flutter/material.dart';

/// 听音辨词空状态视图。
///
/// [message] 非空表示词库太小无法生成四选一，
/// 直接给出明确提示，不显示"暂无复习词"误导用户。
class ListeningEmptyView extends StatelessWidget {
  const ListeningEmptyView({super.key, this.message, required this.onBack});

  /// 词库太小时给出的具体提示，为空则显示默认空状态文案。
  final String? message;

  /// 返回首页回调。
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message == null ? Icons.check_circle_outline : Icons.info_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '暂无需要复习的单词',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (message == null)
            const Text(
              '完成日常学习后再来听音辨词',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onBack, child: const Text('返回首页')),
        ],
      ),
    );
  }
}
