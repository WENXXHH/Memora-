import 'package:injectable/injectable.dart';
import '../sources/word_data_source.dart';
import '../models/word_model.dart';

/// 单词仓库
///
/// 职责：
/// 1. 封装单词数据源调用，面向业务层提供统一接口
/// 2. 处理单词检索与过滤
///
/// 复习状态管理已拆分至 ReviewRepository
///
/// 分层单向依赖：features → repositories → sources → Hive/JSON
@injectable
class WordRepository {
  final WordDataSource _dataSource;

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
}
