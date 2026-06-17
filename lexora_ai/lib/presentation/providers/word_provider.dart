import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/word_entity.dart';
import '../../services/dictionary_service.dart';

final dictionaryServiceProvider = Provider((ref) => DictionaryService());

// Word search state
class WordSearchState {
  final String query;
  final WordEntity? result;
  final bool isLoading;
  final String? error;
  final List<String> suggestions;
  final List<WordEntity> recentWords;

  const WordSearchState({
    this.query = '',
    this.result,
    this.isLoading = false,
    this.error,
    this.suggestions = const [],
    this.recentWords = const [],
  });

  WordSearchState copyWith({
    String? query,
    WordEntity? result,
    bool? isLoading,
    String? error,
    List<String>? suggestions,
    List<WordEntity>? recentWords,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return WordSearchState(
      query: query ?? this.query,
      result: clearResult ? null : (result ?? this.result),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      suggestions: suggestions ?? this.suggestions,
      recentWords: recentWords ?? this.recentWords,
    );
  }
}

class WordSearchNotifier extends StateNotifier<WordSearchState> {
  WordSearchNotifier(this._dictionaryService) : super(const WordSearchState());

  final DictionaryService _dictionaryService;

  Future<void> search(String word) async {
    if (word.trim().isEmpty) return;

    state = state.copyWith(
      query: word,
      isLoading: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final result = await _dictionaryService.fetchWord(word.trim().toLowerCase());
      if (result == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Word not found. Try a different spelling.',
        );
      } else {
        final recent = [result, ...state.recentWords.where((w) => w.word != result.word)]
            .take(20)
            .toList();
        state = state.copyWith(
          result: result,
          isLoading: false,
          recentWords: recent,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  void clear() {
    state = state.copyWith(query: '', clearResult: true, clearError: true);
  }
}

final wordSearchProvider = StateNotifierProvider<WordSearchNotifier, WordSearchState>((ref) {
  return WordSearchNotifier(ref.watch(dictionaryServiceProvider));
});

// Word of the day
final wordOfTheDayProvider = FutureProvider<WordEntity?>((ref) async {
  final service = ref.watch(dictionaryServiceProvider);
  return service.getWordOfTheDay();
});

// Favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<WordEntity>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<WordEntity>> {
  FavoritesNotifier() : super([]);

  void toggle(WordEntity word) {
    if (state.any((w) => w.id == word.id)) {
      state = state.where((w) => w.id != word.id).toList();
    } else {
      state = [word.copyWith(isFavorite: true), ...state];
    }
  }

  bool isFavorite(String wordId) => state.any((w) => w.id == wordId);
}
