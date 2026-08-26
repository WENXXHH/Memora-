import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/home_controller.dart';
import '../state/home_state.dart';
import '../../../providers/repository_providers.dart';

/// 首页功能 Riverpod Provider 定义
///
/// 按规范将 Provider 与 Controller 类分离。
/// family(wordBookId)：每个词库一份独立首页状态（doc 26 / 40），
/// 当前词库变化时页面自然 watch 新实例，统计自动跟随切换。
final homeControllerProvider =
    StateNotifierProvider.family<HomeController, HomeState, String>(
      (ref, wordBookId) => HomeController(
        wordBookId,
        ref.read(wordRepositoryProvider),
        ref.read(reviewRepositoryProvider),
      ),
    );
