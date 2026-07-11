import 'package:flutter/material.dart';
import '../../../data/models/word_model.dart';

/// 单词学习卡片组件
/// 
/// 显示单词详细信息，包括：
/// - 单词拼写（大号加粗）
/// - 音标（斜体灰色）
/// - 多词性释义
/// - 例句（斜体灰色）
/// 
/// 纯展示组件（StatelessWidget），不含业务逻辑
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
            // 单词 + 音标
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

            // 释义区域
            const Text(
              '释义',
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

            // 例句区域（如果有）
            if (word.example.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '例句',
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
