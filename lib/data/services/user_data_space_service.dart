import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../core/storage/data_owner.dart';
import '../../core/storage/hive_initializer.dart';
import '../../domain/models/word_review_model.dart';

/// 本地学习数据"所有者空间"管理服务。
///
/// 职责：
/// 1. 维护 auth Box 中的当前 owner（`guest` / `user:<userId>`）；
/// 2. 启动时把旧格式 key（无 owner 前缀的历史数据）一次性归入 guest 空间；
/// 3. 登录成功时把 guest 空间的学习成果 LWW 迁移进用户空间（升级账号不丢数据）；
/// 4. 登出 / 进入游客模式时把 owner 切回 guest。
///
/// 数据隔离由 [ReviewLocalDataSource] 按 owner 前缀读写实现，
/// 本服务只负责"切换空间"与"迁移数据"。
@injectable
class UserDataSpaceService {
  UserDataSpaceService(
    this._reviewsBox,
    @Named(HiveInitializer.authBoxName) this._authBox,
  );

  final Box<Map<dynamic, dynamic>> _reviewsBox;
  final Box<String> _authBox;

  /// 旧记录缺 clientUpdatedAt 时视为 epoch（同步时必然被远端覆盖）。
  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  /// 读取当前 owner（未设置时视为游客）。
  String currentOwner() => _authBox.get(kDataOwnerKey) ?? kDefaultOwner;

  Future<void> _setOwner(String owner) => _authBox.put(kDataOwnerKey, owner);

  /// 启动时一次性迁移：把旧格式 key（无 `|` owner 前缀）归入 guest 空间。
  ///
  /// 历史版本的数据是全局单份、多账号混合的，统一归入 guest 空间后：
  /// 游客态继续可见；登录账号时随迁移逻辑并入对应账号（LWW）。
  Future<void> migrateLegacyKeysToGuest() async {
    // 先固定 key 快照，避免遍历中修改 Box
    final legacyKeys = _reviewsBox.keys
        .whereType<String>()
        .where((key) => !key.contains('|'))
        .toList();

    for (final key in legacyKeys) {
      final data = _reviewsBox.get(key);
      if (data != null) {
        await _reviewsBox.put('$kGuestOwner|$key', data);
      }
      await _reviewsBox.delete(key);
    }
  }

  /// 登录成功时调用：把 guest 空间学习成果迁移到该用户空间，然后切换 owner。
  ///
  /// 迁移采用 LWW（clientUpdatedAt 新者胜）：与用户空间已有记录冲突时，
  /// 保留较新的一方。迁移完成后 guest 空间被清空。
  ///
  /// 必须在置 authenticated 状态**之前**调用，保证登录触发的自动同步
  /// 读到的是切换后的空间。
  Future<void> switchToUser(String userId) async {
    final targetOwner = userOwnerKey(userId);
    final targetPrefix = '$targetOwner|';
    final guestPrefix = '$kGuestOwner|';

    final guestKeys = _reviewsBox.keys
        .whereType<String>()
        .where((key) => key.startsWith(guestPrefix))
        .toList();

    for (final key in guestKeys) {
      final data = _reviewsBox.get(key);
      if (data == null) continue;

      final targetKey = '$targetPrefix${key.substring(guestPrefix.length)}';
      final existing = _reviewsBox.get(targetKey);

      if (existing == null) {
        // 用户空间没有该记录，直接迁入
        await _reviewsBox.put(targetKey, data);
      } else {
        // 冲突：clientUpdatedAt 新者胜
        final guestReview = WordReview.fromJson(
          Map<String, dynamic>.from(data),
        );
        final userReview = WordReview.fromJson(
          Map<String, dynamic>.from(existing),
        );
        final guestWins = (guestReview.clientUpdatedAt ?? _epoch).isAfter(
          userReview.clientUpdatedAt ?? _epoch,
        );
        await _reviewsBox.put(targetKey, guestWins ? data : existing);
      }

      // 迁移后删除 guest 条目
      await _reviewsBox.delete(key);
    }

    await _setOwner(targetOwner);
  }

  /// 登出 / 进入游客模式时调用：owner 切回 guest 空间。
  ///
  /// 各账号空间数据保留在本地（重登自动恢复，无需依赖网络），
  /// 空间之间互不可见，不会造成跨账号污染。
  Future<void> switchToGuest() => _setOwner(kGuestOwner);
}
