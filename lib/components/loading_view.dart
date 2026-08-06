import 'package:flutter/material.dart';

/// 通用的加载中组件，居中显示转圈动画
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
