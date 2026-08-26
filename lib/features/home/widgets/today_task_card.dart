import 'package:flutter/material.dart';

/// 今日任务卡片组件
///
/// 纯信息展示组件：展示今日待复习和已学习的单词数量
/// 学习/复习入口由 QuickActions 统一提供
class TodayTaskCard extends StatelessWidget {
  /// 待复习单词数量
  final int reviewCount;

  /// 今日已学习单词数量
  final int learnedCount;

  const TodayTaskCard({
    super.key,
    required this.reviewCount,
    required this.learnedCount,
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
              '今日学习任务',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TaskItem(
                  icon: Icons.refresh,
                  label: '待复习',
                  count: reviewCount,
                  color: colorScheme.error,
                ),
                _TaskItem(
                  icon: Icons.menu_book,
                  label: '已学习',
                  count: learnedCount,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 任务项组件
///
/// 展示单个任务的图标、标签和数量
/// 采用垂直布局：图标在上，标签在中，数量在下
class _TaskItem extends StatelessWidget {
  /// 任务图标
  final IconData icon;

  /// 任务标签（如"待复习"、"已学习"）
  final String label;

  /// 任务数量
  final int count;

  /// 主题颜色（用于图标和数量的颜色）
  final Color color;

  const _TaskItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
