class WordEntity {
  final String id;
  final String word;
  final String? phonetic;
  final String? phoneticUs;
  final String? phoneticUk;
  final String? audioUs;
  final String? audioUk;
  final List<MeaningEntity> meanings;
  final EtymologyEntity? etymology;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> relatedWords;
  final List<CollocationEntity> collocations;
  final List<PhrasalVerbEntity> phrasalVerbs;
  final List<IdiomEntity> idioms;
  final String? cefrLevel;
  final String? ieltsLevel;
  final int? frequencyRank;
  final bool isAcademic;
  final String? formalityLevel;
  final String? culturalNote;
  final List<String> commonMistakes;
  final List<String> imageUrls;
  final Map<String, String> translations;
  final DateTime? addedAt;
  final bool isFavorite;
  final bool isLearned;
  final int reviewCount;
  final double masteryScore;

  const WordEntity({
    required this.id,
    required this.word,
    this.phonetic,
    this.phoneticUs,
    this.phoneticUk,
    this.audioUs,
    this.audioUk,
    required this.meanings,
    this.etymology,
    this.synonyms = const [],
    this.antonyms = const [],
    this.relatedWords = const [],
    this.collocations = const [],
    this.phrasalVerbs = const [],
    this.idioms = const [],
    this.cefrLevel,
    this.ieltsLevel,
    this.frequencyRank,
    this.isAcademic = false,
    this.formalityLevel,
    this.culturalNote,
    this.commonMistakes = const [],
    this.imageUrls = const [],
    this.translations = const {},
    this.addedAt,
    this.isFavorite = false,
    this.isLearned = false,
    this.reviewCount = 0,
    this.masteryScore = 0.0,
  });

  WordEntity copyWith({
    bool? isFavorite,
    bool? isLearned,
    int? reviewCount,
    double? masteryScore,
  }) {
    return WordEntity(
      id: id,
      word: word,
      phonetic: phonetic,
      phoneticUs: phoneticUs,
      phoneticUk: phoneticUk,
      audioUs: audioUs,
      audioUk: audioUk,
      meanings: meanings,
      etymology: etymology,
      synonyms: synonyms,
      antonyms: antonyms,
      relatedWords: relatedWords,
      collocations: collocations,
      phrasalVerbs: phrasalVerbs,
      idioms: idioms,
      cefrLevel: cefrLevel,
      ieltsLevel: ieltsLevel,
      frequencyRank: frequencyRank,
      isAcademic: isAcademic,
      formalityLevel: formalityLevel,
      culturalNote: culturalNote,
      commonMistakes: commonMistakes,
      imageUrls: imageUrls,
      translations: translations,
      addedAt: addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isLearned: isLearned ?? this.isLearned,
      reviewCount: reviewCount ?? this.reviewCount,
      masteryScore: masteryScore ?? this.masteryScore,
    );
  }
}

class MeaningEntity {
  final String partOfSpeech;
  final List<DefinitionEntity> definitions;
  final List<String> synonyms;
  final List<String> antonyms;
  final bool? isCountable;

  const MeaningEntity({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms = const [],
    this.antonyms = const [],
    this.isCountable,
  });
}

class DefinitionEntity {
  final String definition;
  final String? example;
  final List<String> examples;
  final String? formalityLevel;

  const DefinitionEntity({
    required this.definition,
    this.example,
    this.examples = const [],
    this.formalityLevel,
  });
}

class EtymologyEntity {
  final String? origin;
  final String? period;
  final String? language;
  final String? description;

  const EtymologyEntity({
    this.origin,
    this.period,
    this.language,
    this.description,
  });
}

class CollocationEntity {
  final String collocation;
  final String? example;
  final String type;

  const CollocationEntity({
    required this.collocation,
    this.example,
    required this.type,
  });
}

class PhrasalVerbEntity {
  final String phrasal;
  final String meaning;
  final String? example;

  const PhrasalVerbEntity({
    required this.phrasal,
    required this.meaning,
    this.example,
  });
}

class IdiomEntity {
  final String idiom;
  final String meaning;
  final String? example;

  const IdiomEntity({
    required this.idiom,
    required this.meaning,
    this.example,
  });
}
