import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../widgets/login_error_banner.dart';
import '../widgets/login_header.dart';
import '../widgets/login_register_link.dart';
import '../widgets/login_submit_button.dart';

/// 登录页。
///
/// 表单校验只是改善体验，服务端必须重新验证全部规则。
/// 登录成功后路由守卫自动重定向到 /home，无需手动导航。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 提交登录表单
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    // 登录成功后会自动跳转，这里只在 error 态显示错误
    final errorMessage =
        authState.status == AuthStatus.error ? authState.errorMessage : null;

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoginHeader(),

              // 用户名
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
              ),
              const SizedBox(height: 24),

              // 错误提示
              if (errorMessage != null) ...[
                LoginErrorBanner(message: errorMessage),
                const SizedBox(height: 16),
              ],

              // 登录按钮
              LoginSubmitButton(
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),

              // 注册链接
              LoginRegisterLink(
                onPressed: isLoading ? null : () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
