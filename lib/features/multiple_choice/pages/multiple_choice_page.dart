import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../providers/multiple_choice_providers.dart';
import '../state/multiple_choice_state.dart';
import '../widgets/multiple_choice_complete_view.dart';
import '../widgets/multiple_choice_empty_view.dart';
import '../widgets/multiple_choice_option_list.dart';
import '../widgets/multiple_choice_progress_header.dart';
import '../widgets/multiple_choice_question_card.dart';
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
            ? MultipleChoiceEmptyView(
                message: state.errorMessage,
                onBack: _onPop,
              )
            : state.isCompleted
            ? MultipleChoiceCompleteView(
                correctCount: state.correctCount,
                wrongCount: state.wrongCount,
                onBack: _onPop,
              )
            : _buildContent(state),
      ),
    );
  }

  Widget _buildContent(MultipleChoiceState state) {
    final question = state.currentQuestion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MultipleChoiceProgressHeader(
            currentIndex: state.currentIndex,
            total: state.questions.length,
            correctCount: state.correctCount,
            wrongCount: state.wrongCount,
          ),
          const SizedBox(height: 24),
          MultipleChoiceQuestionCard(word: question.correctWord),
          const SizedBox(height: 24),
          MultipleChoiceOptionList(
            options: question.options,
            correctIndex: question.correctIndex,
            selectedIndex: state.selectedIndex,
            hasAnswered: state.hasAnswered,
            onSelect: (index) => ref
                .read(
                  multipleChoiceControllerProvider(widget.wordBookId).notifier,
                )
                .selectOption(index),
          ),
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
