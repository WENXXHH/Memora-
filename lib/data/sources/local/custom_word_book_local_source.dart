import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../dto/custom_word_book_model.dart';
import '../../../core/storage/hive_initializer.dart';

/// 自建词库本地持久化数据源（doc 24 / 25）。
///
/// 使用 Hive Box<Map> 存取，key 为 wordBookId（doc 25），
/// 通过 CustomWordBook 的 toJson()/fromJson() 序列化，
/// 与 ReviewLocalDataSource 模式一致，无需额外 TypeAdapter。
@injectable
class CustomWordBookLocalSource {
  CustomWordBookLocalSource(
    @Named(HiveInitializer.customWordBooksBoxName) this._box,
  );

  final Box<Map<dynamic, dynamic>> _box;

  /// 读取全部自建词库，按创建时间升序返回（展示顺序稳定）。
  List<CustomWordBook> getAll() {
    final books = _box.values
        .whereType<Map>()
        .map((data) => CustomWordBook.fromJson(Map<String, dynamic>.from(data)))
        .toList();
    books.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return books;
  }

  /// 按 Domain ID 读取单个词库，不存在时返回 null。
  CustomWordBook? getById(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return CustomWordBook.fromJson(Map<String, dynamic>.from(data));
  }

  /// 判断词库是否存在（Registry 组合时使用，doc 30）。
  Future<bool> exists(String id) async => _box.containsKey(id);

  /// 保存（新建或更新）词库元数据。
  Future<void> save(CustomWordBook book) async {
    await _box.put(book.id, book.toJson());
  }

  /// 删除词库元数据。
  ///
  /// 注意：只删词库本身，关联的 Review 由上层 UseCase 级联处理（doc 15）。
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
