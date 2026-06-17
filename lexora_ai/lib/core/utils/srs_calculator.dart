// Spaced Repetition System (SRS) — Leitner + SM-2 hybrid
class SrsCalculator {
  static const List<int> _intervals = [1, 3, 7, 14, 30, 90, 180];

  // Calculate next review date based on performance
  static DateTime nextReview({
    required int currentStage,
    required bool wasCorrect,
    required double easeFactor,
  }) {
    int newStage;
    if (wasCorrect) {
      newStage = (currentStage + 1).clamp(0, _intervals.length - 1);
    } else {
      newStage = (currentStage - 2).clamp(0, _intervals.length - 1);
    }

    final daysUntilReview = _intervals[newStage];
    return DateTime.now().add(Duration(days: daysUntilReview));
  }

  // SM-2 ease factor adjustment
  static double adjustEaseFactor({
    required double currentEase,
    required int quality, // 0-5 (0=blackout, 5=perfect)
  }) {
    final newEase = currentEase + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return newEase.clamp(1.3, 2.5);
  }

  // Leitner box assignment
  static int getLeitnerBox({required bool wasCorrect, required int currentBox}) {
    if (wasCorrect) {
      return (currentBox + 1).clamp(1, 5);
    }
    return 1;
  }

  // Get cards due for review
  static List<T> getDueCards<T>({
    required List<T> cards,
    required DateTime? Function(T) getNextReview,
  }) {
    final now = DateTime.now();
    return cards.where((card) {
      final nextReview = getNextReview(card);
      return nextReview == null || nextReview.isBefore(now) || nextReview.isAtSameMomentAs(now);
    }).toList();
  }

  // Estimate mastery percentage
  static double estimateMastery({
    required int correctCount,
    required int totalReviews,
    required int srsStage,
  }) {
    if (totalReviews == 0) return 0.0;
    final accuracy = correctCount / totalReviews;
    final stageBonus = srsStage / _intervals.length;
    return ((accuracy * 0.7) + (stageBonus * 0.3)).clamp(0.0, 1.0);
  }
}
