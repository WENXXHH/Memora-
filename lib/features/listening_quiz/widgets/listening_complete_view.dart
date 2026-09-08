import 'package:flutter/material.dart';

/// 听音辨词完成统计视图（听对 / 听错 / 正确率）。
class ListeningCompleteView extends StatelessWidget {
  const ListeningCompleteView({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.onBack,
  });

  /// 听对题数。
  final int correctCount;

  /// 听错题数。
  final int wrongCount;

  /// 返回首页回调。
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
            '听音辨词完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stat('听对', correctCount, Colors.green),
              const SizedBox(width: 24),
              _stat('听错', wrongCount, Colors.red),
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
