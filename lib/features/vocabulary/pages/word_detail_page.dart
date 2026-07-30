import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/word_model.dart';
import '../../../domain/enums/tts_enums.dart';
import '../state/word_detail_state.dart';
import '../providers/vocabulary_providers.dart';

class WordDetailPage extends ConsumerStatefulWidget {
  final Word word;

  const WordDetailPage({super.key, required this.word});

  @override
  ConsumerState<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends ConsumerState<WordDetailPage> {
  @override
  void dispose() {
    ref.read(wordDetailControllerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final ttsState = ref.watch(wordDetailControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词标题行 + 喇叭按钮
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSpeakerButton(ttsState, word.word),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              word.phonetic,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            // 发音错误提示
            if (ttsState.status == TtsStatus.error) ...[
              const SizedBox(height: 8),
              Text(
                ttsState.errorMessage ?? '发音失败',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('释义:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.meaning.map(
              (m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${m.pos} ${m.definitions.join('、')}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('例句:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.example.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(e),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
