class GamificationSystem {
  // XP rewards
  static const int xpWordLearned = 10;
  static const int xpQuizPassed = 50;
  static const int xpPerfectQuiz = 100;
  static const int xpFlashcardReviewed = 5;
  static const int xpStreakBonus = 20;
  static const int xpDailyGoalCompleted = 30;

  // Level thresholds (each level needs more XP)
  static int xpForLevel(int level) => level * 500;

  static int calculateLevel(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return level;
  }

  static double levelProgress(int totalXp) {
    final level = calculateLevel(totalXp);
    int usedXp = 0;
    for (int i = 1; i < level; i++) {
      usedXp += xpForLevel(i);
    }
    final xpInLevel = totalXp - usedXp;
    return xpInLevel / xpForLevel(level);
  }

  // Achievement definitions
  static const Map<String, Map<String, dynamic>> achievements = {
    'first_word': {'title': 'First Steps', 'desc': 'Learn your first word', 'emoji': '🌱', 'xp': 10},
    'word_10': {'title': 'Curious Mind', 'desc': 'Learn 10 words', 'emoji': '🔍', 'xp': 20},
    'word_100': {'title': 'Word Collector', 'desc': 'Learn 100 words', 'emoji': '📚', 'xp': 100},
    'word_500': {'title': 'Lexicon Master', 'desc': 'Learn 500 words', 'emoji': '🏆', 'xp': 500},
    'streak_7': {'title': 'Consistent', 'desc': '7-day streak', 'emoji': '🔥', 'xp': 70},
    'streak_30': {'title': 'Dedicated', 'desc': '30-day streak', 'emoji': '🌟', 'xp': 300},
    'perfect_quiz': {'title': 'Perfectionist', 'desc': '100% quiz score', 'emoji': '🎯', 'xp': 100},
    'ielts_b2': {'title': 'IELTS Ready', 'desc': 'Master B2 vocabulary', 'emoji': '🎓', 'xp': 200},
    'speaker': {'title': 'Speaker', 'desc': 'Score 90%+ in speaking', 'emoji': '🗣️', 'xp': 150},
    'night_owl': {'title': 'Night Owl', 'desc': 'Study after midnight', 'emoji': '🦉', 'xp': 20},
  };

  static Map<String, dynamic>? checkAchievement({
    required int wordsLearned,
    required int streakDays,
    required double quizScore,
    required double speakingScore,
  }) {
    if (wordsLearned == 1) return achievements['first_word'];
    if (wordsLearned == 10) return achievements['word_10'];
    if (wordsLearned == 100) return achievements['word_100'];
    if (wordsLearned == 500) return achievements['word_500'];
    if (streakDays == 7) return achievements['streak_7'];
    if (streakDays == 30) return achievements['streak_30'];
    if (quizScore == 1.0) return achievements['perfect_quiz'];
    if (speakingScore >= 0.9) return achievements['speaker'];
    return null;
  }

  // Streak calculation
  static int calculateStreak({
    required DateTime? lastActiveDate,
    required int currentStreak,
  }) {
    if (lastActiveDate == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final diff = today.difference(last).inDays;

    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1; // streak broken
  }
}
