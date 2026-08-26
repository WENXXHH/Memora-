import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../../home/providers/home_providers.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../../multiple_choice/widgets/option_button.dart';
import '../providers/listening_quiz_providers.dart';
import '../state/listening_quiz_state.dart';
import '../widgets/listening_prompt.dart';

/// 听音辨词复习页（doc 22 / 27 / 28 / 29 / 30 / 31）。
///
/// 与选择题的差异：
/// - 题目区只显示音频提示（喇叭 + 再听一次 + debug 文本 ♪），
///   不显示英文单词拼写（doc 39 验收清单）
/// - 复用 [OptionButton] 渲染中文释义选项，颜色规则一致
/// - 复用 [ApplyReviewFeedbackUseCase]：听对→fuzzy，听错→unknown
///
/// 页面退出时由 Controller 的 autoDispose 触发 dispose 停止音频
/// （doc 31），[PopScope] 同时刷新首页数据。
class ListeningQuizPage extends ConsumerStatefulWidget {
  final String wordBookId;

  const ListeningQuizPage({super.key, this.wordBookId = 'cet6'});

  @override
  ConsumerState<ListeningQuizPage> createState() => _ListeningQuizPageState();
}

class _ListeningQuizPageState extends ConsumerState<ListeningQuizPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(listeningQuizControllerProvider(widget.wordBookId).notifier)
          .startQuiz(widget.wordBookId);
    });
  }

  void _onPop() {
    ref
        .read(
          homeControllerProvider(ref.read(currentWordBookIdProvider)).notifier,
        )
        .loadData();
    Navigator.of(context).pop();
  }

  /// 构建空状态（无到期复习词或词库太小）
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无需要复习的单词',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成日常学习后再来听音辨词',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _onPop, child: const Text('返回首页')),
        ],
      ),
    );
  }

  /// 构建完成视图
  Widget _buildComplete(ListeningQuizState state) {
    final total = state.correctCount + state.wrongCount;
    final accuracy = total > 0 ? (state.correctCount / total * 100).round() : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '听音辨词完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('听对', state.correctCount, Colors.green),
              const SizedBox(width: 24),
              _buildStat('听错', state.wrongCount, Colors.red),
              const SizedBox(width: 24),
              _buildStat('正确率', accuracy, Colors.blue, suffix: '%'),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _onPop, child: const Text('返回首页')),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color, {String? suffix}) {
    return Column(
      children: [
        Text(
          '$value${suffix ?? ''}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  /// 构建进度条
  Widget _buildProgress(ListeningQuizState state) {
    final total = state.questions.length;
    final current = state.currentIndex + 1;
    final progress = total > 0 ? state.currentIndex / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current / $total',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  '${state.correctCount}',
                  style: TextStyle(color: Colors.green.shade600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.close, size: 16, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Text(
                  '${state.wrongCount}',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
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
              begin: progress,
              end: total > 0 ? current / total : 0,
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

  /// 构建音频提示卡片（不显示英文单词拼写）
  Widget _buildPromptCard(ListeningQuizState state) {
    return ListeningPrompt(
      isPlaying: state.isPlaying,
      hasAudioError: state.hasAudioError,
      audioErrorMessage: state.audioErrorMessage,
      lastPlayedWord: state.lastPlayedWord,
      onReplay: () => ref
          .read(listeningQuizControllerProvider(widget.wordBookId).notifier)
          .replay(),
    );
  }

  /// 构建选项列表
  Widget _buildOptions(ListeningQuizState state) {
    final question = state.currentQuestion!;

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final optionText = entry.value;
        final isCorrect = index == question.correctIndex;
        final isSelected = state.selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OptionButton(
            text: optionText,
            index: index,
            isCorrect: isCorrect,
            isSelected: isSelected,
            hasAnswered: state.hasAnswered,
            onTap: () => ref
                .read(
                  listeningQuizControllerProvider(widget.wordBookId).notifier,
                )
                .selectOption(index),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listeningQuizControllerProvider(widget.wordBookId));

    // 保存失败反馈 — 通过 SnackBar 通知用户（与选择题一致）
    ref.listen<ListeningQuizState>(
      listeningQuizControllerProvider(widget.wordBookId),
      (previous, next) {
        if (next.hasSaveError && !(previous?.hasSaveError ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('复习记录保存失败，进度可能未同步'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref
              .read(
                homeControllerProvider(
                  ref.read(currentWordBookIdProvider),
                ).notifier,
              )
              .loadData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('听音辨词'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onPop,
          ),
        ),
        body: state.isLoading
            ? const LoadingView()
            : state.hasError
            ? ErrorView(
                message: state.errorMessage,
                onRetry: () => ref
                    .read(
                      listeningQuizControllerProvider(
                        widget.wordBookId,
                      ).notifier,
                    )
                    .startQuiz(widget.wordBookId),
              )
            : state.questions.isEmpty
            ? _buildEmpty()
            : state.isCompleted
            ? _buildComplete(state)
            : _buildContent(state),
      ),
    );
  }

  Widget _buildContent(ListeningQuizState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgress(state),
          const SizedBox(height: 24),
          _buildPromptCard(state),
          const SizedBox(height: 24),
          _buildOptions(state),
          const SizedBox(height: 16),
          // "下一题"按钮（约束 19：不自动跳转，需手动点击）
          if (state.hasAnswered)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ref
                    .read(
                      listeningQuizControllerProvider(
                        widget.wordBookId,
                      ).notifier,
                    )
                    .nextQuestion(),
                child: Text(
                  state.currentIndex < state.questions.length - 1
                      ? '下一题'
                      : '查看结果',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
