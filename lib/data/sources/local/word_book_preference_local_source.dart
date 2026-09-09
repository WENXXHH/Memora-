import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../../core/storage/hive_initializer.dart';

/// 词库偏好本地源。
///
/// 复用轻量 `settings` Box，仅读写当前词库 ID 一个 String，
/// 不为单个 String 建立 Repository/Entity 分层（避免过度设计）。
///
/// 依赖（settings Box）经 getIt @Named 注入，与同层其他 LocalSource
/// （CustomWordBookLocalSource 等）的注册方式保持一致。
@injectable
class WordBookPreferenceLocalSource {
  /// settings Box 中保存当前词库的 key。
  static const String currentWordBookIdKey = 'currentWordBookId';

  final Box<String> _box;

  WordBookPreferenceLocalSource(
    @Named(HiveInitializer.settingsBoxName) this._box,
  );

  /// 读取已保存的当前词库 ID；无历史选择时返回 null。
  String? readCurrentWordBookId() => _box.get(currentWordBookIdKey);

  /// 保存当前词库 ID（Domain ID，覆盖写入）。
  Future<void> saveCurrentWordBookId(String wordBookId) async {
    await _box.put(currentWordBookIdKey, wordBookId);
  }
}
