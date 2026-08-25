import 'package:injectable/injectable.dart';
import '../sources/word_data_source.dart';
import '../dto/word_model.dart';

/// 单词仓库
///
/// 职责：
/// 1. 封装单词数据源调用，面向业务层提供统一接口
/// 2. 处理单词检索与过滤
///
/// 缓存（doc 19 / 20 / 21）：
/// - 按 wordBookId 隔离（`Map<String, List<Word>>`），CET-6 与 CET-4
///   互不污染，先读 cet6 再读 cet4 不会串库（Bug 2 防御）
/// - 内置 JSON 是静态资源，缓存后只解析一次，命中直接返回
///
/// 复习状态管理已拆分至 ReviewRepository
///
/// 分层单向依赖：features → repositories → sources → Hive/JSON
@injectable
class WordRepository {
  final WordDataSource _dataSource;

  /// 按 wordBookId 隔离的单词缓存。
  final Map<String, List<Word>> _cache = {};

  WordRepository(this._dataSource);

  /// 获取指定词库的单词列表
  ///
  /// [wordBookId] 词库标识，如 'cet6'、'cet4'
  /// 返回：过滤后的单词列表
  Future<List<Word>> getWords(String wordBookId) async {
    final cached = _cache[wordBookId];
    if (cached != null) {
      return cached;
    }

    final words = await _dataSource.getWords(wordBookId);
    _cache[wordBookId] = words;
    return words;
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

  /// 清空全部词库缓存（内置 JSON 为静态资源，缓存失效体系保持简单）。
  void clearCache() {
    _cache.clear();
  }
}
