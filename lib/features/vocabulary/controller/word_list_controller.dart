import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/models/word_model.dart';
import '../../../core/dependency_injection.dart';

/// 单词列表状态类
///
/// 采用不可变模式，管理单词列表的完整状态
/// 包含原始数据、过滤后数据、搜索条件和加载状态
class WordListState {
  /// 原始单词列表（未过滤）
  final List<Word> words;

  /// 过滤后的单词列表（用于显示）
  final List<Word> filteredWords;

  /// 当前搜索关键词
  final String searchQuery;

  /// 数据加载状态
  final bool isLoading;

  /// 是否发生错误
  final bool hasError;

  /// 错误信息（发生错误时）
  final String? errorMessage;

  WordListState({
    required this.words,
    required this.filteredWords,
    required this.searchQuery,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
  });

  /// 复制当前状态并更新指定字段
  WordListState copyWith({
    List<Word>? words,
    List<Word>? filteredWords,
    String? searchQuery,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return WordListState(
      words: words ?? this.words,
      filteredWords: filteredWords ?? this.filteredWords,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 单词列表状态控制器
///
/// 继承 StateNotifier，管理单词列表的状态和业务逻辑
/// 依赖 WordRepository 获取数据，支持搜索过滤功能
class WordListController extends StateNotifier<WordListState> {
  final WordRepository _wordRepository;

  WordListController(this._wordRepository) : super(
    // 初始状态：空列表，加载中
    WordListState(
      words: [],
      filteredWords: [],
      searchQuery: '',
      isLoading: true,
      hasError: false,
    ),
  );

  /// 加载指定词库的单词列表
  ///
  /// [wordBookId] 词库标识，如 'cet6'、'cet4'
  /// 加载前重置为加载状态，加载完成后更新单词列表
  /// 异常时设置错误状态并保存错误信息
  Future<void> loadWords(String wordBookId) async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    try {
      final words = await _wordRepository.getWords(wordBookId);
      state = state.copyWith(
        words: words,
        filteredWords: words,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 根据关键词搜索过滤单词
  ///
  /// [query] 搜索关键词
  /// 支持按单词英文和中文释义进行模糊匹配
  /// 空关键词时恢复显示全部单词
  void search(String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    if (lowerQuery.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredWords: state.words,
      );
      return;
    }

    final filtered = state.words.where((word) => 
      // 匹配单词英文（忽略大小写）
      word.word.toLowerCase().contains(lowerQuery) ||
      // 匹配中文释义
      word.meaning.any((m) => m.definitions.any(
        (d) => d.contains(lowerQuery),
      ))
    ).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredWords: filtered,
    );
  }
}

/// 单词列表状态提供者（带参数）
///
/// 使用 StateNotifierProvider.family 支持传入 wordBookId 参数
/// 每个词库对应独立的控制器实例
final wordListControllerProvider = StateNotifierProvider.family<WordListController, WordListState, String>(
  (ref, wordBookId) => WordListController(
    ref.read(wordRepositoryProvider),
  ),
);

/// WordRepository 的 Riverpod Provider
///
/// 通过 getIt 获取已注册的 WordRepository 实例
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return ref.read(getItProvider).get<WordRepository>();
});

/// getIt 实例的 Riverpod Provider
///
/// 将 getIt 暴露给 Riverpod 生态系统使用
final getItProvider = Provider((ref) => getIt);