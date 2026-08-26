import 'package:flutter/material.dart';

/// 学习统计卡片组件
///
/// 展示学习进度统计数据：总单词数、已掌握数、连续打卡天数
/// 通过构造函数接收数据，实现数据驱动的 UI
class StatisticsCard extends StatelessWidget {
  /// 词库总单词数量
  final int totalWords;

  /// 已掌握单词数量
  final int masteredWords;

  /// 连续打卡天数
  final int streakDays;

  const StatisticsCard({
    super.key,
    required this.totalWords,
    required this.masteredWords,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '学习统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem('总单词', '$totalWords', colorScheme.primary),
                _StatItem('已掌握', '$masteredWords', colorScheme.secondary),
                _StatItem('连续打卡', '$streakDays天', colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计项组件
///
/// 展示单个统计数据的数值和标签
/// 采用垂直布局：数值在上（大字号加粗），标签在下（小字号灰色）
class _StatItem extends StatelessWidget {
  /// 统计标签（如"总单词"、"已掌握"）
  final String label;

  /// 统计数值（如"200"、"45"、"7天"）
  final String value;

  /// 数值颜色（用于突出显示）
  final Color color;

  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
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
