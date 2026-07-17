import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/learning_controller.dart';
import '../state/learning_state.dart';
import '../widgets/word_learning_card.dart';
import '../widgets/feedback_button.dart';
import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../../home/controller/home_controller.dart';

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
      ref.read(learningControllerProvider(widget.wordBookId).notifier).startLearning(
        widget.wordBookId,
        mode: widget.mode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningControllerProvider(widget.wordBookId));
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
            onPressed: () {
              ref.read(homeControllerProvider.notifier).loadData();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: learningState.isLoading
            ? const LoadingView()
            : learningState.hasError
                ? ErrorView(
                    message: learningState.errorMessage,
                    onRetry: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).startLearning(
                      widget.wordBookId,
                      mode: widget.mode,
                    ),
                  )
                : learningState.currentWord == null
                    ? _buildComplete()
                    : _buildContent(learningState, colorScheme),
      ),
    );
  }

  Widget _buildComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            '学习完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(homeControllerProvider.notifier).loadData();
              Navigator.of(context).pop();
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LearningState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgress(state),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation.drive(
                    Tween<double>(begin: 0.95, end: 1.0).chain(
                      CurveTween(curve: Curves.easeOut),
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: WordLearningCard(
              key: ValueKey(state.currentWord!.id),
              word: state.currentWord!,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state.isShowingAnswer
                ? _buildFeedbackButtons(state, colorScheme)
                : ElevatedButton(
                    key: const ValueKey('showAnswer'),
                    onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).showAnswer(),
                    child: const Text('查看释义'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(LearningState state) {
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

  Widget _buildFeedbackButtons(LearningState state, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FeedbackButton(
          label: '不认识',
          color: colorScheme.error,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            widget.wordBookId,
            FeedbackType.unknown,
          ),
        ),
        const SizedBox(width: 16),
        FeedbackButton(
          label: '模糊',
          color: Colors.amber,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            widget.wordBookId,
            FeedbackType.fuzzy,
          ),
        ),
        const SizedBox(width: 16),
        FeedbackButton(
          label: '认识',
          color: colorScheme.primary,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            widget.wordBookId,
            FeedbackType.known,
          ),
        ),
      ],
    );
  }
}