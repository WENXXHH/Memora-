/// 内置词库目录（doc 11 / 12 / 13 / 14 / 15）。
///
/// 只描述"项目有哪些内置词库"，不保存"用户当前选择"（当前词库状态
/// 属于 feature/词库切换 分支）。资源路径、Domain ID、展示名称三者分离：
/// - id：Domain ID（如 cet6 / cet4），业务代码只接触它
/// - name：展示名称（如 CET-6 / CET-4）
/// - assetPath：静态资源路径（如 assets/data/cet-6.json）
///
/// 未知词库 [findById] 返回 null，严禁回退到 cet6（Bug 3 防御），
/// 宁可暴露问题也不要静默读取错误词库。
library;

/// 单个内置词库的元数据配置。
class BuiltInWordBookConfig {
  final String id;
  final String name;
  final String assetPath;

  const BuiltInWordBookConfig({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

/// 内置词库静态目录。
abstract final class BuiltInWordBooks {
  static const cet6 = BuiltInWordBookConfig(
    id: 'cet6',
    name: 'CET-6',
    assetPath: 'assets/data/cet-6.json',
  );

  static const cet4 = BuiltInWordBookConfig(
    id: 'cet4',
    name: 'CET-4',
    assetPath: 'assets/data/cet-4.json',
  );

  /// 全部内置词库（保持 cet6 在前，保证默认行为不变）。
  static const List<BuiltInWordBookConfig> all = [cet6, cet4];

  /// 按 Domain ID 查找内置词库；未知 ID 返回 null（不 fallback）。
  static BuiltInWordBookConfig? findById(String id) {
    for (final config in all) {
      if (config.id == id) return config;
    }
    return null;
  }

  /// 是否为已注册的内置词库 ID。
  static bool contains(String id) => findById(id) != null;
}
