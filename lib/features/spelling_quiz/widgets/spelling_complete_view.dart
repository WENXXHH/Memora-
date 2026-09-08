import 'package:flutter/material.dart';

/// 拼写复习完成统计视图（总题数 / 正确 / 错误 / 正确率）。
class SpellingCompleteView extends StatelessWidget {
  const SpellingCompleteView({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.onBack,
  });

  final int correctCount;
  final int wrongCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final total = correctCount + wrongCount;
    final accuracy = total > 0 ? (correctCount / total * 100).round() : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '拼写复习完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stat('总题数', total, Colors.blueGrey),
              const SizedBox(width: 24),
              _stat('正确', correctCount, Colors.green),
              const SizedBox(width: 24),
              _stat('错误', wrongCount, Colors.red),
              const SizedBox(width: 24),
              _stat('正确率', accuracy, Colors.blue, suffix: '%'),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onBack, child: const Text('返回首页')),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color, {String? suffix}) {
    return Column(
      children: [
        Text(
          '$value${suffix ?? ''}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
