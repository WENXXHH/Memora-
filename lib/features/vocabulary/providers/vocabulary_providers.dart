import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/word_list_controller.dart';
import '../state/word_list_state.dart';
import '../../../providers/repository_providers.dart';

/// 词库功能 Riverpod Provider 定义
///
/// 按规范将 Provider 与 Controller 类分离
final wordListControllerProvider =
    StateNotifierProvider.family<WordListController, WordListState, String>(
      (ref, wordBookId) => WordListController(ref.read(wordRepositoryProvider)),
    );
