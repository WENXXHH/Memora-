import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/error_view.dart';
import '../../../components/loading_view.dart';
import '../../../data/dto/word_model.dart';
import '../../home/providers/home_providers.dart';
import '../providers/spelling_quiz_providers.dart';
import '../state/spelling_quiz_state.dart';

/// 拼写复习页（doc 22 / 23 / 24 / 25 / 29 / 30）。
///
/// 与选择题 / 听音辨词的差异：
/// - 题目区只显示中文释义（每词性一行，与学习页一致），不显示英文拼写
/// - 用户输入英文单词并提交，由 [SpellingAnswerMatcher] 判定对错
/// - 空输入通过 inputError 提示（doc 8），输入无效 ≠ 回答错误
/// - SM-2 映射：拼写正确 → known，错误 → unknown
/// - 答后输入框锁定（doc 23），键盘"完成"与按钮走同一入口（doc 24）
/// - 下一题时清空输入框并重新聚焦（doc 25）
///
/// 页面退出时由 autoDispose 销毁 Controller 状态（Bug 8），
/// [PopScope] 同时刷新首页数据（doc 22 返回首页必须刷新统计）。
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
    ref.read(homeControllerProvider.notifier).loadData();
    Navigator.of(context).pop();
  }

  /// 统一提交入口（doc 24：提交按钮与键盘"完成"走同一个方法，
  /// 避免一套有判空、一套没有）。
  Future<void> _submit() async {
    await ref
        .read(spellingQuizControllerProvider(widget.wordBookId).notifier)
        .submitAnswer(_textController.text);
  }

  /// 下一题：推进状态后清空输入框并重新聚焦（doc 25）。
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

  /// 构建空状态（doc 30：无到期复习词时不能一直转圈 / RangeError）
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无需要拼写复习的单词',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成日常学习后再来拼写复习',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _onPop, child: const Text('返回首页')),
        ],
      ),
    );
  }

  /// 构建完成视图（doc 29：总题数 / 正确 / 错误 / 正确率）
  Widget _buildComplete(SpellingQuizState state) {
    final total = state.correctCount + state.wrongCount;
    final accuracy = total > 0 ? (state.correctCount / total * 100).round() : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '拼写复习完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('总题数', total, Colors.blueGrey),
              const SizedBox(width: 24),
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
  Widget _buildProgress(SpellingQuizState state) {
    final total = state.words.length;
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

  /// 题目面：中文释义（每词性一行，与学习页 word_learning_card 一致，
  /// doc 22 释义显示格式）。
  Widget _buildMeaningCard(Word word) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '中文释义',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...word.meaning.map(
              (meaning) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${meaning.pos} ${meaning.definitions.join('、')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输入区：英文输入框 + 提交按钮
  Widget _buildInputSection(SpellingQuizState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          // doc 23：已提交后锁定输入框，防止改输入但结果仍是第一次答案
          enabled: !state.hasAnswered,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          // doc 24：键盘"完成"与提交按钮走同一入口
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: '输入英文单词',
            hintText: '请输入单词的英文拼写',
            border: const OutlineInputBorder(),
            // doc 8：空输入通过 errorText 提示"请输入单词"
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

  /// 答后反馈：正确显示单词，错误显示用户答案 + 正确拼写
  Widget _buildFeedback(SpellingQuizState state, Word word) {
    final isCorrect = state.isCorrect ?? false;
    final color = isCorrect ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              isCorrect ? '拼写正确' : '拼写错误',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            if (isCorrect)
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            else ...[
              const Text('你的答案：', style: TextStyle(color: Colors.grey)),
              Text(
                state.submittedAnswer ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              const Text('正确答案：', style: TextStyle(color: Colors.grey)),
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spellingQuizControllerProvider(widget.wordBookId));

    // 保存失败反馈 — 通过 SnackBar 通知用户（与选择题 / 听音辨词一致，
    // doc 19：保存失败 ≠ 答错，不影响答题真假）
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
          ref.read(homeControllerProvider.notifier).loadData();
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
        // 分支顺序固定（doc 12）：isLoading → hasError → words.isEmpty
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
            ? _buildEmpty()
            : state.isCompleted
            ? _buildComplete(state)
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
          _buildProgress(state),
          const SizedBox(height: 24),
          _buildMeaningCard(word),
          const SizedBox(height: 24),
          _buildInputSection(state),
          const SizedBox(height: 16),
          if (state.hasAnswered) ...[
            _buildFeedback(state, word),
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
