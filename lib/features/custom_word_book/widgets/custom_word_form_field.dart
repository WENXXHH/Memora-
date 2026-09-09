import 'package:flutter/material.dart';

/// 自建单词 / 词库表单页中的输入框：
/// 统一 OutlineInputBorder 外观，控制器与内联校验文案由页面持有并传入。
class CustomWordFormField extends StatelessWidget {
  const CustomWordFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.errorText,
    this.autofocus = false,
    this.onSubmitted,
    this.maxLength,
  });

  /// 文本控制器（由页面持有）。
  final TextEditingController controller;

  /// 输入框标签文案。
  final String labelText;

  /// 占位提示文案。
  final String hintText;

  /// 内联校验错误文案（null 时不展示）。
  final String? errorText;

  /// 是否自动聚焦。
  final bool autofocus;

  /// 提交回调。
  final ValueChanged<String>? onSubmitted;

  /// 最大输入长度。
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
