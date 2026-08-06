import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learning_providers.dart';
import '../state/learning_state.dart';
import '../widgets/word_learning_card.dart';
import '../widgets/feedback_button_row.dart';
import '../widgets/learning_progress_bar.dart';
import '../widgets/learning_complete_view.dart';
import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../home/providers/home_providers.dart';

/// 学习页组件
///
/// 支持新词学习和单词复习模式。页面加载时自动启动学习会话，
/// 返回首页时刷新首页数据。
class LearningPage extends ConsumerStatefulWidget {
  final String wordBookId;
  final LearningMode mode;

  const LearningPage({
    super.key,
    this.wordBookId = 'cet6',
    this.mode = LearningMode.newWord,
  });

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(learningControllerProvider(widget.wordBookId).notifier)
          .startLearning(widget.wordBookId, mode: widget.mode);
    });
  }

  void _onPop() {
    ref.read(homeControllerProvider.notifier).loadData();
    Navigator.of(context).pop();
  }

  Widget _buildEmpty() {
    final isReview = widget.mode == LearningMode.review;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isReview ? Icons.check_circle_outline : Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isReview ? '暂无单词需要复习' : '暂无新词需要学习',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            isReview ? '所有单词都在记忆周期中，稍后再来看看' : '所有单词都已学过，请等待复习周期',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _onPop, child: const Text('返回首页')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(
      learningControllerProvider(widget.wordBookId),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(homeControllerProvider.notifier).loadData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mode == LearningMode.newWord ? '新词学习' : '单词复习'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onPop,
          ),
        ),
        body: learningState.isLoading
            ? const LoadingView()
            : learningState.hasError
            ? ErrorView(
                message: learningState.errorMessage,
                onRetry: () => ref
                    .read(
                      learningControllerProvider(widget.wordBookId).notifier,
                    )
                    .startLearning(widget.wordBookId, mode: widget.mode),
              )
            : learningState.totalCount == 0
            ? _buildEmpty()
            : learningState.currentWord == null
            ? LearningCompleteView(onBackToHome: _onPop)
            : _buildContent(learningState, colorScheme),
      ),
    );
  }

  Widget _buildContent(LearningState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LearningProgressBar(state: state),
          const SizedBox(height: 24),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(
                        begin: 0.95,
                        end: 1.0,
                      ).chain(CurveTween(curve: Curves.easeOut)),
                    ),
                    child: child,
                  ),
                );
              },
              child: WordLearningCard(
                key: ValueKey(state.currentWord!.id),
                word: state.currentWord!,
                showMeaning: state.isShowingAnswer,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state.isShowingAnswer
                ? FeedbackButtonRow(
                    key: const ValueKey('feedbackRow'),
                    wordBookId: widget.wordBookId,
                    colorScheme: colorScheme,
                    onCompleted: _onPop,
                  )
                : ElevatedButton(
                    key: const ValueKey('showAnswer'),
                    onPressed: () => ref
                        .read(
                          learningControllerProvider(
                            widget.wordBookId,
                          ).notifier,
                        )
                        .showAnswer(),
                    child: const Text('查看释义'),
                  ),
          ),
        ],
      ),
    );
  }
}
