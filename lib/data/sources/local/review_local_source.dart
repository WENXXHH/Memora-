import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/word_review_model.dart';
import '../../../core/storage/data_owner.dart';
import '../../../core/storage/hive_initializer.dart';
import '../../../core/utils/sm2_algorithm.dart';

/// 复习记录本地持久化数据源。
///
/// 使用 Hive Box<Map> 存取，利用 WordReview 的 toJson()/fromJson()
/// 完成序列化与反序列化，无需额外 TypeAdapter 代码生成。
///
/// key 带 owner 前缀（`<owner>|<wordBookId>:<wordId>`）实现账号命名空间
/// 隔离：游客与各登录账号的数据互不可见（见 core/storage/data_owner.dart）。
@injectable
class ReviewLocalDataSource {
  ReviewLocalDataSource(
    this._box,
    @Named(HiveInitializer.authBoxName) this._authBox,
  );

  final Box<Map<dynamic, dynamic>> _box;

  /// auth Box：读取当前数据所有者（guest / `user:<userId>`）。
  final Box<String> _authBox;

  /// 当前 owner 前缀（含分隔符），如 `guest|`、`user:3|`。
  String get _ownerPrefix =>
      '${_authBox.get(kDataOwnerKey) ?? kDefaultOwner}|';

  /// 统一 key 格式：`<owner>|<wordBookId>:<wordId>`
  String _buildKey(String wordBookId, String wordId) =>
      '$_ownerPrefix$wordBookId:$wordId';

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

  /// 获取指定词库的所有复习记录（仅当前 owner 空间）。
  List<WordReview> getAllReviews(String wordBookId) {
    final prefix = '$_ownerPrefix$wordBookId:';
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
      clientUpdatedAt:
          review.lastReviewDate ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// 获取今日到期复习记录。
  List<WordReview> getDueReviews(String wordBookId) {
    final all = getAllReviews(wordBookId);
    return all.where((r) => SM2Algorithm.isDueToday(r)).toList();
  }

  /// 获取"已学未到期"的复习记录（巩固练习队列）。
  ///
  /// 今日到期队列全部做完后，三个练习模式回退取这批词继续巩固
  /// （百词斩"练习随时可做"）。筛选口径：
  /// - 已学：[WordReview.lastReviewDate] 非空（至少被反馈过一次，
  ///   初始未学记录 lastReviewDate 为 null，自然排除）
  /// - 未到期：今天不需要复习（[SM2Algorithm.isDueToday] 为 false）
  ///
  /// 排序：按上次复习时间倒序（最近复习的优先），便于优先巩固刚学过的词。
  List<WordReview> getRecentLearned(String wordBookId) {
    final learned =
        getAllReviews(wordBookId)
            .where(
              (r) => r.lastReviewDate != null && !SM2Algorithm.isDueToday(r),
            )
            .toList();
    learned.sort((a, b) => b.lastReviewDate!.compareTo(a.lastReviewDate!));
    return learned;
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

  /// 删除指定词库的全部复习记录（仅当前 owner 空间）。
  ///
  /// 自建词库级联删除时调用：避免删除词库后
  /// 残留孤儿 Review。按 key 前缀批量删除，一次事务完成。
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {
    final prefix = '$_ownerPrefix$wordBookId:';
    final keys = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
    if (keys.isNotEmpty) {
      await _box.deleteAll(keys);
    }
  }

  /// 清空所有复习记录（调试用）。
  Future<void> clearAll() async => await _box.clear();
}
