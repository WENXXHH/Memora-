import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../dto/word_review_model.dart';
import '../../../core/utils/sm2_algorithm.dart';

/// 复习记录本地持久化数据源。
///
/// 使用 Hive Box<Map> 存取，利用 WordReview 的 toJson()/fromJson()
/// 完成序列化与反序列化，无需额外 TypeAdapter 代码生成。
@injectable
class ReviewLocalDataSource {
  ReviewLocalDataSource(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// 统一 key 格式：wordBookId:wordId
  String _buildKey(String wordBookId, String wordId) => '$wordBookId:$wordId';

  // ---------------------------------------------------------------------------
  // 单条读写
  // ---------------------------------------------------------------------------

  /// 读取单条复习记录，不存在时返回 null。
  WordReview? getWordReview(String wordBookId, String wordId) {
    final key = _buildKey(wordBookId, wordId);
    final data = _box.get(key);
    if (data == null) return null;
    return _withClientUpdatedAtFallback(
      WordReview.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  /// 保存或更新复习记录。
  Future<void> saveWordReview(WordReview review) async {
    final key = _buildKey(review.wordBookId, review.wordId);
    await _box.put(key, review.toJson());
  }

  /// 批量保存复习记录（同步写入用）。
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {
    for (final review in reviews) {
      final key = _buildKey(review.wordBookId, review.wordId);
      await _box.put(key, review.toJson());
    }
  }

  // ---------------------------------------------------------------------------
  // 批量查询
  // ---------------------------------------------------------------------------

  /// 获取指定词库的所有复习记录。
  List<WordReview> getAllReviews(String wordBookId) {
    final prefix = '$wordBookId:';
    return _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .map((key) {
          final data = _box.get(key);
          return _withClientUpdatedAtFallback(
            WordReview.fromJson(Map<String, dynamic>.from(data!)),
          );
        })
        .toList();
  }

  /// 旧 Hive 数据缺少 clientUpdatedAt 时 fallback 到 lastReviewDate 或 epoch。
  /// epoch（1970 UTC）在同步时必然被远端覆盖，安全。
  WordReview _withClientUpdatedAtFallback(WordReview review) {
    if (review.clientUpdatedAt != null) return review;
    return review.copyWith(
      clientUpdatedAt: review.lastReviewDate
          ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// 获取今日到期复习记录。
  List<WordReview> getDueReviews(String wordBookId) {
    final all = getAllReviews(wordBookId);
    return all.where((r) => SM2Algorithm.isDueToday(r)).toList();
  }

  /// 获取所有已有复习记录的 wordId 集合（用于新词过滤）。
  Set<String> getAllReviewIds(String wordBookId) {
    final all = getAllReviews(wordBookId);
    return all.map((r) => r.wordId).toSet();
  }

  // ---------------------------------------------------------------------------
  // 统计
  // ---------------------------------------------------------------------------

  /// 已有复习记录总数（已学数量）。
  int getReviewedCount(String wordBookId) => getAllReviews(wordBookId).length;

  /// 已学会数量（learned == true）。
  int getLearnedCount(String wordBookId) =>
      getAllReviews(wordBookId).where((r) => r.learned).length;

  /// 已掌握数量（mastery >= 0.8）。
  int getMasteredCount(String wordBookId) =>
      getAllReviews(wordBookId).where((r) => r.mastery >= 0.8).length;

  // ---------------------------------------------------------------------------
  // 维护
  // ---------------------------------------------------------------------------

  /// 删除指定复习记录。
  Future<void> deleteReview(String wordBookId, String wordId) async {
    final key = _buildKey(wordBookId, wordId);
    await _box.delete(key);
  }

  /// 清空所有复习记录（调试用）。
  Future<void> clearAll() async => await _box.clear();
}
