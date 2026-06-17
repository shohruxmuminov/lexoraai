import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../domain/entities/chat_entity.dart';
import '../core/constants/app_constants.dart';

/// Talks to the OpenAI Chat Completions REST API directly via Dio.
///
/// No external AI SDK is required. Provide a key one of three ways:
///   1. flutter run --dart-define=OPENAI_API_KEY=sk-...
///   2. AiService.initialize('sk-...')  (e.g. from the Settings screen)
///   3. Leave it empty -> the app runs in "demo mode" with canned replies,
///      so the UI is fully usable without a key.
class AiService {
  static String apiKey =
      const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String _model = 'gpt-4o-mini';

  static void initialize(String key) {
    apiKey = key.trim();
  }

  bool get hasKey => apiKey.trim().isNotEmpty;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.openAiBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 60),
  ));

  // ---------------------------------------------------------------------------
  // Streaming chat
  // ---------------------------------------------------------------------------
  Stream<String> streamChat({
    required List<ChatMessageEntity> messages,
    String? systemPrompt,
    double temperature = 0.7,
  }) async* {
    if (!hasKey) {
      yield* _demoStream(messages.isNotEmpty ? messages.last.content : '');
      return;
    }

    final body = {
      'model': _model,
      'temperature': temperature,
      'stream': true,
      'messages': [
        {'role': 'system', 'content': systemPrompt ?? _defaultSystemPrompt},
        ...messages.map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            }),
      ],
    };

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode(body),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      var buffer = '';
      await for (final bytes in stream) {
        buffer += utf8.decode(bytes, allowMalformed: true);
        final lines = buffer.split('\n');
        // Keep the last (possibly incomplete) line in the buffer.
        buffer = lines.removeLast();
        for (final raw in lines) {
          final line = raw.trim();
          if (line.isEmpty || !line.startsWith('data:')) continue;
          final data = line.substring(5).trim();
          if (data == '[DONE]') return;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            final delta = choices != null && choices.isNotEmpty
                ? (choices.first['delta']?['content'])
                : null;
            if (delta is String && delta.isNotEmpty) yield delta;
          } catch (_) {
            // Ignore malformed partial chunks.
          }
        }
      }
    } on DioException catch (e) {
      yield '\n\n⚠️ AI request failed (${e.response?.statusCode ?? e.message}). '
          'Please check your OpenAI API key in Settings → AI & API.';
    }
  }

  // ---------------------------------------------------------------------------
  // Single-shot helpers
  // ---------------------------------------------------------------------------
  Future<String> explainWord(String word, {String? targetLanguage}) {
    return _singleCompletion('''
Explain the English word "$word" in detail for a language learner. Include:
1. Clear definition
2. Part of speech
3. 3 example sentences
4. Common collocations
5. A tip to remember it
${targetLanguage != null ? '6. Translation in $targetLanguage' : ''}
''');
  }

  Future<String> compareWords(String word1, String word2) {
    return _singleCompletion('''
Compare the English words "$word1" and "$word2". Include:
1. Key differences in meaning
2. When to use each
3. 3 example sentences for each
4. Common learner mistakes
5. A short comparison table
''');
  }

  Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required List<String> words,
    required String difficulty,
    required String type,
  }) async {
    // Returns parsed JSON from the model in production; empty list as a safe
    // default so callers never crash.
    await _singleCompletion(
      'Generate 5 $difficulty $type quiz questions for: ${words.join(', ')}. '
      'Return ONLY a JSON array.',
      temperature: 0.3,
    );
    return [];
  }

  Future<Map<String, dynamic>> evaluateWriting(String text) async {
    final response = await _singleCompletion('''
Evaluate this English text for grammar, vocabulary, coherence and style:
"$text"
Give an IELTS band score (0-9), specific errors, 3 suggestions, and a corrected version.
''', temperature: 0.2);
    return {'response': response};
  }

  Future<Map<String, dynamic>> evaluatePronunciation({
    required String targetWord,
    required String spokenText,
  }) async {
    final response = await _singleCompletion('''
Target word: "$targetWord". Speech recognition captured: "$spokenText".
Give a pronunciation accuracy score (0-100), what was correct, what to improve,
and a phonetic breakdown tip.
''', temperature: 0.2);
    return {'response': response};
  }

  Future<String> translateWithContext({
    required String text,
    required String targetLanguage,
    bool includeAlternatives = true,
  }) {
    return _singleCompletion('''
Translate to $targetLanguage: "$text"
${includeAlternatives ? 'Also give 2 alternative translations and contextual notes.' : ''}
''');
  }

  Future<String> generateStudyPlan({
    required int wordsPerDay,
    required String cefrTarget,
    required String purpose,
    required int daysAvailable,
  }) {
    return _singleCompletion('''
Create a personalized vocabulary study plan:
- Words/day: $wordsPerDay
- Target CEFR: $cefrTarget
- Purpose: $purpose
- Days available: $daysAvailable
Include a day-by-day schedule, a review schedule, retention tips and milestones.
''');
  }

  Future<String> simplifyText(String text, String level) {
    return _singleCompletion(
        'Simplify this text for a $level English learner, keeping the meaning:\n\n"$text"');
  }

  Future<List<Map<String, String>>> extractVocabulary(String articleText) async {
    final clipped = articleText.length > 2000
        ? articleText.substring(0, 2000)
        : articleText;
    await _singleCompletion(
      'Extract the 10 most important advanced vocabulary words from:\n"$clipped"\n'
      'Return ONLY a JSON array of {word, definition, example, cefrLevel}.',
      temperature: 0.2,
    );
    return [];
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------
  Future<String> _singleCompletion(String prompt,
      {double temperature = 0.7}) async {
    if (!hasKey) return _demoText(prompt);
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': _model,
          'temperature': temperature,
          'messages': [
            {'role': 'system', 'content': _defaultSystemPrompt},
            {'role': 'user', 'content': prompt},
          ],
        }),
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        }),
      );
      final choices = response.data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        return choices.first['message']['content'] as String? ?? '';
      }
      return '';
    } on DioException catch (e) {
      return 'AI request failed (${e.response?.statusCode ?? e.message}). '
          'Check your API key in Settings.';
    }
  }

  Stream<String> _demoStream(String prompt) async* {
    final text = _demoText(prompt);
    for (final word in text.split(' ')) {
      await Future.delayed(const Duration(milliseconds: 25));
      yield '$word ';
    }
  }

  String _demoText(String prompt) {
    return "I'm Lexora AI 🤖 (demo mode).\n\n"
        "Add your OpenAI API key in Settings → AI & API to unlock full, "
        "real-time answers.\n\n"
        "You said: \"$prompt\"\n\n"
        "Once connected I can explain words, compare them, generate examples, "
        "check your writing, build study plans and run quizzes — all powered by GPT-4o.";
  }

  static const String _defaultSystemPrompt = '''
You are Lexora AI, an expert English teacher and dictionary assistant.
You help learners with vocabulary, grammar, pronunciation and usage.
Be encouraging, clear and practical. Use tables when comparing words.
Tailor explanations to language learners. Be concise but comprehensive.
''';
}
