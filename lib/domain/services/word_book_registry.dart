import '../../core/utils/built_in_word_books.dart';
import '../../data/repositories/custom_word_book_repository.dart';
import 'word_book_summary.dart';

/// 统一词库注册表（doc 31 / 32 / 33 / 34 / 67）。
///
/// 职责只有三个：`getAll()` / `findById(id)` / `exists(id)`。
/// 内部组合两路来源，对外屏蔽"内置 / 自建"的差异：
/// - 内置词库：静态数据（[BuiltInWordBooks]，同步）
/// - 自建词库：Hive 动态数据（[CustomWordBookRepository]，异步）
///
/// 这样 [CurrentWordBookController]、[WordBookSelectionPage]、
/// [WordRepository] 都只需面向 Registry 一套判断，不必分别维护
/// 合法词库集合（doc 31 / 67）。
class WordBookRegistry {
  WordBookRegistry(this._customWordBookRepository);

  final CustomWordBookRepository _customWordBookRepository;

  /// 全部合法词库（内置在前，保持默认行为不变）。
  ///
  /// 返回统一展示模型 [WordBookSummary]，调用方无需感知底层类型。
  Future<List<WordBookSummary>> getAll() async {
    final builtIn = [
      for (final config in BuiltInWordBooks.all)
        WordBookSummary(
          id: config.id,
          name: config.name,
          kind: WordBookKind.builtIn,
        ),
    ];
    final customs = [
      for (final book in await _customWordBookRepository.getAll())
        WordBookSummary(
          id: book.id,
          name: book.name,
          kind: WordBookKind.custom,
        ),
    ];
    return [...builtIn, ...customs];
  }

  /// 按 Domain ID 查找词库；未知 ID 返回 null（不 fallback）。
  Future<WordBookSummary?> findById(String id) async {
    final config = BuiltInWordBooks.findById(id);
    if (config != null) {
      return WordBookSummary(
        id: config.id,
        name: config.name,
        kind: WordBookKind.builtIn,
      );
    }
    final custom = await _customWordBookRepository.getById(id);
    if (custom != null) {
      return WordBookSummary(
        id: custom.id,
        name: custom.name,
        kind: WordBookKind.custom,
      );
    }
    return null;
  }

  /// 是否为已注册的合法词库（内置或自建，doc 33 / 67）。
  Future<bool> exists(String id) async {
    if (BuiltInWordBooks.contains(id)) return true;
    return _customWordBookRepository.exists(id);
  }
}
