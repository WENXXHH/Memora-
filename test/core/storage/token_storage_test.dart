import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:memora/core/storage/hive_initializer.dart';
import 'package:memora/core/storage/token_storage.dart';

/// TokenStorage 真 Hive 持久化测试。
///
/// 重点覆盖游客模式标记（问题 4：游客杀进程重启回登录页）：
/// 1. 默认非游客
/// 2. setGuestMode(true) 后 isGuestMode 为 true
/// 3. 杀进程（关闭 Box 重新打开）后标记仍在
/// 4. setGuestMode(false) 清除标记
/// 5. 游客标记与 Token 互不影响
void main() {
  late Directory tempDir;
  late Box<String> authBox;
  late TokenStorage storage;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('token_storage_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    authBox = await Hive.openBox<String>(HiveInitializer.authBoxName);
    await authBox.clear();
    storage = TokenStorage(authBox);
  });

  tearDown(() async {
    await authBox.close();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  test('默认无 Token 且非游客模式', () {
    expect(storage.hasToken, isFalse);
    expect(storage.isGuestMode, isFalse);
  });

  test('setGuestMode(true) 后 isGuestMode 为 true', () async {
    await storage.setGuestMode(true);

    expect(storage.isGuestMode, isTrue);
    // 不影响 Token 判定
    expect(storage.hasToken, isFalse);
  });

  test('游客标记杀进程持久化：关闭 Box 重开后仍为 true', () async {
    await storage.setGuestMode(true);
    await authBox.close();

    // 模拟杀进程重启
    authBox = await Hive.openBox<String>(HiveInitializer.authBoxName);
    storage = TokenStorage(authBox);

    expect(storage.isGuestMode, isTrue);
  });

  test('setGuestMode(false) 清除游客标记（模拟登录 / 登出）', () async {
    await storage.setGuestMode(true);
    expect(storage.isGuestMode, isTrue);

    await storage.setGuestMode(false);
    expect(storage.isGuestMode, isFalse);
  });

  test('登录写 Token 后游客标记仍为 false，重启进登录恢复而非游客', () async {
    await storage.setGuestMode(true);
    await storage.saveToken('jwt-abc');
    await storage.setGuestMode(false);
    await authBox.close();

    authBox = await Hive.openBox<String>(HiveInitializer.authBoxName);
    storage = TokenStorage(authBox);

    expect(storage.hasToken, isTrue);
    expect(storage.isGuestMode, isFalse);
  });
}
