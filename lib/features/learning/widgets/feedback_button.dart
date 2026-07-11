import 'package:flutter/material.dart';

/// 单词掌握程度反馈按钮组件
/// 
/// 支持三种状态：
/// - 认识（绿色/主题色）
/// - 模糊（黄色）
/// - 不认识（红色/错误色）
/// 
/// 纯展示组件（StatelessWidget），点击事件由父组件处理
class FeedbackButton extends StatelessWidget {
  /// 按钮显示文本
  final String label;

  /// 按钮背景颜色
  final Color color;

  /// 点击回调函数
  final VoidCallback onPressed;

  const FeedbackButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(label),
    );
  }
}
