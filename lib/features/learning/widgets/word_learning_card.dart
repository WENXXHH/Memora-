import 'package:flutter/material.dart';
import '../../../data/models/word_model.dart';

/// Word learning card widget
/// 
/// Displays word details including:
/// - Word spelling (large, bold)
/// - Phonetic (italic, gray)
/// - Multi-part-of-speech definitions
/// - Example sentences (italic, gray)
/// 
/// Pure presentation component (StatelessWidget), no business logic
class WordLearningCard extends StatelessWidget {
  final Word word;

  const WordLearningCard({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word + Phonetic
            Row(
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 20),

            // Definitions section
            const Text(
              'Definition',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...word.meaning.map((meaning) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${meaning.pos} ${meaning.definitions.join('、')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )),

            // Examples section (if available)
            if (word.example.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Examples',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...word.example.map((example) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}