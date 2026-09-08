import 'package:flutter/material.dart';

/// 无到期拼写复习词时的空状态视图。
class SpellingEmptyView extends StatelessWidget {
  const SpellingEmptyView({super.key, required this.onBack});

  /// 返回首页回调。
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无需要拼写复习的单词',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成日常学习后再来拼写复习',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onBack, child: const Text('返回首页')),
        ],
      ),
    );
  }
}
