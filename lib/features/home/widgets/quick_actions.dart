import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 快速入口组件
///
/// 提供七个核心功能入口：学习新词、复习旧词、选择题复习、听音辨词、
/// 拼写复习、词库浏览、词库切换。
/// 使用 2×2 网格布局（4 行），最后一行"词库切换"为全宽按钮。
/// 支持路由跳转。
///
/// 学习类入口统一携带 [wordBookId]（由页面从 currentWordBookIdProvider
/// 读取后传入），保证所有模式读取同一个当前词库。
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.wordBookId});

  /// 当前词库 Domain ID，所有学习类入口共享同一来源。
  final String wordBookId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速入口',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.school,
              label: '学习新词',
              color: colorScheme.primary,
              onPressed: () => context.push('/learning?wordBookId=$wordBookId'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.refresh,
              label: '复习旧词',
              color: colorScheme.error,
              onPressed: () =>
                  context.push('/learning?mode=review&wordBookId=$wordBookId'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.quiz,
              label: '选择题复习',
              color: colorScheme.tertiary,
              onPressed: () => context.push('/choice?wordBookId=$wordBookId'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.headphones,
              label: '听音辨词',
              color: colorScheme.tertiary,
              onPressed: () =>
                  context.push('/listening-quiz?wordBookId=$wordBookId'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.spellcheck,
              label: '拼写复习',
              color: colorScheme.primary,
              onPressed: () =>
                  context.push('/spelling-quiz?wordBookId=$wordBookId'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.menu_book,
              label: '词库浏览',
              color: colorScheme.secondary,
              onPressed: () => context.push(
                '/vocabulary?wordBookId=$wordBookId&title=词库',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // _ActionButton 内部是 Expanded，必须放在 Row 中
        // （直接放进 Column 会因无界高度约束抛布局异常，导致首页空白）
        Row(
          children: [
            _ActionButton(
              icon: Icons.swap_horiz,
              label: '词库切换',
              color: colorScheme.secondary,
              onPressed: () => context.push('/word-books'),
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
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.08),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
