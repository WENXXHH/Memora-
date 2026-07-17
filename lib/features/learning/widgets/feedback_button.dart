import 'package:flutter/material.dart';

class FeedbackButton extends StatefulWidget {
  final String label;
  final Color color;
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

  void _handlePressed() {
    if (_isPressed) return;
    setState(() => _isPressed = true);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.color.withValues(alpha: 0.85)
              : widget.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _isPressed ? null : _handlePressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}