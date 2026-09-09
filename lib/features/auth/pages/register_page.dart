import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../widgets/register_error_banner.dart';
import '../widgets/register_header.dart';
import '../widgets/register_login_link.dart';
import '../widgets/register_submit_button.dart';

/// 注册页。
///
/// 客户端校验规则与后端 UserCreate 一致：
/// - username: 3-50 字符
/// - email: 合法邮箱格式
/// - password: 6-128 字符
///
/// 注册成功后弹出「注册成功，请登录」提示并主动跳转 /login
/// （SnackBar 挂在根 ScaffoldMessenger，跨页面可见）；
/// 失败则留在本页，由错误横幅展示原因。
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 提交注册表单。
  ///
  /// 成功（状态回到 unauthenticated）→ 弹出「注册成功，请登录」提示并
  /// 立即跳转登录页；失败（error 态）→ 留在本页，由错误横幅展示原因。
  ///
  /// 成功后必须立即离开本页：否则按钮在 isLoading 复位后可再次点击，
  /// 重复注册会触发「用户名已存在」错误，误导用户以为注册失败。
  /// SnackBar 挂在 MaterialApp 的根 ScaffoldMessenger 上，
  /// 路由切换后在登录页仍然可见。
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (ref.read(authControllerProvider).status == AuthStatus.unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功，请登录')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    final errorMessage =
        authState.status == AuthStatus.error ? authState.errorMessage : null;

    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RegisterHeader(),

              // 用户名
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  helperText: '3-50 个字符',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.trim().length < 3) {
                    return '用户名至少 3 个字符';
                  }
                  if (value.trim().length > 50) {
                    return '用户名不能超过 50 个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 邮箱
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入邮箱';
                  }
                  // 简易邮箱格式校验
                  final emailRegex = RegExp(
                    r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return '邮箱格式不正确';
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
                  helperText: '6-128 个字符',
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
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少 6 个字符';
                  }
                  if (value.length > 128) {
                    return '密码不能超过 128 个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 确认密码
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请再次输入密码';
                  }
                  if (value != _passwordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
              ),
              const SizedBox(height: 24),

              // 错误提示
              if (errorMessage != null) ...[
                RegisterErrorBanner(message: errorMessage),
                const SizedBox(height: 16),
              ],

              // 注册按钮
              RegisterSubmitButton(
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),

              // 登录链接
              RegisterLoginLink(
                onPressed: isLoading ? null : () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
