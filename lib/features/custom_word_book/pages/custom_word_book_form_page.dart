import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/custom_word_book_providers.dart';
import '../widgets/custom_word_form_field.dart';
import '../widgets/custom_word_form_submit_button.dart';

/// 自建词库创建 / 重命名表单页。
///
/// [bookId] 为 null 时是"新建"模式，否则为"重命名"模式。
/// 名称校验走管理控制器的 [validateName]，
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
        if (book != null && _nameController.text.isEmpty) {
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
      // 先退出页面（列表自动刷新 + 页面关闭本身就是主反馈），
      // 再在根 ScaffoldMessenger 上提示；pop 后本页 context 已失效，
      // 必须提前捕获 messenger。
      final messenger = ScaffoldMessenger.of(context);
      context.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? '词库已重命名' : '词库已创建')),
      );
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
            CustomWordFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: 30,
              labelText: '词库名称',
              hintText: '如：考研词汇',
              errorText: _errorText,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            CustomWordFormSubmitButton(
              submitting: _submitting,
              label: _isEdit ? '保存' : '创建',
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
