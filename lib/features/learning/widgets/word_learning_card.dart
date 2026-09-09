import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/word_model.dart';
import '../../../domain/entities/ai_suggestion_request.dart';
import '../../../domain/enums/tts_enums.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../vocabulary/providers/vocabulary_providers.dart';
import '../../vocabulary/state/word_detail_state.dart';
import '../../vocabulary/widgets/mnemonic_suggestion_card.dart';

/// 单词学习卡片组件
///
/// 显示单词详细信息：
/// - 单词拼写（大号加粗）+ 音标（始终可见）+ 喇叭按钮
/// - 多词性释义（由 showMeaning 控制显隐）
/// - 例句（由 showMeaning 控制显隐）
/// - AI 助记卡片（由 showMeaning 控制显隐）
///
/// TTS 与 AI 助记均复用 vocabulary 模块的 autoDispose Provider。
/// 卡片切换单词时（AnimatedSwitcher key 变化 → 新 State 实例），
/// initState 重置 AI 助记状态，dispose 停止 TTS 播放。
class WordLearningCard extends ConsumerStatefulWidget {
  final Word word;
  final bool showMeaning;

  const WordLearningCard({
    super.key,
    required this.word,
    this.showMeaning = false,
  });

  @override
  ConsumerState<WordLearningCard> createState() => _WordLearningCardState();
}

class _WordLearningCardState extends ConsumerState<WordLearningCard> {
  @override
  void initState() {
    super.initState();
    // 新单词卡片创建时重置 AI 助记状态，防止上一题的助记内容残留
    Future.microtask(() {
      ref.read(aiSuggestionControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    // 卡片销毁时停止 TTS（autoDispose Provider 在无监听者时自动 dispose）
    ref.read(wordDetailControllerProvider.notifier).stop();
    super.dispose();
  }

  /// 根据 Word 构建 AI 助记请求（取首个释义和首条例句）
  AiSuggestionRequest _buildRequest() {
    final word = widget.word;
    final firstMeaning =
        word.meaning.isNotEmpty ? word.meaning.first.definitions.join('、') : '';
    final firstExample = word.example.isNotEmpty ? word.example.first : '';

    return AiSuggestionRequest(
      word: word.word,
      meaning: firstMeaning,
      example: firstExample,
      feedbackType: FeedbackType.unknown,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ttsState = ref.watch(wordDetailControllerProvider);
    final word = widget.word;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词独占一行：给足整行宽度完整展示，
            // 避免与音标、喇叭按钮挤在同一行时被压缩成 "acc"
            Text(
              word.word,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // 音标 + 喇叭按钮紧随下一行
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.phonetic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _buildSpeakerButton(ttsState, word.word),
              ],
            ),
            // 发音错误提示
            if (ttsState.status == TtsStatus.error) ...[
              const SizedBox(height: 8),
              Text(
                ttsState.errorMessage ?? '发音失败',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 释义区域（仅在 showMeaning 为 true 时显示）
            if (widget.showMeaning) ...[
              const Text('释义', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...word.meaning.map(
                (meaning) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${meaning.pos} ${meaning.definitions.join('、')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // 例句区域（如果有）
              if (word.example.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('例句', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...word.example.map(
                  (example) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              // AI 助记卡片
              MnemonicSuggestionCard(request: _buildRequest()),
            ],
          ],
        ),
      ),
    );
  }

  /// 喇叭按钮：点击朗读单词，朗读中高亮，失败显红。
  Widget _buildSpeakerButton(TtsState ttsState, String wordText) {
    final isSpeaking = ttsState.status == TtsStatus.speaking;
    final hasError = ttsState.status == TtsStatus.error;

    return IconButton(
      icon: Icon(
        isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
        color: hasError
            ? Theme.of(context).colorScheme.error
            : isSpeaking
                ? Theme.of(context).colorScheme.primary
                : null,
      ),
      tooltip: isSpeaking ? '正在朗读...' : '点击发音',
      onPressed: () {
        ref.read(wordDetailControllerProvider.notifier).speak(wordText);
      },
    );
  }
}
