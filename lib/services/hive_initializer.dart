import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// 集中管理 Hive 的初始化生命周期。
///
/// 遵循规范：统一由一个 Initializer 打开 Box，
/// 其他层（Repository / DataSource）只获取已打开实例，
/// 不在多处重复调用 openBox()。
class HiveInitializer {
  HiveInitializer._();

  /// Box 名称常量
  static const String reviewsBoxName = 'reviews';

  /// 初始化 Hive 引擎并打开 reviews Box。
  ///
  /// 必须在 WidgetsFlutterBinding.ensureInitialized() 之后、
  /// configureDependencies() 之前调用。
  ///
  /// 返回已打开的 Box<Map>，由调用方注册到 DI 容器。
  static Future<Box<Map<dynamic, dynamic>>> initialize() async {
    await Hive.initFlutter();

    final box = await Hive.openBox<Map<dynamic, dynamic>>(reviewsBoxName);
    return box;
  }
}
