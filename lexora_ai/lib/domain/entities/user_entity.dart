class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String nativeLanguage;
  final List<String> learningLanguages;
  final int xp;
  final int level;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int wordsLearned;
  final int totalWords;
  final double masteryScore;
  final List<String> achievements;
  final Map<String, dynamic> settings;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final String? dailyGoal;
  final int dailyGoalWords;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.nativeLanguage = 'uz',
    this.learningLanguages = const ['en'],
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActiveDate,
    this.wordsLearned = 0,
    this.totalWords = 0,
    this.masteryScore = 0.0,
    this.achievements = const [],
    this.settings = const {},
    this.isPremium = false,
    this.premiumExpiry,
    this.dailyGoal,
    this.dailyGoalWords = 20,
  });

  int get levelThreshold => level * 500;
  int get xpInCurrentLevel => xp % 500;
  double get levelProgress => xpInCurrentLevel / 500;

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    int? xp,
    int? level,
    int? streakDays,
    DateTime? lastActiveDate,
    int? wordsLearned,
    double? masteryScore,
    bool? isPremium,
    int? dailyGoalWords,
  }) {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      nativeLanguage: nativeLanguage,
      learningLanguages: learningLanguages,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      totalWords: totalWords,
      masteryScore: masteryScore ?? this.masteryScore,
      achievements: achievements,
      settings: settings,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry,
      dailyGoal: dailyGoal,
      dailyGoalWords: dailyGoalWords ?? this.dailyGoalWords,
    );
  }
}
