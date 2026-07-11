import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../models/word_model.dart';

/// 单词数据源抽象接口
///
/// 定义单词数据获取的标准契约，支持不同数据源实现（Mock、API、Hive等）
abstract class WordDataSource {
  /// 获取指定词库的单词列表
  ///
  /// [wordBookId] 词库标识，如 'cet6'、'cet4'
  Future<List<Word>> getWords(String wordBookId);
}

/// Mock单词数据源实现
///
/// 从 assets/data/cet-6.json 加载模拟数据，用于开发和测试阶段
/// 通过 @Injectable(as: WordDataSource) 注册为 WordDataSource 的默认实现
@Injectable(as: WordDataSource)
class MockWordSource implements WordDataSource {
  @override
  Future<List<Word>> getWords(String wordBookId) async {
    try {
      // 从本地资源文件加载 JSON 数据
      final jsonString = await rootBundle.loadString('assets/data/cet-6.json');
      // 解析 JSON 数组
      final jsonList = json.decode(jsonString) as List<dynamic>;
      // 转换为 Word 对象列表
      final words = jsonList.map((e) => Word.fromJson(e)).toList();
      // 根据词库ID过滤单词
      return words.where((word) => word.wordBookId == wordBookId).toList();
    } catch (e) {
      // 统一异常处理，向上抛出包含详细信息的异常
      throw Exception('Failed to load words: $e');
    }
  }
}
