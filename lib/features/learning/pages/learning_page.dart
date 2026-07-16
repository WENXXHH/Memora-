import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/learning_controller.dart';
import '../state/learning_state.dart';
import '../widgets/word_learning_card.dart';
import '../widgets/feedback_button.dart';
import '../../../components/loading_view.dart';
import '../../../components/error_view.dart';
import '../../home/controller/home_controller.dart';

/// 学习页面组件
/// 
/// 集成控制器和子组件：
/// 1. 创建 LearningController 处理业务逻辑
/// 2. 使用 WordLearningCard 显示单词信息
/// 3. 使用 FeedbackButton 接收用户反馈
/// 4. 构建页面布局结构
/// 
/// 参数：
/// - wordBookId: 词书标识符（默认为 'cet6'）
/// - mode: 学习模式（默认为 newWord）
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

/// LearningPage 的状态类
/// 
/// 通过 Riverpod ref 处理初始化和状态监听
class _LearningPageState extends ConsumerState<LearningPage> {
  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 避免在 build 过程中修改状态
    // 这是 Riverpod 的最佳实践，防止 "State modification during build" 错误
    Future.microtask(() {
      ref.read(learningControllerProvider(widget.wordBookId).notifier).startLearning(
        widget.wordBookId,
        mode: widget.mode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听学习状态，状态变化时自动重建
    final learningState = ref.watch(learningControllerProvider(widget.wordBookId));
    final colorScheme = Theme.of(context).colorScheme;

    // PopScope 拦截系统返回键，返回前触发首页数据刷新
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
              // 返回前刷新首页数据
              ref.read(homeControllerProvider.notifier).loadData();
              Navigator.of(context).pop();
            },
          ),
        ),
        // 根据状态条件渲染不同内容
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

  /// 构建学习完成页面
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
              // 返回前刷新首页数据
              ref.read(homeControllerProvider.notifier).loadData();
              Navigator.of(context).pop();
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  /// 构建学习内容页面
  /// [state]: 当前学习状态
  /// [colorScheme]: 主题颜色方案
  Widget _buildContent(LearningState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgress(state),
          const SizedBox(height: 24),
          WordLearningCard(word: state.currentWord!),
          const SizedBox(height: 24),
          // 根据状态显示反馈按钮或"查看释义"按钮
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

  /// 构建进度指示器
  /// [state]: 当前学习状态
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

  /// 构建反馈按钮行
  /// [state]: 当前学习状态
  /// [colorScheme]: 主题颜色方案
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
