import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/built_in_word_books.dart';
import '../../../data/sources/local/word_book_preference_local_source.dart';
import '../state/current_word_book_state.dart';

/// 当前词库选择控制器（doc 12 / 13 / 14 / 54 / 55）。
///
/// 职责只有三件：恢复选择、选择词库、重置默认。
/// - 不负责加载 Word（doc 12）
/// - 不依赖任何学习 Controller（doc 15，避免成为上帝对象）
///
/// 选择顺序（doc 55 / Bug 9 防御）：验证 → 去重 → 先持久化 →
/// 成功后才更新 state。保存失败时当前选择不变，保证内存与磁盘一致。
class CurrentWordBookController extends StateNotifier<CurrentWordBookState> {
  CurrentWordBookController(this._localSource)
    : super(const CurrentWordBookState());

  final WordBookPreferenceLocalSource _localSource;

  /// 恢复用户上次的词库选择（doc 10 / 11 / 44）。
  ///
  /// - 无历史选择 → 保持默认 CET-6
  /// - 历史选择有效 → 恢复
  /// - 历史选择无效 → fallback CET-6，并顺手修正存储
  ///   （避免每次启动都遇到同一个坏数据，doc 11）
  /// - 读取异常 → 降级 CET-6，不阻止 App 使用（doc 44）
  ///
  /// 幂等：已初始化时直接返回。
  Future<void> initialize() async {
    if (state.isInitialized) return;

    String? savedId;
    try {
      savedId = _localSource.readCurrentWordBookId();
    } catch (_) {
      state = state.copyWith(
        isInitialized: true,
        errorMessage: '读取词库偏好失败，已恢复默认',
      );
      return;
    }

    if (savedId == null) {
      state = state.copyWith(isInitialized: true);
      return;
    }

    if (BuiltInWordBooks.contains(savedId)) {
      state = state.copyWith(currentWordBookId: savedId, isInitialized: true);
      return;
    }

    // 非法历史 ID（如旧版本遗留的 cet5）：回退默认并修正存储。
    // 修正失败不阻断启动，状态仍回退默认。
    try {
      await _localSource.saveCurrentWordBookId(BuiltInWordBooks.cet6.id);
    } catch (_) {
      // 忽略：下次启动会再次尝试修正
    }
    state = state.copyWith(
      isInitialized: true,
      errorMessage: '已保存的词库无效，已恢复默认 CET-6',
    );
  }

  /// 主动选择词库（doc 13 / 55）。
  ///
  /// - 非法 ID：state 不变 + errorMessage（明确失败，不静默 fallback）
  /// - 与当前相同：no-op，不重复写存储（doc 14 / Bug 8 防御）
  /// - 先持久化，成功后才更新 state（Bug 9 防御）
  Future<void> selectWordBook(String wordBookId) async {
    if (!BuiltInWordBooks.contains(wordBookId)) {
      state = state.copyWith(errorMessage: '未知词库: $wordBookId');
      return;
    }

    if (wordBookId == state.currentWordBookId) return;

    try {
      await _localSource.saveCurrentWordBookId(wordBookId);
    } catch (_) {
      state = state.copyWith(errorMessage: '保存词库选择失败');
      return;
    }

    state = state.copyWith(currentWordBookId: wordBookId, errorMessage: null);
  }

  /// 重置回默认词库（CET-6）。
  ///
  /// 通过 [selectWordBook] 复用验证与持久化链路；当前已是默认时 no-op。
  Future<void> resetToDefault() async {
    await selectWordBook(BuiltInWordBooks.cet6.id);
  }
}
