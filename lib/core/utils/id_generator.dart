/// 客户端 ID 生成器。
///
/// 自建词库 Domain ID 采用 `custom_<uuid>`（doc 5 / 6）：
/// - ID 一旦创建永不因重命名而变化，故不能使用英文文本或时间戳
/// - 未来云同步需要稳定的客户端随机 UUID，而非依赖本地时间
/// 项目当前未引入 uuid 依赖，自建轻量 v4 风格 UUID 即可满足需求。
library;

import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random.secure();

  /// 生成 v4 风格 UUID 字符串（格式 xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx）。
  ///
  /// 使用 [Random.secure] 保证跨设备随机性，避免碰撞。
  static String uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // v4 版本号与 RFC 4122 variant 位
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// 自建词库 Domain ID：`custom_<uuid>`（doc 5）。
  static String customWordBookId() => 'custom_${uuidV4()}';
}
