enum QuizType { multipleChoice, fillBlank, matching, listening, speaking, writing }
enum QuizDifficulty { beginner, intermediate, advanced, ielts }

class QuizEntity {
  final String id;
  final String title;
  final QuizType type;
  final QuizDifficulty difficulty;
  final List<QuizQuestionEntity> questions;
  final int? timeLimit;
  final String? topic;
  final DateTime createdAt;

  const QuizEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.questions,
    this.timeLimit,
    this.topic,
    required this.createdAt,
  });
}

class QuizQuestionEntity {
  final String id;
  final String question;
  final String? word;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? audioUrl;
  final String? imageUrl;
  final int points;

  const QuizQuestionEntity({
    required this.id,
    required this.question,
    this.word,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.audioUrl,
    this.imageUrl,
    this.points = 10,
  });
}

class QuizResultEntity {
  final String quizId;
  final int score;
  final int totalPoints;
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeTaken;
  final DateTime completedAt;
  final int xpEarned;

  const QuizResultEntity({
    required this.quizId,
    required this.score,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.completedAt,
    required this.xpEarned,
  });

  double get percentage => (score / totalPoints) * 100;
  bool get isPassed => percentage >= 60;
}
