import 'package:flutter/material.dart';

/// Feedback button widget for word mastery
/// 
/// Three states supported:
/// - Known (green/primary color)
/// - Fuzzy (yellow)
/// - Unknown (red/error color)
/// 
/// Pure presentation component (StatelessWidget), click event handled by parent
class FeedbackButton extends StatelessWidget {
  /// Button display text
  final String label;

  /// Button background color
  final Color color;

  /// Click callback
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