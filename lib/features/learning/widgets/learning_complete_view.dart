import 'package:flutter/material.dart';

/// 学习完成页面组件
///
/// 显示完成图标、提示文字和返回首页按钮
/// 通过回调解耦，不直接操作导航或引用其他 feature
class LearningCompleteView extends StatelessWidget {
  final VoidCallback onBackToHome;

  const LearningCompleteView({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            '学习完成！',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onBackToHome, child: const Text('返回首页')),
        ],
      ),
    );
  }
}
