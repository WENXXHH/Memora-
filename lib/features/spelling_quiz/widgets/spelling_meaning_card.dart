import 'package:flutter/material.dart';

import '../../../domain/models/word_model.dart';

/// 拼写题面：中文释义卡（每词性一行，与学习页 word_learning_card 一致）。
class SpellingMeaningCard extends StatelessWidget {
  const SpellingMeaningCard({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '中文释义',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...word.meaning.map(
              (meaning) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${meaning.pos} ${meaning.definitions.join('、')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
