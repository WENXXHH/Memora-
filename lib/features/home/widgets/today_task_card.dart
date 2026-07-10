import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 今日任务卡片组件
///
/// 展示今日待复习和已学习的单词数量，提供开始学习按钮
/// 通过构造函数接收数据，实现数据驱动的 UI
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
    // 获取当前主题的颜色方案，用于动态配色
    final colorScheme = Theme.of(context).colorScheme;

    // 使用 Card 组件实现卡片效果，包含阴影和圆角
    return Card(
      elevation: 4, // 阴影深度，值越大阴影越明显
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 圆角半径
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // 内边距
        child: Column(
          // 垂直布局：标题 → 任务项 → 按钮
          children: [
            // 卡片标题
            const Text(
              '今日学习任务',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20), // 间距
            // 任务项横向排列，使用 spaceEvenly 均匀分布
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 待复习任务项，使用红色系
                _TaskItem(
                  icon: Icons.refresh,
                  label: '待复习',
                  count: reviewCount,
                  color: colorScheme.error,
                ),
                // 已学习任务项，使用主题色系
                _TaskItem(
                  icon: Icons.menu_book,
                  label: '已学习',
                  count: learnedCount,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20), // 间距
            // 开始学习按钮，宽度占满卡片
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/learning'), // 跳转到学习页
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), // 垂直内边距
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 圆角
                  ),
                ),
                child: const Text('开始学习', style: TextStyle(fontSize: 16)),
              ),
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
      // 垂直排列：图标 → 标签 → 数量
      children: [
        // 图标，使用指定颜色
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8), // 间距
        // 标签文字，使用默认颜色
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4), // 间距
        // 数量文字，加粗并使用主题颜色突出显示
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