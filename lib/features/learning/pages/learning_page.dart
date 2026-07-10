import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/learning_controller.dart';
import '../state/learning_state.dart';
import '../widgets/word_learning_card.dart';
import '../widgets/feedback_button.dart';
import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';

/// Learning page widget
/// 
/// Integrates controller and widgets:
/// 1. Creates LearningController for business logic
/// 2. Uses WordLearningCard to display word info
/// 3. Uses FeedbackButton for user feedback
/// 4. Builds page layout structure
/// 
/// Parameters:
/// - wordBookId: word book identifier (default: 'cet6')
/// - mode: learning mode (default: newWord)
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

/// State class for LearningPage
/// 
/// Handles initialization and state listening via Riverpod ref
class _LearningPageState extends ConsumerState<LearningPage> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid state modification during build
    // This is Riverpod best practice to prevent "State modification during build" error
    Future.microtask(() {
      ref.read(learningControllerProvider(widget.wordBookId).notifier).startLearning(
        widget.wordBookId,
        mode: widget.mode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch learning state, rebuild when state changes
    final learningState = ref.watch(learningControllerProvider(widget.wordBookId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == LearningMode.newWord ? '新词学习' : '单词复习'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Conditional rendering based on state
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
    );
  }

  /// Build complete screen
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  /// Build learning content screen
  /// [state]: current learning state
  /// [colorScheme]: theme color scheme
  Widget _buildContent(LearningState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgress(state),
          const SizedBox(height: 24),
          WordLearningCard(word: state.currentWord!),
          const SizedBox(height: 24),
          // Show feedback buttons or "Show Definition" button
          if (state.isShowingAnswer) ...[
            _buildFeedbackButtons(state, colorScheme),
          ] else ...[
            ElevatedButton(
              onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).showAnswer(),
              child: const Text('查看释义'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build progress indicator
  /// [state]: current learning state
  Widget _buildProgress(LearningState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${state.currentIndex + 1}/${state.totalCount}'),
            Text(state.mode == LearningMode.newWord ? '新词' : '复习'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: state.totalCount > 0 ? (state.currentIndex + 1) / state.totalCount : 0,
        ),
      ],
    );
  }

  /// Build feedback buttons row
  /// [state]: current learning state
  /// [colorScheme]: theme color scheme
  Widget _buildFeedbackButtons(LearningState state, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FeedbackButton(
          label: '不认识',
          color: colorScheme.error,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            FeedbackType.unknown,
          ),
        ),
        const SizedBox(width: 16),
        FeedbackButton(
          label: '模糊',
          color: Colors.amber,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            FeedbackType.fuzzy,
          ),
        ),
        const SizedBox(width: 16),
        FeedbackButton(
          label: '认识',
          color: colorScheme.primary,
          onPressed: () => ref.read(learningControllerProvider(widget.wordBookId).notifier).handleFeedback(
            FeedbackType.known,
          ),
        ),
      ],
    );
  }
}