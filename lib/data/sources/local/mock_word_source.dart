import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import '../../models/word_model.dart';

/// 单词数据源抽象接口
///
/// 设计意图：
/// 1. 面向接口编程，便于后续替换为真实API数据源
/// 2. Mock数据源和Remote数据源实现同一接口
/// 3. 业务层只依赖接口，不关心数据来源
abstract class WordDataSource {
  /// 获取指定词库的单词列表
  ///
  /// [wordBookId] 词库标识
  /// 返回：单词列表
  Future<List<Word>> getWords(String wordBookId);
}

/// Mock单词数据源
///
/// 职责：从本地JSON文件读取单词数据
/// 特性：
/// - 使用 rootBundle 读取 assets/data/cet-6.json
/// - 内置重试机制（最多3次，间隔500ms）
/// - 支持词库过滤（根据 wordBookId）
@Injectable(as: WordDataSource)
class MockWordSource implements WordDataSource {
  /// 重试配置：最多3次，每次间隔500ms
  static const _retryOptions = RetryOptions(
    maxAttempts: 3,
    delayFactor: Duration(milliseconds: 500),
  );

  @override
  Future<List<Word>> getWords(String wordBookId) async {
    return _retryOptions.retry(
          () async {
        // 读取JSON文件
        final jsonString = await rootBundle.loadString('assets/data/cet-6.json');

        // 解析JSON为List<Word>
        final jsonList = json.decode(jsonString) as List<dynamic>;
        final words = jsonList.map((e) => Word.fromJson(e)).toList();

        // 根据词库ID过滤（支持多词库场景）
        return words.where((word) => word.wordBookId == wordBookId).toList();
      },
      // 重试条件：所有Exception都重试
      retryIf: (_) => true,
    );
  }
}