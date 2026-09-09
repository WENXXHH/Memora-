import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';
//定义全局 GetIt 依赖容器，并提供 configureDependencies() 作为依赖注入初始化入口
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
