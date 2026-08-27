import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/custom_word_book_providers.dart';

/// 自建单词新增 / 编辑表单页（doc 42 / 43）。
///
/// [wordId] 为 null 时是"新增"模式，否则为"编辑"模式。
/// - 必填：英文单词、中文释义（doc 12，释义自动生成一条默认 MeaningEntry）
/// - 可选：音标、例句
/// - 英文重复校验走控制器（doc 45），内联提示；英文统一 trim + lowercase
class CustomWordFormPage extends ConsumerStatefulWidget {
  const CustomWordFormPage({
    super.key,
    required this.wordBookId,
    this.wordId,
  });

  /// 所属自建词库 Domain ID。
  final String wordBookId;

  /// 要编辑的单词 ID；null 表示新增。
  final String? wordId;

  @override
  ConsumerState<CustomWordFormPage> createState() =>
      _CustomWordFormPageState();
}

class _CustomWordFormPageState extends ConsumerState<CustomWordFormPage> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _phoneticController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();

  String? _wordError;
  String? _meaningError;
  bool _submitting = false;

  bool get _isEdit => widget.wordId != null;

  @override
  void initState() {
    super.initState();
    // 编辑模式：回填已有内容（单词列表已由详情页加载）
    if (widget.wordId != null) {
      Future.microtask(() {
        final state = ref.read(
          customWordManagementControllerProvider(widget.wordBookId),
        );
        final record = state.words
            .where((w) => w.id == widget.wordId)
            .firstOrNull;
        if (record == null) return;
        _wordController.text = record.word;
        if (record.meaning.isNotEmpty && record.meaning.first.definitions.isNotEmpty) {
          _meaningController.text = record.meaning.first.definitions.first;
        }
        _phoneticController.text = record.phonetic;
        if (record.example.isNotEmpty) {
          _exampleController.text = record.example.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _phoneticController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  /// 提交：先内联校验英文（重复 / 非空）与释义非空，再走控制器保存。
  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _wordError = null;
      _meaningError = null;
    });

    final word = _wordController.text;
    if (word.trim().isEmpty) {
      setState(() => _wordError = '英文不能为空');
      return;
    }
    if (_meaningController.text.trim().isEmpty) {
      setState(() => _meaningError = '中文释义不能为空');
      return;
    }
    // 重复英文校验（doc 45，编辑时排除自身）
    final controller = ref.read(
      customWordManagementControllerProvider(widget.wordBookId).notifier,
    );
    final error = controller.validateWord(word, excludeWordId: widget.wordId);
    if (error != null) {
      setState(() => _wordError = error);
      return;
    }

    setState(() => _submitting = true);
    final result = _isEdit
        ? await controller.update(
            wordId: widget.wordId!,
            word: word,
            phonetic: _phoneticController.text,
            meaningChinese: _meaningController.text,
            example: _exampleController.text,
          )
        : await controller.create(
            word: word,
            phonetic: _phoneticController.text,
            meaningChinese: _meaningController.text,
            example: _exampleController.text,
          );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_isEdit ? '单词已更新' : '单词已添加')));
      context.pop();
      return;
    }

    // 内联校验通过但存储层仍失败，展示控制器错误
    final stateError = ref
        .read(customWordManagementControllerProvider(widget.wordBookId))
        .errorMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(stateError ?? '操作失败，请重试')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑单词' : '添加单词'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _wordController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '英文单词 *',
                hintText: '如：abandon',
                errorText: _wordError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _meaningController,
              decoration: InputDecoration(
                labelText: '中文释义 *',
                hintText: '如：放弃；抛弃',
                errorText: _meaningError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneticController,
              decoration: const InputDecoration(
                labelText: '音标（可选）',
                hintText: '如：/əˈbændən/',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exampleController,
              decoration: const InputDecoration(
                labelText: '例句（可选）',
                hintText: '如：He decided to abandon the project.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }
}
