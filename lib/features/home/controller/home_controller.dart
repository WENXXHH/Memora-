import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页状态类
///
/// 采用不可变模式，通过 copyWith 方法更新状态
/// 包含首页展示所需的所有数据字段
class HomeState {
  /// 待复习单词数量
  final int reviewCount;

  /// 今日已学习单词数量
  final int learnedCount;

  /// 词库总单词数量
  final int totalWords;

  /// 已掌握单词数量
  final int masteredWords;

  /// 连续打卡天数
  final int streakDays;

  /// 数据加载状态
  final bool isLoading;

  HomeState({
    required this.reviewCount,
    required this.learnedCount,
    required this.totalWords,
    required this.masteredWords,
    required this.streakDays,
    required this.isLoading,
  });

  /// 复制当前状态并更新指定字段
  ///
  /// 不可变对象的标准更新方式，返回新的状态实例
  HomeState copyWith({
    int? reviewCount,
    int? learnedCount,
    int? totalWords,
    int? masteredWords,
    int? streakDays,
    bool? isLoading,
  }) {
    return HomeState(
      reviewCount: reviewCount ?? this.reviewCount,
      learnedCount: learnedCount ?? this.learnedCount,
      totalWords: totalWords ?? this.totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 首页状态控制器
///
/// 继承 StateNotifier，管理首页状态和数据加载逻辑
/// 当前使用 Mock 数据模拟异步加载，后续可替换为真实数据层调用
class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(
    // 初始状态：所有数据为0，处于加载中
    HomeState(
      reviewCount: 0,
      learnedCount: 0,
      totalWords: 0,
      masteredWords: 0,
      streakDays: 0,
      isLoading: true,
    ),
  );

  /// 加载首页数据
  ///
  /// 模拟800ms延迟，模拟异步数据获取过程
  /// 后续接入真实数据时，需替换为 WordRepository 和学习记录的查询逻辑
  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    state = state.copyWith(
      reviewCount: 15,
      learnedCount: 5,
      totalWords: 200,
      masteredWords: 45,
      streakDays: 7,
      isLoading: false,
    );
  }
}

/// 首页状态提供者
///
/// 通过 Riverpod 向页面提供 HomeController 实例和 HomeState 状态监听
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(),
);