import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 快速入口组件
///
/// 提供三个核心功能入口：学习新词、复习旧词、查看词库
/// 使用等宽按钮布局，支持路由跳转
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的颜色方案
    final colorScheme = Theme.of(context).colorScheme;

    // 垂直布局：标题 → 按钮行
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 标题左对齐
      children: [
        // 标题
        const Text(
          '快速入口',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12), // 间距
        // 按钮行：三个等宽按钮
        Row(
          children: [
            // 学习新词按钮，使用主题色
            _ActionButton(
              icon: Icons.school,
              label: '学习新词',
              color: colorScheme.primary,
              onPressed: () => context.push('/learning'), // 跳转到学习页
            ),
            const SizedBox(width: 12), // 按钮间距
            // 复习旧词按钮，使用红色系
            _ActionButton(
              icon: Icons.refresh,
              label: '复习旧词',
              color: colorScheme.error,
              onPressed: () => context.push('/learning?mode=review'), // 跳转到学习页（复习模式）
            ),
            const SizedBox(width: 12), // 按钮间距
            // 词库按钮，使用次要色
            _ActionButton(
              icon: Icons.library_books,
              label: '词库',
              color: colorScheme.secondary,
              onPressed: () => context.push('/vocabulary'), // 跳转到词库页
            ),
          ],
        ),
      ],
    );
  }
}

/// 快速入口按钮组件
///
/// 展示图标和标签的组合按钮，支持自定义颜色和点击事件
/// 使用 Expanded 实现等宽布局，使用浅色背景突出主题色
class _ActionButton extends StatelessWidget {
  /// 按钮图标
  final IconData icon;

  /// 按钮标签文字
  final String label;

  /// 按钮主题颜色（影响背景色和文字色）
  final Color color;

  /// 点击回调函数
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 Expanded 让按钮在 Row 中均分宽度
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.08), // 浅色背景（8%透明度），更柔和自然
          foregroundColor: color, // 文字和图标使用主题色
          padding: const EdgeInsets.symmetric(vertical: 16), // 垂直内边距
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 圆角
          elevation: 0, // 无阴影，扁平风格
        ),
        child: Column(
          // 垂直排列：图标在上，文字在下
          children: [
            Icon(icon, size: 28), // 图标
            const SizedBox(height: 8), // 间距
            Text(label), // 标签文字
          ],
        ),
      ),
    );
  }
}