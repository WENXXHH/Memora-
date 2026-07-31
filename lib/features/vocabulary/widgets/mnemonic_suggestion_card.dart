import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/enums/ai_enums.dart';
import '../state/ai_suggestion_state.dart';
import '../providers/vocabulary_providers.dart';
import '../../../data/models/ai_suggestion_request.dart';

/// AI 助记建议卡片 — 展示流式生成的助记内容
///
/// 支持五种 UI 状态：
/// - idle：显示"生成 AI 助记"按钮
/// - loading：显示加载动画
/// - streaming：逐字显示文本 + 绿色光标
/// - success：完整文本 + "重新生成"按钮
/// - error：错误信息 + "重试"按钮
class MnemonicSuggestionCard extends ConsumerWidget {
  final AiSuggestionRequest request;

  const MnemonicSuggestionCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiSuggestionControllerProvider);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI 助记',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                _buildActionButton(context, ref, state),
              ],
            ),
            if (state.status != AiSuggestionStatus.idle) ...[
              const SizedBox(height: 12),
              _buildContent(context, state),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据状态决定右上角按钮
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    AiSuggestionState state,
  ) {
    final controller = ref.read(aiSuggestionControllerProvider.notifier);

    switch (state.status) {
      case AiSuggestionStatus.idle:
        return TextButton.icon(
          onPressed: () => controller.generate(request),
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('生成 AI 助记'),
        );

      case AiSuggestionStatus.loading:
      case AiSuggestionStatus.streaming:
        return TextButton(
          onPressed: () => controller.cancel(),
          child: const Text('取消', style: TextStyle(color: Colors.grey)),
        );

      case AiSuggestionStatus.success:
        return TextButton.icon(
          onPressed: () => controller.generate(request),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('重新生成'),
        );

      case AiSuggestionStatus.error:
        return TextButton.icon(
          onPressed: () => controller.generate(request),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('重试'),
        );
    }
  }

  /// 根据状态渲染内容区
  Widget _buildContent(BuildContext context, AiSuggestionState state) {
    switch (state.status) {
      case AiSuggestionStatus.idle:
        return const SizedBox.shrink();

      case AiSuggestionStatus.loading:
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('正在生成...', style: TextStyle(color: Colors.grey)),
          ],
        );

      case AiSuggestionStatus.streaming:
        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: state.text),
              TextSpan(
                text: '▍',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        );

      case AiSuggestionStatus.success:
        return Text(state.text);

      case AiSuggestionStatus.error:
        return Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.errorMessage ?? '生成失败',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
              ),
            ),
          ],
        );
    }
  }
}
