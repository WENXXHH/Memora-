import 'package:flutter/material.dart';

/// 选择题完成统计视图（正确 / 错误 / 正确率）。
class MultipleChoiceCompleteView extends StatelessWidget {
  const MultipleChoiceCompleteView({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.onBack,
  });

  /// 累计答对题数。
  final int correctCount;

  /// 累计答错题数。
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
            '答题完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // 统计
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('正确', correctCount, Colors.green),
              const SizedBox(width: 24),
              _buildStat('错误', wrongCount, Colors.red),
              const SizedBox(width: 24),
              _buildStat('正确率', accuracy, Colors.blue, suffix: '%'),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onBack, child: const Text('返回首页')),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color, {String? suffix}) {
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
