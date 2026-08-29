import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/data/sources/local/word_book_preference_local_source.dart';

/// WordBookPreferenceLocalSource 持久化测试（doc 72 第三层）。
///
/// 使用真实 Hive settings Box（临时目录），覆盖：
/// 1. 无历史 → readCurrentWordBookId 返回 null
/// 2. save → read 覆盖写
/// 3. 杀进程持久化：保存选择 → 关闭 Box → 重新打开 → 仍能恢复 custom
void main() {
  late Directory tempDir;
  late Box<String> box;
  late WordBookPreferenceLocalSource source;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('word_book_pref_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<String>('settings');
    await box.clear();
    source = WordBookPreferenceLocalSource(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('读写（doc 9）', () {
    test('无历史选择 → null', () {
      expect(source.readCurrentWordBookId(), isNull);
    });

    test('save → read 恢复相同值', () async {
      await source.saveCurrentWordBookId('custom_abc');
      expect(source.readCurrentWordBookId(), 'custom_abc');
    });

    test('覆盖写：cet4 → custom_abc 以后者为准', () async {
      await source.saveCurrentWordBookId('cet4');
      await source.saveCurrentWordBookId('custom_abc');
      expect(source.readCurrentWordBookId(), 'custom_abc');
    });
  });

  group('杀进程持久化（doc 72 第三层）', () {
    test('选择 custom_abc → 关闭 Box → 重新打开 → 仍为 custom_abc', () async {
      await source.saveCurrentWordBookId('custom_abc');
      await box.close();

      // 模拟杀进程重启：同目录同名称重新打开 settings Box
      box = await Hive.openBox<String>('settings');
      source = WordBookPreferenceLocalSource(box);

      expect(source.readCurrentWordBookId(), 'custom_abc');
    });
  });
}
