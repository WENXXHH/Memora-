import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learning_providers.dart';
import '../../../domain/enums/learning_enums.dart';
import 'feedback_button.dart';

/// 反馈按钮行组件
///
/// 展示三个反馈按钮（不认识/模糊/认识）
/// 通过回调解耦，不直接引用 homeControllerProvider
class FeedbackButtonRow extends ConsumerWidget {
  final String wordBookId;
  final ColorScheme colorScheme;
  final VoidCallback onCompleted;

  const FeedbackButtonRow({
    super.key,
    required this.wordBookId,
    required this.colorScheme,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: FeedbackButton(
            label: '不认识',
            color: colorScheme.error,
            onPressed: () => ref
                .read(learningControllerProvider(wordBookId).notifier)
                .handleFeedback(
                  wordBookId,
                  FeedbackType.unknown,
                  onCompleted: onCompleted,
                ),
          ),
        ),
        Flexible(
          child: FeedbackButton(
            label: '模糊',
            color: Colors.amber,
            onPressed: () => ref
                .read(learningControllerProvider(wordBookId).notifier)
                .handleFeedback(
                  wordBookId,
                  FeedbackType.fuzzy,
                  onCompleted: onCompleted,
                ),
          ),
        ),
        Flexible(
          child: FeedbackButton(
            label: '认识',
            color: colorScheme.primary,
            onPressed: () => ref
                .read(learningControllerProvider(wordBookId).notifier)
                .handleFeedback(
                  wordBookId,
                  FeedbackType.known,
                  onCompleted: onCompleted,
                ),
          ),
        ),
      ],
    );
  }
}
