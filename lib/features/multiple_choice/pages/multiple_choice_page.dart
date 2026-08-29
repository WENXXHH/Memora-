import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../providers/multiple_choice_providers.dart';
import '../state/multiple_choice_state.dart';
import '../widgets/option_button.dart';
import '../../home/providers/home_providers.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';

/// 选择题复习页。
///
/// 展示英文单词，用户从 4 个中文释义中选择正确答案。
/// 答题后显示颜色反馈（绿=正确，红=用户选错，灰=其他），不自动跳转。
/// 点击"下一题"按钮手动推进（约束 19）。
class MultipleChoicePage extends ConsumerStatefulWidget {
  final String wordBookId;

  const MultipleChoicePage({super.key, this.wordBookId = 'cet6'});

  @override
  ConsumerState<MultipleChoicePage> createState() => _MultipleChoicePageState();
}

class _MultipleChoicePageState extends ConsumerState<MultipleChoicePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(multipleChoiceControllerProvider(widget.wordBookId).notifier)
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

  /// 构建空状态。
  ///
  /// [message] 非空表示词库太小无法生成四选一（doc 52），
  /// 直接给出明确提示，不显示"暂无复习词"误导用户。
  Widget _buildEmpty({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            message == null ? Icons.check_circle_outline : Icons.info_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '暂无需要复习的单词',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (message == null)
            const Text(
              '完成日常学习后再来测试吧',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _onPop, child: const Text('返回首页')),
        ],
      ),
    );
  }

  /// 构建完成视图
  Widget _buildComplete(MultipleChoiceState state) {
    final total = state.correctCount + state.wrongCount;
    final accuracy = total > 0 ? (state.correctCount / total * 100).round() : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '答题完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // 统计
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('正确', state.correctCount, Colors.green),
              const SizedBox(width: 24),
              _buildStat('错误', state.wrongCount, Colors.red),
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
  Widget _buildProgress(MultipleChoiceState state) {
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

  /// 构建题目卡片（英文单词 + 音标，不显示释义）
  Widget _buildQuestionCard(MultipleChoiceState state) {
    final word = state.currentQuestion!.correctWord;
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
              '选择正确的释义',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              word.word,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }

  /// 构建选项列表
  Widget _buildOptions(MultipleChoiceState state) {
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
                  multipleChoiceControllerProvider(widget.wordBookId).notifier,
                )
                .selectOption(index),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      multipleChoiceControllerProvider(widget.wordBookId),
    );

    // 第五天：保存失败反馈 — 通过 SnackBar 通知用户
    ref.listen<MultipleChoiceState>(
      multipleChoiceControllerProvider(widget.wordBookId),
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
          title: const Text('选择题复习'),
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
                      multipleChoiceControllerProvider(
                        widget.wordBookId,
                      ).notifier,
                    )
                    .startQuiz(widget.wordBookId),
              )
            : state.questions.isEmpty
            ? _buildEmpty(message: state.errorMessage)
            : state.isCompleted
            ? _buildComplete(state)
            : _buildContent(state),
      ),
    );
  }

  Widget _buildContent(MultipleChoiceState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgress(state),
          const SizedBox(height: 24),
          _buildQuestionCard(state),
          const SizedBox(height: 24),
          _buildOptions(state),
          const SizedBox(height: 16),
          // "下一题"按钮（约束 19：不自动跳转）
          if (state.hasAnswered)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ref
                    .read(
                      multipleChoiceControllerProvider(
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
