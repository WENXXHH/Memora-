import 'package:injectable/injectable.dart';

import '../dto/custom_word_record_model.dart';
import '../dto/word_model.dart';
import '../sources/local/custom_word_local_source.dart';
import '../../core/utils/id_generator.dart';

/// 自建单词仓库（doc 28 / 46）。
///
/// 只负责自建单词 CRUD；对上层统一返回现有 [Word]（doc 10），
/// 使学习 Controller 无需感知"自建"数据源。
@injectable
class CustomWordRepository {
  CustomWordRepository(this._localSource);

  final CustomWordLocalSource _localSource;

  /// 读取指定词库的全部自建单词记录。
  Future<List<CustomWordRecord>> getAll(String wordBookId) async =>
      _localSource.getAll(wordBookId);

  /// 按词库 + 单词 ID 读取单个记录。
  Future<CustomWordRecord?> getById(String wordBookId, String wordId) async =>
      _localSource.getById(wordBookId, wordId);

  /// 创建自建单词。
  ///
  /// wordId 由 [IdGenerator] 生成 uuid（doc 19，不用英文文本作 ID）。
  /// 英文/释义已由 Controller 完成 trim 与重复校验（doc 43 / 45）。
  Future<CustomWordRecord> create({
    required String wordBookId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    final now = DateTime.now();
    final record = CustomWordRecord(
      id: IdGenerator.uuidV4(),
      wordBookId: wordBookId,
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      createdAt: now,
      updatedAt: now,
    );
    await _localSource.save(record);
    return record;
  }

  /// 更新自建单词，返回更新后的记录。
  ///
  /// ID 与 createdAt 保持不变，仅更新内容与 updatedAt。
  Future<CustomWordRecord> update({
    required String wordBookId,
    required String wordId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    final existing = _localSource.getById(wordBookId, wordId);
    if (existing == null) {
      throw StateError('自建单词不存在: $wordBookId:$wordId');
    }
    final updated = existing.copyWith(
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      updatedAt: DateTime.now(),
    );
    await _localSource.save(updated);
    return updated;
  }

  /// 删除单个自建单词。
  ///
  /// 关联的 WordReview 由上层删除（doc 23），本方法只删单词本体。
  Future<void> delete(String wordBookId, String wordId) async {
    await _localSource.delete(wordBookId, wordId);
  }

  /// 删除指定词库的全部自建单词（级联删词库时调用，doc 61）。
  Future<void> deleteByWordBookId(String wordBookId) async {
    await _localSource.deleteByWordBookId(wordBookId);
  }

  /// 读取指定词库单词并统一转换为 [Word]（doc 10 / 46）。
  ///
  /// 供后续 WordRepository 按 wordBookId 路由数据源时使用，
  /// 学习模式只感知 [Word]。
  Future<List<Word>> toWords(String wordBookId) async {
    final records = _localSource.getAll(wordBookId);
    return records.map((record) => record.toWord()).toList();
  }
}
