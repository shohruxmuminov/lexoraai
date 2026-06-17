import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/word_entity.dart';
import '../../providers/word_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../services/tts_service.dart';

final _ttsService = TtsService();

class WordDetailScreen extends ConsumerStatefulWidget {
  final String word;
  const WordDetailScreen({super.key, required this.word});

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _playingUs = false;
  bool _playingUk = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _ttsService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordSearchProvider.notifier).search(widget.word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(favoritesProvider.notifier).isFavorite(widget.word);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.result == null
              ? _notFound(context)
              : _buildContent(context, state.result!, isDark, isFav),
    );
  }

  Widget _buildContent(BuildContext context, WordEntity word, bool isDark, bool isFav) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppColors.textDark,
                size: 18,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isFav ? AppColors.primary : (isDark ? Colors.white : AppColors.textDark),
              ),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(word),
            ),
            IconButton(
              icon: Icon(
                Icons.share_rounded,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _WordHeader(word: word, isDark: isDark),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textWhite50 : AppColors.textLight,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Meanings'),
              Tab(text: 'Examples'),
              Tab(text: 'Related'),
              Tab(text: 'Grammar'),
              Tab(text: 'AI Chat'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _MeaningsTab(word: word, isDark: isDark),
          _ExamplesTab(word: word, isDark: isDark),
          _RelatedTab(word: word, isDark: isDark),
          _GrammarTab(word: word, isDark: isDark),
          _AiChatTab(word: word.word),
        ],
      ),
    );
  }

  Widget _notFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            '"${widget.word}" not found',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try checking the spelling\nor search another word.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/search'),
            child: const Text('Search Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _WordHeader extends StatelessWidget {
  final WordEntity word;
  final bool isDark;

  const _WordHeader({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.surfaceDark, AppColors.backgroundDark]
              : [Colors.white, AppColors.backgroundLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textDark,
                        height: 1,
                      ),
                    ),
                    if (word.phonetic != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        word.phonetic!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (word.cefrLevel != null)
                    _badge(word.cefrLevel!, _cefrColor(word.cefrLevel!)),
                  if (word.isAcademic) ...[
                    const SizedBox(height: 4),
                    _badge('Academic', AppColors.secondary),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Pronunciation buttons
          Row(
            children: [
              _pronBtn('🇺🇸 US', word.audioUs ?? word.word, isUs: true),
              const SizedBox(width: 8),
              _pronBtn('🇬🇧 UK', word.audioUk ?? word.word, isUs: false),
              const Spacer(),
              if (word.frequencyRank != null)
                Row(
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 14,
                        color: isDark ? AppColors.textWhite50 : AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      'Rank #${word.frequencyRank}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pronBtn(String label, String text, {required bool isUs}) {
    return GestureDetector(
      onTap: () {
        if (isUs) {
          _ttsService.speakUS(text);
        } else {
          _ttsService.speakUK(text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _cefrColor(String level) {
    switch (level) {
      case 'A1': return AppColors.cefrA1;
      case 'A2': return AppColors.cefrA2;
      case 'B1': return AppColors.cefrB1;
      case 'B2': return AppColors.cefrB2;
      case 'C1': return AppColors.cefrC1;
      case 'C2': return AppColors.cefrC2;
      default: return AppColors.primary;
    }
  }
}

class _MeaningsTab extends StatelessWidget {
  final WordEntity word;
  final bool isDark;

  const _MeaningsTab({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...word.meanings.asMap().entries.map((e) => _MeaningSection(
          meaning: e.value,
          index: e.key,
          isDark: isDark,
        )),
        if (word.commonMistakes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: '⚠️ Common Mistakes',
            color: AppColors.warning,
            isDark: isDark,
            child: Column(
              children: word.commonMistakes.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(m, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
        if (word.culturalNote != null) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: '🌍 Cultural Note',
            color: AppColors.secondary,
            isDark: isDark,
            child: Text(
              word.culturalNote!,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ],
        if (word.etymology != null) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: '📜 Etymology',
            color: AppColors.accent,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.etymology!.origin != null)
                  Text('Origin: ${word.etymology!.origin}',
                    style: const TextStyle(fontSize: 13, height: 1.5)),
                if (word.etymology!.description != null)
                  Text(word.etymology!.description!,
                    style: const TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MeaningSection extends StatelessWidget {
  final MeaningEntity meaning;
  final int index;
  final bool isDark;

  const _MeaningSection({required this.meaning, required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(height: 32),
        // Part of speech
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            meaning.partOfSpeech,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        if (meaning.isCountable != null) ...[
          const SizedBox(height: 6),
          Text(
            meaning.isCountable! ? '[countable]' : '[uncountable]',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),

        ...meaning.definitions.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 1, right: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.value.definition,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (e.value.example != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 3),
                          ),
                        ),
                        child: Text(
                          '"${e.value.example}"',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.textWhite70 : AppColors.textMedium,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _ExamplesTab extends StatelessWidget {
  final WordEntity word;
  final bool isDark;

  const _ExamplesTab({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final allExamples = word.meanings
        .expand((m) => m.definitions.expand((d) => d.examples))
        .toList();

    if (allExamples.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_quote_rounded, size: 48, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('No examples yet', style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allExamples.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${allExamples[i]}"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white : AppColors.textDark,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Example ${i + 1}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                const Spacer(),
                Icon(Icons.volume_up_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedTab extends StatelessWidget {
  final WordEntity word;
  final bool isDark;

  const _RelatedTab({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (word.synonyms.isNotEmpty) ...[
          _ChipGroup(title: '✅ Synonyms', words: word.synonyms, color: AppColors.success, isDark: isDark),
          const SizedBox(height: 20),
        ],
        if (word.antonyms.isNotEmpty) ...[
          _ChipGroup(title: '❌ Antonyms', words: word.antonyms, color: AppColors.error, isDark: isDark),
          const SizedBox(height: 20),
        ],
        if (word.collocations.isNotEmpty) ...[
          Text('🔗 Collocations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          ...word.collocations.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Text(c.collocation,
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                if (c.example != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(c.example!,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textLight)),
                  ),
                ],
              ],
            ),
          )),
        ],
        if (word.phrasalVerbs.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('🔄 Phrasal Verbs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          ...word.phrasalVerbs.map((p) => _PhrasalCard(phrasal: p, isDark: isDark)),
        ],
        if (word.idioms.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('💬 Idioms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          ...word.idioms.map((i) => _IdiomCard(idiom: i, isDark: isDark)),
        ],
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final String title;
  final List<String> words;
  final Color color;
  final bool isDark;

  const _ChipGroup({required this.title, required this.words, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.map((w) => GestureDetector(
            onTap: () => context.go('/word/$w'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(w,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _PhrasalCard extends StatelessWidget {
  final PhrasalVerbEntity phrasal;
  final bool isDark;

  const _PhrasalCard({required this.phrasal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phrasal.phrasal,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(phrasal.meaning, style: const TextStyle(fontSize: 13, height: 1.4)),
          if (phrasal.example != null) ...[
            const SizedBox(height: 4),
            Text('"${phrasal.example}"',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textLight)),
          ],
        ],
      ),
    );
  }
}

class _IdiomCard extends StatelessWidget {
  final IdiomEntity idiom;
  final bool isDark;

  const _IdiomCard({required this.idiom, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(idiom.idiom,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text(idiom.meaning, style: const TextStyle(fontSize: 13, height: 1.4)),
          if (idiom.example != null) ...[
            const SizedBox(height: 4),
            Text('"${idiom.example}"',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textLight)),
          ],
        ],
      ),
    );
  }
}

class _GrammarTab extends StatelessWidget {
  final WordEntity word;
  final bool isDark;

  const _GrammarTab({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: '📊 Word Information',
          color: AppColors.primary,
          isDark: isDark,
          child: Column(
            children: [
              _infoRow('Word', word.word, isDark),
              _infoRow('CEFR Level', word.cefrLevel ?? 'Unknown', isDark),
              _infoRow('IELTS Band', word.ieltsLevel ?? 'N/A', isDark),
              _infoRow('Register', word.formalityLevel ?? 'Neutral', isDark),
              _infoRow('Academic Word', word.isAcademic ? 'Yes ✓' : 'No', isDark),
              if (word.frequencyRank != null)
                _infoRow('Frequency Rank', '#${word.frequencyRank}', isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '🎭 Parts of Speech',
          color: AppColors.secondary,
          isDark: isDark,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: word.meanings.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Text(m.partOfSpeech,
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label,
            style: TextStyle(fontSize: 13, color: isDark ? AppColors.textWhite50 : AppColors.textLight)),
          const Spacer(),
          Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;
  final bool isDark;

  const _SectionCard({
    required this.title,
    required this.color,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
              color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AiChatTab extends ConsumerStatefulWidget {
  final String word;
  const _AiChatTab({required this.word});

  @override
  ConsumerState<_AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends ConsumerState<_AiChatTab> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).setWordContext(widget.word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Quick actions
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _quickChip('Explain simply', '🧠'),
              _quickChip('Give examples', '📝'),
              _quickChip('Synonyms & differences', '🔄'),
              _quickChip('How to remember', '💡'),
              _quickChip('Use in sentence', '✍️'),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chatState.messages.length,
            itemBuilder: (context, i) => _MessageBubble(
              message: chatState.messages[i],
              isDark: isDark,
            ),
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Ask anything about "${widget.word}"...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textWhite30 : AppColors.textLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: chatState.isStreaming
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String text, String emoji) {
    return GestureDetector(
      onTap: () => _send('$emoji $text about "${widget.word}"'),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(
          '$emoji $text',
          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role.toString().contains('user');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isLoading
                  ? const _TypingIndicator()
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : (isDark ? Colors.white : AppColors.textDark),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true, period: Duration(milliseconds: 600 + i * 200)));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _controllers[i],
        builder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textLight.withOpacity(0.4 + 0.6 * _controllers[i].value),
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }
}
