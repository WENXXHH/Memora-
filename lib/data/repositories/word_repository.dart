import 'package:injectable/injectable.dart';
import '../models/word_review_model.dart';
import '../sources/local/mock_word_source.dart';
import '../models/word_model.dart';
import '../../utils/sm2_algorithm.dart';

/// 单词仓库
///
/// 职责：
/// 1. 封装数据源调用，面向业务层提供统一接口
/// 2. 处理业务逻辑（如词库过滤、数据转换）
/// 3. 实现数据与业务的解耦
///
/// 分层单向依赖：features → repositories → sources → Hive/JSON
@injectable
class WordRepository {
  final WordDataSource _dataSource;

  // 内存缓存：存储单词复习状态（第3周替换为 Hive）
  final Map<String, WordReview> _reviewCache = {};

  WordRepository(this._dataSource);

  /// 获取指定词库的单词列表
  ///
  /// [wordBookId] 词库标识，如 'cet6'、'cet4'
  /// 返回：过滤后的单词列表
  Future<List<Word>> getWords(String wordBookId) {
    return _dataSource.getWords(wordBookId);
  }

  /// 获取单词总数
  Future<int> getWordCount(String wordBookId) async {
    final words = await getWords(wordBookId);
    return words.length;
  }

  /// 根据ID查找单词
  Future<Word?> getWordById(String wordBookId, String wordId) async {
    final words = await getWords(wordBookId);
    return words.where((w) => w.id == wordId).firstOrNull;
  }

  // ===== SM-2 相关方法 =====

  /// 获取单词复习状态
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async {
    final key = '$wordBookId:$wordId';
    return _reviewCache[key];
  }

  /// 保存单词复习状态（控制台打印 SM-2 更新结果）
  Future<void> saveWordReview(WordReview review) async {
    final key = '${review.wordBookId}:${review.wordId}';
    _reviewCache[key] = review;
    print('[SM-2] Saved: ${review.wordId} -> interval=${review.interval} days, '
        'EF=${review.easinessFactor.toStringAsFixed(2)}');
  }

  /// 获取今日待复习队列
  Future<List<WordReview>> getDueReviews(String wordBookId) async {
    return _reviewCache.values
        .where((r) => r.wordBookId == wordBookId && SM2Algorithm.isDueToday(r))
        .toList();
  }

  /// 统计已学会单词数
  Future<int> getLearnedCount(String wordBookId) async {
    return _reviewCache.values
        .where((r) => r.wordBookId == wordBookId && r.learned)
        .length;
  }

  /// 统计已掌握单词数（掌握度 >= 0.8）
  Future<int> getMasteredCount(String wordBookId) async {
    return _reviewCache.values
        .where((r) => r.wordBookId == wordBookId && r.mastery >= 0.8)
        .length;
  }

  /// 获取所有已有复习记录的单词ID集合（不限到期时间）
  /// 供 _getUnlearnedWords 过滤已学过的单词
  Future<Set<String>> getAllReviewIds(String wordBookId) async {
    return _reviewCache.values
        .where((r) => r.wordBookId == wordBookId)
        .map((r) => r.wordId)
        .toSet();
  }

  /// 统计已有复习记录的单词总数（首次复习即计入，不限 learned 字段）
  Future<int> getReviewedCount(String wordBookId) async {
    return _reviewCache.values
        .where((r) => r.wordBookId == wordBookId)
        .length;
  }
}
