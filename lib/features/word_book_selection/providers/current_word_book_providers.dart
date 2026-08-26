import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/storage/hive_initializer.dart';
import '../../../data/sources/local/word_book_preference_local_source.dart';
import '../../../providers/repository_providers.dart';
import '../controller/current_word_book_controller.dart';
import '../state/current_word_book_state.dart';

/// 当前词库选择相关 Provider（doc 16 / 17）。

/// settings Box Provider（设备级轻量偏好，doc 9）。
///
/// 从 getIt 取已打开的 settings Box，与 auth_providers 读取 auth Box 的模式一致。
final settingsBoxProvider = Provider<Box<String>>((ref) {
  return ref
      .read(getItProvider)
      .get<Box<String>>(instanceName: HiveInitializer.settingsBoxName);
});

/// 词库偏好本地源 Provider。
final wordBookPreferenceLocalSourceProvider =
    Provider<WordBookPreferenceLocalSource>((ref) {
      return WordBookPreferenceLocalSource(ref.watch(settingsBoxProvider));
    });

/// 当前词库选择控制器 Provider。
///
/// 非 autoDispose：当前词库是全局状态，需在整个 App 生命周期内保持。
final currentWordBookControllerProvider =
    StateNotifierProvider<CurrentWordBookController, CurrentWordBookState>(
      (ref) => CurrentWordBookController(
        ref.watch(wordBookPreferenceLocalSourceProvider),
      ),
    );

/// 当前词库 ID 便利 Provider（doc 16）。
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
