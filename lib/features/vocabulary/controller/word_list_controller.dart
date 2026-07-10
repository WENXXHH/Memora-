import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/word_repository.dart';
import '../state/word_list_state.dart';
import '../../../providers/repository_providers.dart';

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
