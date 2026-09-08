import 'package:flutter/material.dart';

/// 登录页底部“还没有账号？注册”跳转入口。
class LoginRegisterLink extends StatelessWidget {
  const LoginRegisterLink({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('还没有账号？'),
        TextButton(
          onPressed: onPressed,
          child: const Text('注册'),
        ),
      ],
    );
  }
}
