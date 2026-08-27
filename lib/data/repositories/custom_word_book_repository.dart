import 'package:injectable/injectable.dart';

import '../dto/custom_word_book_model.dart';
import '../sources/local/custom_word_book_local_source.dart';
import '../../core/utils/id_generator.dart';

/// 自建词库仓库（doc 28）。
///
/// 只负责词库元数据 CRUD，自建单词归 [CustomWordRepository]
/// （后续分支），学习用 Word 统一由 [WordRepository] 路由读取。
/// 分层单向依赖：features → repositories → sources → Hive。
@injectable
class CustomWordBookRepository {
  CustomWordBookRepository(this._localSource);

  final CustomWordBookLocalSource _localSource;

  /// 读取全部自建词库。
  Future<List<CustomWordBook>> getAll() async => _localSource.getAll();

  /// 按 Domain ID 读取单个词库，不存在时返回 null。
  Future<CustomWordBook?> getById(String id) async => _localSource.getById(id);

  /// 判断词库是否存在（doc 30，Registry 组合用）。
  Future<bool> exists(String id) => _localSource.exists(id);

  /// 创建自建词库。
  ///
  /// ID 由 [IdGenerator] 生成（doc 5：`custom_<uuid>`，永不因重命名变化），
  /// 名称在调用前已由 Controller 完成唯一性校验（doc 13 / 14）。
  Future<CustomWordBook> create({required String name}) async {
    final now = DateTime.now();
    final book = CustomWordBook(
      id: IdGenerator.customWordBookId(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    await _localSource.save(book);
    return book;
  }

  /// 重命名词库，返回更新后的词库。
  ///
  /// ID 保持不变（doc 5），仅更新 name 与 updatedAt。
  Future<CustomWordBook> rename({
    required String id,
    required String newName,
  }) async {
    final existing = _localSource.getById(id);
    if (existing == null) {
      throw StateError('词库不存在: $id');
    }
    final updated = existing.copyWith(name: newName, updatedAt: DateTime.now());
    await _localSource.save(updated);
    return updated;
  }

  /// 删除词库元数据。
  ///
  /// 关联数据（单词 / Review / 当前选择）由上层 UseCase 协调（doc 15 / 61）。
  Future<void> delete(String id) async => _localSource.delete(id);
}
