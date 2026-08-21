import '../dto/word_model.dart';

/// 单词数据源抽象接口
///
/// 定义单词数据获取的标准契约，支持不同数据源实现（Mock、API、Hive等）
abstract class WordDataSource {
  /// 获取指定词库的单词列表
  ///
  /// [wordBookId] 词库标识，如 'cet6'、'cet4'
  Future<List<Word>> getWords(String wordBookId);
}
