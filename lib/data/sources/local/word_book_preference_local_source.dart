/// 当前词库选择的本地持久化封装（doc 9 / 8）。
///
/// 只处理 Domain ID（cet6 / cet4），不保存展示名称或资源路径。
/// 复用轻量 `settings` Box，不为一个 String 建立 Repository / Entity
/// 分层（避免过度设计，doc 9）。
library;

import 'package:hive_ce/hive_ce.dart';

/// 词库偏好本地源。
///
/// 由 Provider 手动组装（从 getIt 读取 settings Box），不参与 injectable。
class WordBookPreferenceLocalSource {
  /// settings Box 中保存当前词库的 key。
  static const String currentWordBookIdKey = 'currentWordBookId';

  final Box<String> _box;

  WordBookPreferenceLocalSource(this._box);

  /// 读取已保存的当前词库 ID；无历史选择时返回 null。
  String? readCurrentWordBookId() => _box.get(currentWordBookIdKey);

  /// 保存当前词库 ID（Domain ID，覆盖写入）。
  Future<void> saveCurrentWordBookId(String wordBookId) async {
    await _box.put(currentWordBookIdKey, wordBookId);
  }
}
