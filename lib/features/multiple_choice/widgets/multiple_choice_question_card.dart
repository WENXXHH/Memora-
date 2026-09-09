import 'package:flutter/material.dart';

import '../../../domain/models/word_model.dart';

/// 选择题题面卡片（英文单词 + 音标，不显示释义）。
class MultipleChoiceQuestionCard extends StatelessWidget {
  const MultipleChoiceQuestionCard({super.key, required this.word});

  /// 被考查的单词。
  final Word word;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '选择正确的释义',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              word.word,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              word.phonetic,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
