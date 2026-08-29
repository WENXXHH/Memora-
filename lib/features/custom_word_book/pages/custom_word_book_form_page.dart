import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/custom_word_book_providers.dart';

/// 自建词库创建 / 重命名表单页（doc 39）。
///
/// [bookId] 为 null 时是"新建"模式，否则为"重命名"模式。
/// 名称校验走管理控制器的 [validateName]（doc 13 / 14），
/// 校验失败在输入框下方内联提示，存储失败用 SnackBar 提示。
class CustomWordBookFormPage extends ConsumerStatefulWidget {
  const CustomWordBookFormPage({super.key, this.bookId});

  /// 要重命名的词库 ID；null 表示新建。
  final String? bookId;

  @override
  ConsumerState<CustomWordBookFormPage> createState() =>
      _CustomWordBookFormPageState();
}

class _CustomWordBookFormPageState
    extends ConsumerState<CustomWordBookFormPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;
  bool _submitting = false;

  bool get _isEdit => widget.bookId != null;

  @override
  void initState() {
    super.initState();
    // 重命名模式：回填当前名称
    if (widget.bookId != null) {
      Future.microtask(() {
        final books = ref
            .read(customWordBookManagementControllerProvider)
            .wordBooks;
        final book = books.where((b) => b.id == widget.bookId).firstOrNull;
        if (book != null && _nameController.text.isNotEmpty) {
          _nameController.text = book.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 提交：先即时校验名称，再走控制器创建 / 重命名。
  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _errorText = null);

    final controller = ref.read(
      customWordBookManagementControllerProvider.notifier,
    );
    final name = _nameController.text;
    final error = controller.validateName(name, excludeId: widget.bookId);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() => _submitting = true);
    final result = _isEdit
        ? await controller.rename(widget.bookId!, name.trim())
        : await controller.create(name.trim());
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_isEdit ? '词库已重命名' : '词库已创建')));
      context.pop();
      return;
    }

    // 即时校验通过但存储层仍失败（如数据冲突），展示控制器错误
    final stateError = ref
        .read(customWordBookManagementControllerProvider)
        .errorMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(stateError ?? '操作失败，请重试')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '重命名词库' : '新建词库'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: '词库名称',
                hintText: '如：考研词汇',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? '保存' : '创建'),
            ),
          ],
        ),
      ),
    );
  }
}
