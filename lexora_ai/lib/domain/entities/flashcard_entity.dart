enum FlashcardType { basic, picture, audio, reverse, sentence }
enum FlashcardStatus { new_, learning, review, mastered }

class FlashcardEntity {
  final String id;
  final String wordId;
  final String word;
  final String definition;
  final String? translation;
  final String? example;
  final String? imageUrl;
  final String? audioUrl;
  final FlashcardType type;
  final FlashcardStatus status;
  final int srsStage;
  final DateTime? nextReviewDate;
  final int correctCount;
  final int incorrectCount;
  final String deckId;

  const FlashcardEntity({
    required this.id,
    required this.wordId,
    required this.word,
    required this.definition,
    this.translation,
    this.example,
    this.imageUrl,
    this.audioUrl,
    this.type = FlashcardType.basic,
    this.status = FlashcardStatus.new_,
    this.srsStage = 0,
    this.nextReviewDate,
    this.correctCount = 0,
    this.incorrectCount = 0,
    required this.deckId,
  });

  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  FlashcardEntity copyWith({
    FlashcardStatus? status,
    int? srsStage,
    DateTime? nextReviewDate,
    int? correctCount,
    int? incorrectCount,
  }) {
    return FlashcardEntity(
      id: id,
      wordId: wordId,
      word: word,
      definition: definition,
      translation: translation,
      example: example,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      type: type,
      status: status ?? this.status,
      srsStage: srsStage ?? this.srsStage,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      deckId: deckId,
    );
  }
}

class DeckEntity {
  final String id;
  final String name;
  final String? description;
  final String? emoji;
  final String color;
  final List<String> cardIds;
  final String userId;
  final DateTime createdAt;
  final bool isBuiltIn;

  const DeckEntity({
    required this.id,
    required this.name,
    this.description,
    this.emoji,
    required this.color,
    required this.cardIds,
    required this.userId,
    required this.createdAt,
    this.isBuiltIn = false,
  });

  int get totalCards => cardIds.length;
}
