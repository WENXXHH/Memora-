/// 词库来源类型（doc 9 / 32）。
enum WordBookKind {
  /// 内置词库（CET-6 / CET-4，来自静态资源）。
  builtIn,

  /// 自建词库（`custom_<uuid>`，来自本地 Hive）。
  custom,
}

/// 词库轻量展示模型（doc 8 / 9 / 32）。
///
/// 只承载选择页展示所需的 id + name + 来源类型，不负责加载 Word。
/// 内置词库由 [BuiltInWordBooks] 静态转换而来，自建词库由
/// [CustomWordBookRepository] 动态转换而来，避免 UI 判断具体底层模型
/// 类型（doc 9）。
class WordBookSummary {
  final String id;
  final String name;
  final WordBookKind kind;

  const WordBookSummary({
    required this.id,
    required this.name,
    required this.kind,
  });
}
