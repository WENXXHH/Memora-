import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/built_in_word_books.dart';
import 'package:memora/data/sources/local/word_book_preference_local_source.dart';
import 'package:memora/features/word_book_selection/controller/current_word_book_controller.dart';

/// CurrentWordBookController 单元测试（doc 46）。
///
/// 覆盖：
/// 1. 无历史数据 → cet6
/// 2. 保存 cet4 → initialize 恢复 cet4
/// 3. 保存 cet6 → initialize 恢复 cet6
/// 4. 保存非法 ID → fallback cet6
/// 5. 非法历史 ID 被修复（存储写回 cet6）
/// 6. selectWordBook(cet4) → state = cet4
/// 7. selectWordBook 后写入持久化
/// 8. 重复选择 cet4 → 不重复写
/// 9. selectWordBook(unknown) → state 不变
/// 10. 切 cet6 → cet4 → cet6 → 状态正确
/// 额外：读取异常降级 / 保存失败 state 不变 / resetToDefault
void main() {
  late FakeWordBookPreferenceLocalSource localSource;
  late CurrentWordBookController controller;

  setUp(() {
    localSource = FakeWordBookPreferenceLocalSource();
    controller = CurrentWordBookController(localSource);
  });

  group('initialize（doc 10 / 46）', () {
    test('无历史数据 → cet6 且 isInitialized', () async {
      await controller.initialize();
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(controller.state.isInitialized, isTrue);
      expect(controller.state.errorMessage, isNull);
    });

    test('保存 cet4 → initialize 恢复 cet4', () async {
      localSource.stored = 'cet4';
      await controller.initialize();
      expect(controller.state.currentWordBookId, 'cet4');
      expect(controller.state.isInitialized, isTrue);
    });

    test('保存 cet6 → initialize 恢复 cet6', () async {
      localSource.stored = 'cet6';
      await controller.initialize();
      expect(controller.state.currentWordBookId, 'cet6');
      expect(controller.state.isInitialized, isTrue);
    });

    test('保存非法 ID → fallback cet6 + errorMessage', () async {
      localSource.stored = 'cet5';
      await controller.initialize();
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(controller.state.isInitialized, isTrue);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('非法历史 ID 被修复：存储写回 cet6（doc 11）', () async {
      localSource.stored = 'cet5';
      await controller.initialize();
      expect(localSource.stored, BuiltInWordBooks.cet6.id);
      expect(localSource.writeCount, 1);
    });

    test('读取异常 → 降级 cet6 + errorMessage，不阻止 App 使用（doc 44）', () async {
      localSource.throwOnRead = true;
      await controller.initialize();
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(controller.state.isInitialized, isTrue);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('initialize 幂等：重复调用不重复读取', () async {
      localSource.stored = 'cet4';
      await controller.initialize();
      await controller.initialize();
      // 第二次 initialize 被 isInitialized 拦截，不产生额外副作用
      expect(controller.state.currentWordBookId, 'cet4');
    });
  });

  group('selectWordBook（doc 13 / 14 / 46）', () {
    test('selectWordBook(cet4) → state = cet4', () async {
      await controller.selectWordBook('cet4');
      expect(controller.state.currentWordBookId, 'cet4');
      expect(controller.state.errorMessage, isNull);
    });

    test('selectWordBook 后写入持久化（doc 46 #7）', () async {
      await controller.selectWordBook('cet4');
      expect(localSource.stored, 'cet4');
      expect(localSource.writeCount, 1);
    });

    test('重复选择 cet4 → 不重复写（doc 14 / Bug 8 防御）', () async {
      await controller.selectWordBook('cet4');
      await controller.selectWordBook('cet4');
      expect(localSource.writeCount, 1);
      expect(controller.state.currentWordBookId, 'cet4');
    });

    test('selectWordBook(unknown) → state 不变 + errorMessage（doc 13）', () async {
      await controller.selectWordBook('cet5');
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(controller.state.errorMessage, contains('cet5'));
      expect(localSource.writeCount, 0);
    });

    test('切 cet6 → cet4 → cet6 状态正确（doc 46 #10）', () async {
      await controller.selectWordBook('cet4');
      expect(controller.state.currentWordBookId, 'cet4');

      await controller.selectWordBook('cet6');
      expect(controller.state.currentWordBookId, 'cet6');
      expect(localSource.stored, 'cet6');
    });

    test('保存失败 → state 不变 + errorMessage（Bug 9 防御）', () async {
      localSource.throwOnWrite = true;
      await controller.selectWordBook('cet4');
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(controller.state.errorMessage, isNotNull);
      expect(localSource.stored, isNull);
    });

    test('Catalog 中的每个词库都能被 selectWordBook 接受（doc 47）', () async {
      for (final config in BuiltInWordBooks.all) {
        await controller.selectWordBook(config.id);
        expect(
          controller.state.currentWordBookId,
          config.id,
          reason: 'selectWordBook 应接受 Catalog 中 ${config.id}',
        );
      }
    });
  });

  group('resetToDefault（doc 12）', () {
    test('重置回默认 CET-6 并持久化', () async {
      await controller.selectWordBook('cet4');
      await controller.resetToDefault();
      expect(controller.state.currentWordBookId, BuiltInWordBooks.cet6.id);
      expect(localSource.stored, BuiltInWordBooks.cet6.id);
    });

    test('当前已是默认时 no-op', () async {
      await controller.resetToDefault();
      expect(localSource.writeCount, 0);
    });
  });
}

/// 可注入读写异常 / 统计写入次数的 Fake 本地源。
class FakeWordBookPreferenceLocalSource
    implements WordBookPreferenceLocalSource {
  String? stored;
  int writeCount = 0;
  bool throwOnRead = false;
  bool throwOnWrite = false;

  @override
  String? readCurrentWordBookId() {
    if (throwOnRead) {
      throw Exception('read failed');
    }
    return stored;
  }

  @override
  Future<void> saveCurrentWordBookId(String wordBookId) async {
    if (throwOnWrite) {
      throw Exception('write failed');
    }
    stored = wordBookId;
    writeCount++;
  }
}
