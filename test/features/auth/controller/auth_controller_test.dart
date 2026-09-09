import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/auth_models.dart';
import 'package:memora/data/repositories/auth_repository.dart';
import 'package:memora/data/services/user_data_space_service.dart';
import 'package:memora/features/auth/controller/auth_controller.dart';
import 'package:memora/features/auth/state/auth_state.dart';

/// AuthController 游客模式持久化测试（问题 4：游客杀进程重启回登录页）。
///
/// 覆盖：
/// 1. restoreSession 无 Token + 游客标记 true → 直接恢复 guest 态
/// 2. restoreSession 无 Token + 标记 false → unauthenticated（回登录页）
/// 3. restoreSession Token 有效 → authenticated + 切换用户空间
/// 4. enterGuestMode → 写 guest 标记 true + 切 guest 空间
/// 5. login 成功 → 清 guest 标记 + 迁用户空间
/// 6. register 成功 → 清 guest 标记
/// 7. logout → 清 guest 标记
void main() {
  const user = RemoteUser(id: 7, username: 'alice', email: 'a@x.com');

  late FakeAuthRepository authRepo;
  late FakeUserDataSpaceService dataSpace;
  late AuthController controller;

  setUp(() {
    authRepo = FakeAuthRepository();
    dataSpace = FakeUserDataSpaceService();
    controller = AuthController(authRepo, dataSpace);
  });

  group('restoreSession — 杀进程重启恢复', () {
    test('无 Token 且游客标记 true → 恢复 guest 态 + 切 guest 空间', () async {
      authRepo.restoreResult = RestoreSessionResult.noToken;
      authRepo.guestMode = true;

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.guest);
      expect(dataSpace.switchToGuestCalls, 1);
      expect(dataSpace.switchToUserCalls, isEmpty);
    });

    test('无 Token 且游客标记 false → unauthenticated（回登录页）', () async {
      authRepo.restoreResult = RestoreSessionResult.noToken;
      authRepo.guestMode = false;

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(dataSpace.switchToGuestCalls, 0);
    });

    test('Token 有效 → authenticated + 切换对应用户空间', () async {
      authRepo.restoreResult = RestoreSessionResult.valid(user);
      authRepo.guestMode = true; // 即使残留标记，有效 Token 优先

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.currentUser?.id, 7);
      expect(dataSpace.switchToUserCalls, ['7']);
      expect(dataSpace.switchToGuestCalls, 0);
    });
  });

  group('enterGuestMode — 持久化游客标记', () {
    test('进入游客模式 → 写 true + 切 guest 空间 + guest 态', () async {
      await controller.enterGuestMode();

      expect(controller.state.status, AuthStatus.guest);
      expect(authRepo.guestModeWrites, [true]);
      expect(dataSpace.switchToGuestCalls, 1);
    });
  });

  group('login / register / logout — 清除游客标记', () {
    test('login 成功 → 写 false + 迁用户空间 + authenticated', () async {
      await controller.login(username: 'alice', password: 'pw');

      expect(controller.state.status, AuthStatus.authenticated);
      expect(authRepo.guestModeWrites.last, false);
      expect(dataSpace.switchToUserCalls, ['7']);
    });

    test('register 成功 → 写 false + unauthenticated（回登录页登录）', () async {
      await controller.register(
        username: 'bob',
        email: 'b@x.com',
        password: 'pw',
      );

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(authRepo.guestModeWrites, [false]);
    });

    test('logout → 写 false + 切 guest 空间 + unauthenticated', () async {
      await controller.logout();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(authRepo.guestModeWrites, [false]);
      expect(dataSpace.switchToGuestCalls, 1);
    });
  });
}

/// Fake AuthRepository — 内存控制恢复结果与游客标记。
class FakeAuthRepository implements AuthRepository {
  /// restoreSession 的返回值（默认 noToken）。
  RestoreSessionResult restoreResult = RestoreSessionResult.noToken;

  /// 当前游客标记（模拟持久层）。
  bool guestMode = false;

  /// 记录所有 setGuestMode 调用参数。
  final List<bool> guestModeWrites = [];

  @override
  bool get isGuestMode => guestMode;

  @override
  Future<void> setGuestMode(bool enabled) async {
    guestModeWrites.add(enabled);
    guestMode = enabled;
  }

  @override
  Future<RestoreSessionResult> restoreSession() async => restoreResult;

  @override
  Future<RemoteUser> login({
    required String username,
    required String password,
  }) async {
    return const RemoteUser(id: 7, username: 'alice', email: 'a@x.com');
  }

  @override
  Future<RemoteUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return RemoteUser(id: 8, username: username, email: email);
  }

  @override
  Future<void> logout() async {}
}

/// Fake UserDataSpaceService — 记录空间切换调用。
class FakeUserDataSpaceService implements UserDataSpaceService {
  final List<String> switchToUserCalls = [];
  int switchToGuestCalls = 0;

  @override
  Future<void> switchToUser(String userId) async {
    switchToUserCalls.add(userId);
  }

  @override
  Future<void> switchToGuest() async {
    switchToGuestCalls++;
  }

  @override
  Future<void> migrateLegacyKeysToGuest() async {}

  @override
  String currentOwner() => 'guest';
}
