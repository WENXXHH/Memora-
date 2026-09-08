import 'package:flutter/material.dart';

/// 拼写答后反馈卡：正确时显示单词；错误时显示用户答案与正确拼写。
class SpellingFeedbackCard extends StatelessWidget {
  const SpellingFeedbackCard({
    super.key,
    required this.isCorrect,
    required this.correctWord,
    this.submittedAnswer,
  });

  /// 回答是否正确；未提交时为 null（按错误样式兜底）。
  final bool? isCorrect;
  final String correctWord;
  final String? submittedAnswer;

  @override
  Widget build(BuildContext context) {
    final correct = isCorrect ?? false;
    final color = correct ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              correct ? '拼写正确' : '拼写错误',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            if (correct)
              Text(
                correctWord,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            else ...[
              const Text('你的答案：', style: TextStyle(color: Colors.grey)),
              Text(
                submittedAnswer ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              const Text('正确答案：', style: TextStyle(color: Colors.grey)),
              Text(
                correctWord,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
