import 'package:flutter/material.dart';

/// 拼写复习进度头：题号（current / total）+ 对错计数 + 动画进度条。
///
/// [currentIndex] 为当前题目下标（0 起），[total] 为总题数。
class SpellingProgressHeader extends StatelessWidget {
  const SpellingProgressHeader({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.correctCount,
    required this.wrongCount,
  });

  final int currentIndex;
  final int total;
  final int correctCount;
  final int wrongCount;

  @override
  Widget build(BuildContext context) {
    final current = currentIndex + 1;
    final progress = total > 0 ? currentIndex / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current / $total',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  '$correctCount',
                  style: TextStyle(color: Colors.green.shade600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.close, size: 16, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Text(
                  '$wrongCount',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: progress,
              end: total > 0 ? current / total : 0,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
