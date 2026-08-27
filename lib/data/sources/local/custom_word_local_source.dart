import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../dto/custom_word_record_model.dart';
import '../../../core/storage/hive_initializer.dart';

/// 自建单词本地持久化数据源（doc 24 / 26）。
///
/// 全部自建单词存同一个 Hive Box，key 为联合 Key `$wordBookId:$wordId`（doc 26），
/// 与词库元数据（custom_word_books Box）分离。
/// 沿用 Box<Map> + JSON 序列化，无需 TypeAdapter。
@injectable
class CustomWordLocalSource {
  CustomWordLocalSource(
    @Named(HiveInitializer.customWordsBoxName) this._box,
  );

  final Box<Map<dynamic, dynamic>> _box;

  /// 构造联合 Key：`$wordBookId:$wordId`（doc 26）。
  String _buildKey(String wordBookId, String wordId) => '$wordBookId:$wordId';

  /// 读取指定词库的全部自建单词，按创建时间升序。
  List<CustomWordRecord> getAll(String wordBookId) {
    final prefix = '$wordBookId:';
    final records = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .map((key) {
          final data = _box.get(key);
          return CustomWordRecord.fromJson(Map<String, dynamic>.from(data!));
        })
        .toList();
    records.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return records;
  }

  /// 按联合 Key 读取单个单词，不存在返回 null。
  CustomWordRecord? getById(String wordBookId, String wordId) {
    final data = _box.get(_buildKey(wordBookId, wordId));
    if (data == null) return null;
    return CustomWordRecord.fromJson(Map<String, dynamic>.from(data));
  }

  /// 判断单词是否存在。
  Future<bool> exists(String wordBookId, String wordId) async =>
      _box.containsKey(_buildKey(wordBookId, wordId));

  /// 保存（新增或更新）自建单词。
  Future<void> save(CustomWordRecord record) async {
    await _box.put(_buildKey(record.wordBookId, record.id), record.toJson());
  }

  /// 删除单个自建单词。
  ///
  /// 只删单词本体，关联的 WordReview 由上层 UseCase / Controller
  /// 级联删除（doc 23）。
  Future<void> delete(String wordBookId, String wordId) async {
    await _box.delete(_buildKey(wordBookId, wordId));
  }

  /// 删除指定词库的全部自建单词（级联删词库时调用，doc 61）。
  Future<void> deleteByWordBookId(String wordBookId) async {
    final prefix = '$wordBookId:';
    final keys = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
    if (keys.isNotEmpty) {
      await _box.deleteAll(keys);
    }
  }
}
