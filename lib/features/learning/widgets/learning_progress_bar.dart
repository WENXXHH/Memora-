import 'package:flutter/material.dart';
import '../state/learning_state.dart';
import '../../../domain/enums/learning_enums.dart';

/// 学习进度条组件
///
/// 显示当前进度（N/M）和带动画的线性进度条
class LearningProgressBar extends StatelessWidget {
  final LearningState state;

  const LearningProgressBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '${state.currentIndex + 1}/${state.totalCount}',
                key: ValueKey(state.currentIndex),
              ),
            ),
            Text(state.mode == LearningMode.newWord ? '新词' : '复习'),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: state.totalCount > 0
                  ? state.currentIndex / state.totalCount
                  : 0,
              end: state.totalCount > 0
                  ? (state.currentIndex + 1) / state.totalCount
                  : 0,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
