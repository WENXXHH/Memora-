import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/home_controller.dart';
import '../state/home_state.dart';
import '../../../providers/repository_providers.dart';

/// 首页功能 Riverpod Provider 定义
///
/// 按规范将 Provider 与 Controller 类分离
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(
    ref.read(wordRepositoryProvider),
    ref.read(reviewRepositoryProvider),
  ),
);
