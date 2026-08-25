import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/built_in_word_books.dart';
import '../../dto/word_model.dart';
import '../word_data_source.dart';

/// Mock 单词数据源实现
///
/// 从 assets 加载内置词库 JSON（doc 16 / 17）：
/// - `getWords('cet6')` → assets/data/cet-6.json
/// - `getWords('cet4')` → assets/data/cet-4.json
///
/// 资源路径由 [BuiltInWordBooks] 目录按 wordBookId 定位（doc 11），
/// 未知词库明确抛错，不静默回退 cet6（Bug 3 防御，doc 15）。
///
/// 通过 @Injectable(as: WordDataSource) 注册为 WordDataSource 的默认实现
@Injectable(as: WordDataSource)
class MockWordSource implements WordDataSource {
  @override
  Future<List<Word>> getWords(String wordBookId) async {
    try {
      final config = BuiltInWordBooks.findById(wordBookId);
      if (config == null) {
        throw Exception('未知词库: $wordBookId');
      }

      final jsonString = await rootBundle.loadString(config.assetPath);
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final words = jsonList.map((e) => Word.fromJson(e)).toList();

      // 防御：asset 按 wordBookId 定位后，再按字段过滤一次，
      // 防止数据文件内部 wordBookId 与请求不一致时发生串库（Bug 1）。
      return words.where((word) => word.wordBookId == wordBookId).toList();
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }
}
