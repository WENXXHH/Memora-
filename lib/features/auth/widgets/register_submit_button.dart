import 'package:flutter/material.dart';

/// 注册提交按钮：加载中禁用并显示白色转圈进度，否则显示“注册”。
class RegisterSubmitButton extends StatelessWidget {
  const RegisterSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('注册'),
    );
  }
}
