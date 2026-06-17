import 'package:dio/dio.dart';
import '../domain/entities/word_entity.dart';
import '../core/constants/app_constants.dart';

class DictionaryService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Fetch from Free Dictionary API
  Future<WordEntity?> fetchWord(String word) async {
    try {
      final response = await _dio.get(
        '${AppConstants.dictionaryApiUrl}/en/$word',
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data[0] as Map<String, dynamic>;
        return _parseWordEntity(data, word);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    return null;
  }

  // Search words (autocomplete)
  Future<List<String>> searchWords(String query) async {
    // In production, this would call a proper search API
    // For now, returns filtered results from local index
    return [];
  }

  // Get word of the day
  Future<WordEntity?> getWordOfTheDay() async {
    const words = [
      'ephemeral', 'serendipity', 'eloquent', 'resilience', 'ponder',
      'meticulous', 'ambiguous', 'profound', 'tenacious', 'lucid',
    ];
    final dayIndex = DateTime.now().day % words.length;
    return fetchWord(words[dayIndex]);
  }

  // Get IELTS word list (would be from local DB in production)
  Future<List<String>> getIeltsWords({String band = 'B2'}) async {
    return [];
  }

  WordEntity _parseWordEntity(Map<String, dynamic> data, String word) {
    final meanings = <MeaningEntity>[];
    final allSynonyms = <String>{};
    final allAntonyms = <String>{};

    for (final m in (data['meanings'] as List? ?? [])) {
      final definitions = <DefinitionEntity>[];
      for (final d in (m['definitions'] as List? ?? [])) {
        definitions.add(DefinitionEntity(
          definition: d['definition'] ?? '',
          example: d['example'],
          examples: d['example'] != null ? [d['example']] : [],
        ));
        allSynonyms.addAll(List<String>.from(d['synonyms'] ?? []));
        allAntonyms.addAll(List<String>.from(d['antonyms'] ?? []));
      }
      allSynonyms.addAll(List<String>.from(m['synonyms'] ?? []));
      allAntonyms.addAll(List<String>.from(m['antonyms'] ?? []));

      meanings.add(MeaningEntity(
        partOfSpeech: m['partOfSpeech'] ?? '',
        definitions: definitions,
        synonyms: List<String>.from(m['synonyms'] ?? []),
        antonyms: List<String>.from(m['antonyms'] ?? []),
      ));
    }

    // Extract phonetics
    String? phonetic = data['phonetic'];
    String? audioUs;
    String? audioUk;

    for (final p in (data['phonetics'] as List? ?? [])) {
      final audio = p['audio'] as String?;
      if (audio != null && audio.isNotEmpty) {
        if (audio.contains('us')) {
          audioUs = audio;
        } else if (audio.contains('uk')) {
          audioUk = audio;
        } else if (audioUs == null) {
          audioUs = audio;
        }
      }
    }

    return WordEntity(
      id: word.toLowerCase(),
      word: word,
      phonetic: phonetic,
      audioUs: audioUs,
      audioUk: audioUk,
      meanings: meanings,
      synonyms: allSynonyms.take(10).toList(),
      antonyms: allAntonyms.take(10).toList(),
      addedAt: DateTime.now(),
    );
  }
}
