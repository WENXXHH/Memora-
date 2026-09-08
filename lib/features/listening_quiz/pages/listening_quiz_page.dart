import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../../home/providers/home_providers.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/listening_quiz_providers.dart';
import '../state/listening_quiz_state.dart';
import '../widgets/listening_complete_view.dart';
import '../widgets/listening_empty_view.dart';
import '../widgets/listening_options.dart';
import '../widgets/listening_progress_header.dart';
import '../widgets/listening_prompt.dart';

/// 听音辨词复习页。
///
/// 与选择题的差异：
/// - 题目区只显示音频提示（喇叭 + 再听一次 + debug 文本 ♪），
///   不显示英文单词拼写
/// - 复用 [OptionButton] 渲染中文释义选项，颜色规则一致
/// - 复用 [ApplyReviewFeedbackUseCase]：听对→fuzzy，听错→unknown
///
/// 页面退出时由 Controller 的 autoDispose 触发 dispose 停止音频
/// ，[PopScope] 同时刷新首页数据。
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
            ? ListeningEmptyView(message: state.errorMessage, onBack: _onPop)
            : state.isCompleted
            ? ListeningCompleteView(
                correctCount: state.correctCount,
                wrongCount: state.wrongCount,
                onBack: _onPop,
              )
            : _buildContent(state),
      ),
    );
  }

  Widget _buildContent(ListeningQuizState state) {
    final question = state.currentQuestion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListeningProgressHeader(
            currentIndex: state.currentIndex,
            total: state.questions.length,
            correctCount: state.correctCount,
            wrongCount: state.wrongCount,
          ),
          const SizedBox(height: 24),
          _buildPromptCard(state),
          const SizedBox(height: 24),
          ListeningOptions(
            options: question.options,
            correctIndex: question.correctIndex,
            selectedIndex: state.selectedIndex,
            hasAnswered: state.hasAnswered,
            onSelect: (index) => ref
                .read(
                  listeningQuizControllerProvider(widget.wordBookId).notifier,
                )
                .selectOption(index),
          ),
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
