import 'package:flutter/material.dart';

/// 单词掌握程度反馈按钮组件
///
/// 支持三种状态：
/// - 认识（绿色/主题色）
/// - 模糊（黄色）
/// - 不认识（红色/错误色）
///
/// 组件为 StatefulWidget，支持选中态视觉反馈：
/// - 点击后按钮缩小并禁用，防止快速连续点击
/// - 按钮不需要手动恢复：handleFeedback 完成后 LearningPage 会重建，
///   按钮被自然移除（下一词）或替换为完成页面（最后词）
class FeedbackButton extends StatefulWidget {
  /// 按钮显示文本
  final String label;

  /// 按钮背景颜色
  final Color color;

  /// 点击回调函数（同步，内部启动异步 handleFeedback）
  final VoidCallback onPressed;

  const FeedbackButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton> {
  bool _isPressed = false;

  /// 同步处理点击：立即禁用按钮，触发异步 handleFeedback
  /// handleFeedback 完成后 LearningPage 自动重建，按钮自然移除。
  void _handlePressed() {
    if (_isPressed) return;
    setState(() => _isPressed = true);
    widget.onPressed(); // 触发 handleFeedback（异步，但不需要 await）
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isPressed ? null : _handlePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: _isPressed ? 0 : 2,
        minimumSize: _isPressed
            ? const Size(0, 36)
            : const Size(0, 48),
      ),
      child: Transform.scale(
        scale: _isPressed ? 0.95 : 1.0,
        child: Text(widget.label),
      ),
    );
  }
}
