import 'package:flutter/material.dart';

/// 听音辨词音频提示区。
///
/// 职责：
/// - 显示喇叭图标
/// - 提供"🔊 再听一次"按钮，点击触发 [onReplay]
/// - 作答后显示 `♪ ${lastPlayedWord}` 文本用于确认刚听的单词；
///   **作答前绝不显示**，否则等于直接泄露答案
/// - 播放失败时显示错误提示（与答错完全不同的事件）
class ListeningPrompt extends StatelessWidget {
  const ListeningPrompt({
    super.key,
    required this.isPlaying,
    required this.hasAudioError,
    required this.audioErrorMessage,
    required this.lastPlayedWord,
    required this.hasAnswered,
    required this.onReplay,
  });

  /// 是否正在播放（驱动 loading 指示）。
  final bool isPlaying;

  /// 播放是否失败。
  final bool hasAudioError;

  /// 播放失败提示信息。
  final String? audioErrorMessage;

  /// 最后播放的单词文本（作答后确认用）。
  final String? lastPlayedWord;

  /// 当前题是否已作答：未作答时不显示单词拼写，避免泄露答案。
  final bool hasAnswered;

  /// 点击"再听一次"回调。
  final VoidCallback onReplay;

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
              '听单词，选释义',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // 喇叭图标（播放中转圈，错误时红色）
            isPlaying
                ? const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Icon(
                    hasAudioError ? Icons.volume_off : Icons.volume_up,
                    size: 56,
                    color: hasAudioError
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
            const SizedBox(height: 8),
            // 作答后才显示单词拼写（"作答确认"体验）；
            // 作答前留等高占位，避免显隐时卡片高度跳动。
            if (hasAnswered)
              Text(
                lastPlayedWord != null ? '♪ $lastPlayedWord' : '♪ —',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              const SizedBox(height: 17),
            const SizedBox(height: 16),
            // 播放失败提示
            if (hasAudioError) ...[
              Text(
                audioErrorMessage ?? '播放失败，请重试',
                style: TextStyle(fontSize: 13, color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            // "再听一次"按钮
            OutlinedButton.icon(
              onPressed: isPlaying ? null : onReplay,
              icon: const Icon(Icons.replay),
              label: const Text('再听一次'),
            ),
          ],
        ),
      ),
    );
  }
}
