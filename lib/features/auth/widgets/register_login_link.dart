import 'package:flutter/material.dart';

/// 注册页底部“已有账号？登录”跳转入口。
class RegisterLoginLink extends StatelessWidget {
  const RegisterLoginLink({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('已有账号？'),
        TextButton(
          onPressed: onPressed,
          child: const Text('登录'),
        ),
      ],
    );
  }
}
