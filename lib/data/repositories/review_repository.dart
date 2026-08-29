import 'package:injectable/injectable.dart';
import '../dto/word_review_model.dart';
import '../sources/local/review_local_source.dart';

/// 管理用户复习记录的持久化存取。
///
/// 第三周已将内存 Map<_reviewCache> 替换为 Hive 持久化存储（ReviewLocalDataSource）。
/// 公开 API 完全不变，LearningController 和 HomeController 无需修改。
@injectable
class ReviewRepository {
  ReviewRepository(this._localDataSource);

  final ReviewLocalDataSource _localDataSource;

  /// 获取单词复习状态
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async {
    return _localDataSource.getWordReview(wordBookId, wordId);
  }

  /// 保存单词复习状态
  Future<void> saveWordReview(WordReview review) async {
    await _localDataSource.saveWordReview(review);
  }

  /// 获取今日待复习队列
  Future<List<WordReview>> getDueReviews(String wordBookId) async {
    return _localDataSource.getDueReviews(wordBookId);
  }

  /// 统计已学会单词数
  Future<int> getLearnedCount(String wordBookId) async {
    return _localDataSource.getLearnedCount(wordBookId);
  }

  /// 统计已掌握单词数（掌握度 >= 0.8）
  Future<int> getMasteredCount(String wordBookId) async {
    return _localDataSource.getMasteredCount(wordBookId);
  }

  /// 获取所有已有复习记录的单词ID集合（不限到期时间）
  /// 供 _getUnlearnedWords 过滤已学过的单词
  Future<Set<String>> getAllReviewIds(String wordBookId) async {
    return _localDataSource.getAllReviewIds(wordBookId);
  }

  /// 获取指定词库的全部复习记录（同步层使用）。
  Future<List<WordReview>> getAllReviews(String wordBookId) async {
    return _localDataSource.getAllReviews(wordBookId);
  }

  /// 批量保存复习记录（同步写入用）。
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {
    await _localDataSource.saveWordReviews(reviews);
  }

  /// 统计已有复习记录的单词总数（首次复习即计入，不限 learned 字段）
  Future<int> getReviewedCount(String wordBookId) async {
    return _localDataSource.getReviewedCount(wordBookId);
  }

  /// 删除指定词库的全部复习记录。
  ///
  /// 自建词库级联删除时调用（doc 15 / 61），避免残留孤儿 Review。
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {
    await _localDataSource.deleteReviewsByWordBookId(wordBookId);
  }

  /// 删除单个单词的复习记录。
  ///
  /// 删除自建单词时调用（doc 23），避免留下孤儿 Review。
  Future<void> deleteReview(String wordBookId, String wordId) async {
    await _localDataSource.deleteReview(wordBookId, wordId);
  }
}
