import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 底部导航壳组件
///
/// 封装 StatefulNavigationShell，提供统一的底部Tab栏
/// 使用 Material 3 NavigationBar 组件
class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({super.key, required this.navigationShell});

  /// StatefulNavigationShell 实例，用于管理底部导航状态
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // 如果用户再次点击当前已经选中的 Tab，就回到这个 branch 的初始路由。
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
