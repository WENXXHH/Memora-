import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/built_in_word_books.dart';

/// BuiltInWordBooks 目录单元测试（doc 38）。
///
/// 覆盖：
/// 1. all 包含 cet6 / cet4
/// 2. findById(cet6) / findById(cet4) 返回正确配置
/// 3. assetPath / displayName 正确
/// 4. findById(unknown) → null（不回退 cet6）
void main() {
  group('BuiltInWordBooks.all', () {
    test('包含 CET-6 且 CET-6 在前（保持默认行为）', () {
      expect(BuiltInWordBooks.all.first.id, 'cet6');
    });

    test('包含 cet4', () {
      final ids = BuiltInWordBooks.all.map((b) => b.id).toList();
      expect(ids, contains('cet4'));
    });
  });

  group('BuiltInWordBooks.findById', () {
    test('cet6 → CET-6 配置', () {
      final config = BuiltInWordBooks.findById('cet6');
      expect(config, isNotNull);
      expect(config!.name, 'CET-6');
      expect(config.assetPath, 'assets/data/cet-6.json');
    });

    test('cet4 → CET-4 配置', () {
      final config = BuiltInWordBooks.findById('cet4');
      expect(config, isNotNull);
      expect(config!.name, 'CET-4');
      expect(config.assetPath, 'assets/data/cet-4.json');
    });

    test('assetPath 与展示名称分离：cet4 使用 cet-4.json', () {
      final config = BuiltInWordBooks.findById('cet4')!;
      expect(config.id, 'cet4');
      expect(config.name, 'CET-4');
      expect(config.assetPath, 'assets/data/cet-4.json');
    });

    test('unknown → null（严禁回退 cet6）', () {
      expect(BuiltInWordBooks.findById('unknown'), isNull);
      expect(BuiltInWordBooks.findById('cet4_typo'), isNull);
    });
  });

  group('BuiltInWordBooks.contains', () {
    test('cet6 / cet4 均为已注册内置词库', () {
      expect(BuiltInWordBooks.contains('cet6'), isTrue);
      expect(BuiltInWordBooks.contains('cet4'), isTrue);
    });

    test('未知词库不为已注册内置词库', () {
      expect(BuiltInWordBooks.contains('toefl'), isFalse);
    });
  });
}
