import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/error_view.dart';
import '../../../components/loading_view.dart';
import '../../home/providers/home_providers.dart';
import '../../word_book_selection/providers/current_word_book_providers.dart';
import '../providers/spelling_quiz_providers.dart';
import '../state/spelling_quiz_state.dart';
import '../widgets/spelling_complete_view.dart';
import '../widgets/spelling_empty_view.dart';
import '../widgets/spelling_feedback_card.dart';
import '../widgets/spelling_meaning_card.dart';
import '../widgets/spelling_progress_header.dart';

/// 拼写复习页。
///
/// 与选择题 / 听音辨词的差异：
/// - 题目区只显示中文释义（每词性一行，与学习页一致），不显示英文拼写
/// - 用户输入英文单词并提交，由 [SpellingAnswerMatcher] 判定对错
/// - 空输入通过 inputError 提示，输入无效 ≠ 回答错误
/// - SM-2 映射：拼写正确 → known，错误 → unknown
/// - 答后输入框锁定，键盘"完成"与按钮走同一入口
/// - 下一题时清空输入框并重新聚焦
///
/// 页面退出时由 autoDispose 销毁 Controller 状态，
/// [PopScope] 同时刷新首页数据。
class SpellingQuizPage extends ConsumerStatefulWidget {
  final String wordBookId;

  const SpellingQuizPage({super.key, this.wordBookId = 'cet6'});

  @override
  ConsumerState<SpellingQuizPage> createState() => _SpellingQuizPageState();
}

class _SpellingQuizPageState extends ConsumerState<SpellingQuizPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(spellingQuizControllerProvider(widget.wordBookId).notifier)
          .startQuiz(widget.wordBookId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPop() {
    ref
        .read(
          homeControllerProvider(ref.read(currentWordBookIdProvider)).notifier,
        )
        .loadData();
    Navigator.of(context).pop();
  }

  /// 统一提交入口（提交按钮与键盘"完成"走同一个方法，
  /// 避免一套有判空、一套没有）。
  Future<void> _submit() async {
    await ref
        .read(spellingQuizControllerProvider(widget.wordBookId).notifier)
        .submitAnswer(_textController.text);
  }

  /// 下一题：推进状态后清空输入框并重新聚焦。
  /// 不操作已销毁的输入框：最后一题（完成态）只清空不聚焦。
  void _handleNext() {
    final notifier = ref.read(
      spellingQuizControllerProvider(widget.wordBookId).notifier,
    );
    notifier.nextQuestion();

    final isCompleted = ref
        .read(spellingQuizControllerProvider(widget.wordBookId))
        .isCompleted;
    _textController.clear();
    if (!isCompleted) {
      _focusNode.requestFocus();
    }
  }

  /// 输入区：英文输入框 + 提交按钮。
  ///
  /// 已提交后锁定输入框，防止改输入但结果仍是第一次答案；
  /// 空输入通过 errorText 提示"请输入单词"（输入无效 ≠ 回答错误）。
  Widget _buildInputSection(SpellingQuizState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !state.hasAnswered,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: '输入英文单词',
            hintText: '请输入单词的英文拼写',
            border: const OutlineInputBorder(),
            errorText: state.inputError,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.hasAnswered ? null : _submit,
          child: const Text('提交答案'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spellingQuizControllerProvider(widget.wordBookId));

    // 保存失败 ≠ 答错，不影响答题真假（与选择题 / 听音辨词一致）——
    // 通过 SnackBar 通知用户
    ref.listen<SpellingQuizState>(
      spellingQuizControllerProvider(widget.wordBookId),
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
          title: const Text('拼写复习'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onPop,
          ),
        ),
        // 分支顺序固定：isLoading → hasError → words.isEmpty
        // → isCompleted → 答题内容，不依赖 currentWord == null 判断完成态
        body: state.isLoading
            ? const LoadingView()
            : state.hasError
            ? ErrorView(
                message: state.errorMessage,
                onRetry: () => ref
                    .read(
                      spellingQuizControllerProvider(
                        widget.wordBookId,
                      ).notifier,
                    )
                    .startQuiz(widget.wordBookId),
              )
            : state.words.isEmpty
            ? SpellingEmptyView(onBack: _onPop)
            : state.isCompleted
            ? SpellingCompleteView(
                correctCount: state.correctCount,
                wrongCount: state.wrongCount,
                onBack: _onPop,
              )
            : _buildContent(state),
      ),
    );
  }

  Widget _buildContent(SpellingQuizState state) {
    // 走到答题内容分支时 words 非空且未完成，currentWord 一定存在
    final word = state.currentWord!;
    final isLast = state.currentIndex >= state.words.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SpellingProgressHeader(
            currentIndex: state.currentIndex,
            total: state.words.length,
            correctCount: state.correctCount,
            wrongCount: state.wrongCount,
          ),
          const SizedBox(height: 24),
          SpellingMeaningCard(word: word),
          const SizedBox(height: 24),
          _buildInputSection(state),
          const SizedBox(height: 16),
          if (state.hasAnswered) ...[
            SpellingFeedbackCard(
              isCorrect: state.isCorrect,
              submittedAnswer: state.submittedAnswer,
              correctWord: word.word,
            ),
            const SizedBox(height: 16),
            // 手动"下一题"（约束：不自动跳转，答错后留时间看正确拼写）
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handleNext,
                child: Text(isLast ? '查看结果' : '下一题'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
