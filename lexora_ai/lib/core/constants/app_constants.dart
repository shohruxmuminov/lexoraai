class AppConstants {
  static const String appName = 'Lexora AI';
  static const String appVersion = '1.0.0';

  // API
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String dictionaryApiUrl = 'https://api.dictionaryapi.dev/api/v2/entries';
  static const String merriamWebsterUrl = 'https://www.dictionaryapi.com/api/v3/references';

  // Hive Boxes
  static const String wordsBox = 'words_box';
  static const String flashcardsBox = 'flashcards_box';
  static const String settingsBox = 'settings_box';
  static const String userProgressBox = 'user_progress_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String vocabularyBankBox = 'vocabulary_bank_box';
  static const String cacheBox = 'cache_box';

  // Durations
  static const int splashDuration = 3;
  static const int animDuration = 300;
  static const int longAnimDuration = 600;

  // Gamification
  static const int xpPerWord = 10;
  static const int xpPerQuiz = 50;
  static const int xpPerFlashcard = 5;
  static const int xpPerStreak = 20;
  static const int wordsPerDailyGoal = 20;

  // SRS intervals (days)
  static const List<int> srsIntervals = [1, 3, 7, 14, 30, 90];

  // CEFR levels
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  // Supported language pairs
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'uz', 'name': 'Uzbek', 'flag': '🇺🇿'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦'},
  ];
}
