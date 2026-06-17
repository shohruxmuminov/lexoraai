import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../domain/entities/chat_entity.dart';
import '../core/constants/app_constants.dart';

class AiService {
  static const String _model = 'gpt-4o';

  static void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
    OpenAI.baseUrl = AppConstants.openAiBaseUrl;
  }

  // Stream chat completion
  Stream<String> streamChat({
    required List<ChatMessageEntity> messages,
    String? systemPrompt,
    double temperature = 0.7,
  }) async* {
    final systemMsg = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          systemPrompt ?? _defaultSystemPrompt,
        )
      ],
      role: OpenAIChatMessageRole.system,
    );

    final chatMessages = [
      systemMsg,
      ...messages.map((m) => OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(m.content)
            ],
            role: m.role == MessageRole.user
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
          )),
    ];

    final stream = OpenAI.instance.chat.createStream(
      model: _model,
      messages: chatMessages,
      temperature: temperature,
      maxTokens: 1500,
    );

    await for (final chunk in stream) {
      final delta = chunk.choices.first.delta.content?.first.text;
      if (delta != null && delta.isNotEmpty) {
        yield delta;
      }
    }
  }

  // Explain word with context
  Future<String> explainWord(String word, {String? targetLanguage}) async {
    final prompt = '''
Explain the English word "$word" in detail. Include:
1. Clear definition
2. Part of speech
3. 3 example sentences
4. Common collocations
5. Tips to remember it
${targetLanguage != null ? '6. Translation in $targetLanguage' : ''}

Format your response in a clear, engaging way suitable for a language learner.
''';

    return await _singleCompletion(prompt);
  }

  // Compare two words
  Future<String> compareWords(String word1, String word2) async {
    final prompt = '''
Compare the English words "$word1" and "$word2". Create a detailed comparison including:
1. Key differences in meaning
2. When to use each word
3. 3 example sentences for each
4. Common mistakes learners make
5. A simple table comparing their usage

Make it educational and easy to understand.
''';

    return await _singleCompletion(prompt);
  }

  // Generate quiz questions for a word
  Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required List<String> words,
    required String difficulty,
    required String type,
  }) async {
    final prompt = '''
Generate 5 quiz questions for these English words: ${words.join(', ')}.
Difficulty: $difficulty
Type: $type

Return as a JSON array with objects containing:
- question: the question text
- options: array of 4 options (for MCQ)
- correctAnswer: the correct answer
- explanation: brief explanation
- points: 10 for easy, 20 for medium, 30 for hard

Return ONLY valid JSON, no markdown.
''';

    final response = await _singleCompletion(prompt, temperature: 0.3);
    try {
      // Parse and return
      return [];
    } catch (_) {
      return [];
    }
  }

  // Evaluate writing
  Future<Map<String, dynamic>> evaluateWriting(String text) async {
    final prompt = '''
Evaluate this English text for grammar, vocabulary, coherence, and style:

"$text"

Provide:
1. Overall band score (0-9 IELTS scale)
2. Grammar score with specific errors
3. Vocabulary score with suggestions
4. Coherence score
5. 3 specific improvement suggestions
6. Corrected version

Return as JSON with keys: overallScore, grammarScore, vocabularyScore, coherenceScore, errors, suggestions, correctedText
''';

    final response = await _singleCompletion(prompt, temperature: 0.2);
    return {'response': response};
  }

  // Evaluate pronunciation (from transcript)
  Future<Map<String, dynamic>> evaluatePronunciation({
    required String targetWord,
    required String spokenText,
  }) async {
    final prompt = '''
The user was supposed to say: "$targetWord"
The speech recognition captured: "$spokenText"

Evaluate pronunciation accuracy (0-100) and provide:
1. Score
2. What they got right
3. What needs improvement
4. Phonetic breakdown tips

Return as JSON: {score, feedback, tips, phonetic}
''';

    final response = await _singleCompletion(prompt, temperature: 0.2);
    return {'response': response};
  }

  // Translate with context
  Future<String> translateWithContext({
    required String text,
    required String targetLanguage,
    bool includeAlternatives = true,
  }) async {
    final prompt = '''
Translate to $targetLanguage: "$text"

${includeAlternatives ? 'Also provide:\n1. 2 alternative translations\n2. Contextual notes\n3. Any important cultural differences' : ''}
''';

    return await _singleCompletion(prompt);
  }

  // Generate vocabulary study plan
  Future<String> generateStudyPlan({
    required int wordsPerDay,
    required String cefrTarget,
    required String purpose,
    required int daysAvailable,
  }) async {
    final prompt = '''
Create a personalized vocabulary study plan:
- Words per day: $wordsPerDay
- Target CEFR level: $cefrTarget
- Purpose: $purpose
- Days available: $daysAvailable

Include:
1. Day-by-day schedule
2. Review schedule
3. Tips for retention
4. Milestones to track progress

Be specific and motivating.
''';

    return await _singleCompletion(prompt);
  }

  // Simplify a complex text
  Future<String> simplifyText(String text, String level) async {
    final prompt = 'Simplify this text for a $level English learner. Keep the main meaning but use simpler words and shorter sentences:\n\n"$text"';
    return await _singleCompletion(prompt);
  }

  // Extract vocabulary from article
  Future<List<Map<String, String>>> extractVocabulary(String articleText) async {
    final prompt = '''
From this article, extract the 10 most important advanced vocabulary words:

"${articleText.substring(0, articleText.length > 2000 ? 2000 : articleText.length)}"

For each word return JSON: [{word, definition, example, cefrLevel}]
Return ONLY a JSON array.
''';

    final response = await _singleCompletion(prompt, temperature: 0.2);
    return [];
  }

  Future<String> _singleCompletion(String prompt, {double temperature = 0.7}) async {
    final completion = await OpenAI.instance.chat.create(
      model: _model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
          role: OpenAIChatMessageRole.user,
        ),
      ],
      temperature: temperature,
      maxTokens: 2000,
    );

    return completion.choices.first.message.content?.first.text ?? '';
  }

  static const String _defaultSystemPrompt = '''
You are Lexora AI, an expert English language teacher and dictionary assistant.
You help users learn English vocabulary, grammar, pronunciation, and usage.
You are encouraging, clear, and provide practical examples.
When comparing words, use tables for clarity.
Always tailor your explanations to language learners.
Be concise but comprehensive.
''';
}
