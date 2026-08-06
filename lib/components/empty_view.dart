import 'package:flutter/material.dart';

/// 空数据占位组件，显示无数据提示
class EmptyView extends StatelessWidget {
  final String? message;

  const EmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message ?? '暂无数据', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
