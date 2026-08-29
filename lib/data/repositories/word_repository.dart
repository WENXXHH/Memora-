import 'package:injectable/injectable.dart';

import '../../core/utils/built_in_word_books.dart';
import '../sources/word_data_source.dart';
import '../dto/custom_word_record_model.dart';
import '../dto/word_model.dart';
import 'custom_word_book_repository.dart';
import 'custom_word_repository.dart';

/// 单词仓库（doc 46 / 48 / 49 / 30）。
///
/// 职责：
/// 1. 按 wordBookId 路由数据源：内置 → Asset，自建 → Hive，
///    未知 → 明确失败（doc 30 / 46），对外统一返回 [Word]
/// 2. 内置词库保持缓存；自建词库不缓存（doc 48 / 49），
///    保证新增 / 编辑 / 删除单词后学习页读到最新数据
///
/// 缓存（doc 19 / 20 / 21）：
/// - 仅作用于内置词库，按 wordBookId 隔离（`Map<String, List<Word>>`），
///   CET-6 与 CET-4 互不污染（Bug 2 防御）
/// - 内置 JSON 是静态资源，缓存后只解析一次，命中直接返回
///
/// 复习状态管理已拆分至 ReviewRepository
///
/// 分层单向依赖：features → repositories → sources → Hive/JSON
@injectable
class WordRepository {
  WordRepository(
    this._dataSource,
    this._customWordBookRepository,
    this._customWordRepository,
  );

  final WordDataSource _dataSource;
  final CustomWordBookRepository _customWordBookRepository;
  final CustomWordRepository _customWordRepository;

  /// 按 wordBookId 隔离的内置词库单词缓存。
  final Map<String, List<Word>> _cache = {};

  /// 获取指定词库的单词列表（doc 46 / 49）。
  ///
  /// - 内置词库：读 Asset，命中缓存直接返回
  /// - 自建词库：读 Hive（不缓存，doc 49）
  /// - 未知词库：抛 [ArgumentError]，不静默 fallback（doc 30）
  Future<List<Word>> getWords(String wordBookId) async {
    if (BuiltInWordBooks.contains(wordBookId)) {
      final cached = _cache[wordBookId];
      if (cached != null) {
        return cached;
      }
      final words = await _dataSource.getWords(wordBookId);
      _cache[wordBookId] = words;
      return words;
    }

    // 自建词库：Hive 动态数据，每次读取保证最新（doc 48 / 49）
    if (await _customWordBookRepository.exists(wordBookId)) {
      return _customWordRepository.toWords(wordBookId);
    }

    throw ArgumentError('未知词库: $wordBookId');
  }

  /// 获取单词总数
  Future<int> getWordCount(String wordBookId) async {
    final words = await getWords(wordBookId);
    return words.length;
  }

  /// 根据ID查找单词
  Future<Word?> getWordById(String wordBookId, String wordId) async {
    if (BuiltInWordBooks.contains(wordBookId)) {
      final words = await getWords(wordBookId);
      return words.where((w) => w.id == wordId).firstOrNull;
    }

    if (await _customWordBookRepository.exists(wordBookId)) {
      final record = await _customWordRepository.getById(wordBookId, wordId);
      return record?.toWord();
    }

    throw ArgumentError('未知词库: $wordBookId');
  }

  /// 清空内置词库缓存（内置 JSON 为静态资源，缓存失效体系保持简单）。
  void clearCache() {
    _cache.clear();
  }
}
