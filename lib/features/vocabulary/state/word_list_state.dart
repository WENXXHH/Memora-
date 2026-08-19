import '../../../data/dto/word_model.dart';

/// 词库列表状态，包含原始词库、过滤结果与搜索/加载/错误状态
class WordListState {
  final List<Word> words;
  final List<Word> filteredWords;
  final String searchQuery;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  WordListState({
    required this.words,
    required this.filteredWords,
    required this.searchQuery,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
  });

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
