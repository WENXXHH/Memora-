import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';

/// GetIt 依赖注入实例
///
/// 使用方式：
/// ```dart
/// final repository = getIt<WordRepository>();
/// ```
final getIt = GetIt.instance;

/// 依赖注入初始化函数
///
/// 在 main.dart 中调用：
/// ```dart
/// void main() async {
///   configureDependencies();
///   runApp(const MyApp());
/// }
/// ```
///
/// 配置说明：
/// - preferRelativeImports: true 优先使用相对路径导入
/// - asExtension: false 不生成扩展方法
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
