import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/sources/local/word_book_preference_local_source.dart';
import '../../../providers/repository_providers.dart';
import '../controller/current_word_book_controller.dart';
import '../state/current_word_book_state.dart';

/// 当前词库选择相关 Provider。

/// 词库偏好本地源 Provider。
///
/// 实例由 getIt 管理（settings Box 经 @Named 注入，见 dependency_injection），
/// 此处仅做获取，不在 Provider 内手工组装依赖。
final wordBookPreferenceLocalSourceProvider =
    Provider<WordBookPreferenceLocalSource>((ref) {
      return ref.read(getItProvider).get<WordBookPreferenceLocalSource>();
    });

/// 当前词库选择控制器 Provider。
///
/// 非 autoDispose：当前词库是全局状态，需在整个 App 生命周期内保持。
final currentWordBookControllerProvider =
    StateNotifierProvider<CurrentWordBookController, CurrentWordBookState>(
      (ref) => CurrentWordBookController(
        ref.watch(wordBookPreferenceLocalSourceProvider),
        ref.watch(wordBookRegistryProvider),
      ),
    );

/// 当前词库 ID 便利 Provider。
///
/// 业务页面只需 watch 这个 String，不必关心 isInitialized / errorMessage。
/// 未来自建词库接入后，这里返回的仍是统一的 currentWordBookId。
final currentWordBookIdProvider = Provider<String>((ref) {
  return ref.watch(
    currentWordBookControllerProvider.select(
      (state) => state.currentWordBookId,
    ),
  );
});
