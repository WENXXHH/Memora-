import 'package:flutter/material.dart';

/// 用户信息头：展示当前登录用户的头像、用户名与邮箱。
class ProfileUserHeader extends StatelessWidget {
  const ProfileUserHeader({
    super.key,
    this.username,
    this.email,
  });

  /// 用户名（空/未登录时显示"未知用户"）。
  final String? username;

  /// 邮箱。
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Icon(
            Icons.person,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username ?? '未知用户',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
