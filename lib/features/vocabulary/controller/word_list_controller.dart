import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/word_repository.dart';
import '../../../data/models/word_model.dart';
import '../../../core/dependency_injection.dart';

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

class WordListController extends StateNotifier<WordListState> {
  final WordRepository _wordRepository;

  WordListController(this._wordRepository) : super(
    WordListState(
      words: [],
      filteredWords: [],
      searchQuery: '',
      isLoading: true,
      hasError: false,
    ),
  );

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
      word.word.toLowerCase().contains(lowerQuery) ||
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

final wordListControllerProvider = StateNotifierProvider.family<WordListController, WordListState, String>(
  (ref, wordBookId) => WordListController(
    ref.read(wordRepositoryProvider),
  ),
);

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return ref.read(getItProvider).get<WordRepository>();
});

final getItProvider = Provider((ref) => getIt);