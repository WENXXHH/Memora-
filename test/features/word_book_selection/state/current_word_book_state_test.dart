import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/built_in_word_books.dart';
import 'package:memora/features/word_book_selection/state/current_word_book_state.dart';

/// CurrentWordBookState 单元测试（doc 45）。
///
/// 覆盖：
/// 1. 默认 currentWordBookId = cet6
/// 2. 初始 isInitialized = false
/// 3. 默认 errorMessage = null
/// 4. 普通字段更新
/// 5. errorMessage 可设置 / 可清 null（sentinel）
/// 6. copyWith 不传 nullable 参数时保留原值
void main() {
  group('默认值（doc 45）', () {
    test('currentWordBookId 默认 CET-6（与 Catalog 一致）', () {
      const state = CurrentWordBookState();
      expect(state.currentWordBookId, BuiltInWordBooks.cet6.id);
    });

    test('isInitialized 默认 false（尚未恢复用户选择）', () {
      const state = CurrentWordBookState();
      expect(state.isInitialized, isFalse);
    });

    test('errorMessage 默认 null', () {
      const state = CurrentWordBookState();
      expect(state.errorMessage, isNull);
    });
  });

  group('copyWith（doc 45）', () {
    test('普通字段更新', () {
      const state = CurrentWordBookState();
      final updated = state.copyWith(
        currentWordBookId: 'cet4',
        isInitialized: true,
      );
      expect(updated.currentWordBookId, 'cet4');
      expect(updated.isInitialized, isTrue);
      expect(updated.errorMessage, isNull);
    });

    test('errorMessage 可设置', () {
      const state = CurrentWordBookState();
      final updated = state.copyWith(errorMessage: '读取失败');
      expect(updated.errorMessage, '读取失败');
    });

    test('errorMessage 可显式清 null（sentinel）', () {
      const state = CurrentWordBookState(errorMessage: '旧错误');
      final cleared = state.copyWith(errorMessage: null);
      expect(cleared.errorMessage, isNull);
    });

    test('不传 errorMessage 时保留原值', () {
      const state = CurrentWordBookState(errorMessage: '旧错误');
      final updated = state.copyWith(currentWordBookId: 'cet4');
      expect(updated.errorMessage, '旧错误');
    });

    test('copyWith 不修改原 State（不可变）', () {
      const state = CurrentWordBookState();
      state.copyWith(currentWordBookId: 'cet4');
      expect(state.currentWordBookId, BuiltInWordBooks.cet6.id);
    });
  });
}
