import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final _textCtrl = TextEditingController();
  bool _isAnalyzing = false;
  bool _hasResult = false;
  String _pastedText = '';

  final String _sampleArticle = '''The concept of artificial intelligence has undergone a remarkable metamorphosis since its inception in the mid-20th century. What began as an esoteric academic endeavor has proliferated into virtually every domain of contemporary life, fundamentally altering the paradigm of human-machine interaction.

The ramifications of this technological proliferation are multifaceted. Proponents argue that AI augments human capabilities, enabling unprecedented efficiency and precision in complex analytical tasks. Critics, however, articulate apprehension regarding the potential obsolescence of human labor and the ethical implications of autonomous decision-making systems.''';

  final List<String> _hardWords = ['metamorphosis', 'esoteric', 'proliferated', 'paradigm', 'ramifications', 'multifaceted', 'augments', 'unprecedented', 'obsolescence', 'autonomous'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('Reading Assistant', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
        actions: [
          if (_hasResult)
            TextButton(
              onPressed: () => setState(() { _hasResult = false; _pastedText = ''; _textCtrl.clear(); }),
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _hasResult ? _buildResult(isDark) : _buildInput(isDark),
      ),
    );
  }

  Widget _buildInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5B4FE8), Color(0xFF00C6A7)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📖', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              const Text('Paste any article or text',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('AI will highlight difficult words and help you understand them.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 20),

        // Text input
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _textCtrl,
            maxLines: 10,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Paste your article here...',
              hintStyle: TextStyle(color: isDark ? AppColors.textWhite30 : AppColors.textLight, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 12),

        // Sample article button
        TextButton.icon(
          icon: const Icon(Icons.article_rounded, color: AppColors.primary, size: 18),
          label: const Text('Use sample article', style: TextStyle(color: AppColors.primary)),
          onPressed: () => setState(() => _textCtrl.text = _sampleArticle),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyze,
            icon: _isAnalyzing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Text',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ).animate(delay: 200.ms).fadeIn(),
      ],
    );
  }

  Widget _buildResult(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        Row(
          children: [
            _statChip('${_hardWords.length} Hard Words', AppColors.error, isDark),
            const SizedBox(width: 8),
            _statChip('C1 Level', AppColors.levelPurple, isDark),
            const SizedBox(width: 8),
            _statChip('~3 min read', AppColors.info, isDark),
          ],
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        // Highlighted text
        Text('Article Analysis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: RichText(
            text: _buildHighlightedText(_pastedText, _hardWords, isDark),
          ),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 20),

        // Difficult words
        Text('Vocabulary to Learn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 12),

        ..._hardWords.take(6).asMap().entries.map((e) =>
          _VocabCard(word: e.value, index: e.key, isDark: isDark)
            .animate(delay: Duration(milliseconds: 200 + e.key * 50)).fadeIn().slideX(begin: 0.1, end: 0)),

        const SizedBox(height: 20),

        // Generate exercises
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.quiz_rounded),
            label: const Text('Generate Exercises', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ).animate(delay: 600.ms).fadeIn(),

        const SizedBox(height: 40),
      ],
    );
  }

  TextSpan _buildHighlightedText(String text, List<String> hardWords, bool isDark) {
    final spans = <TextSpan>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      int earliestIndex = remaining.length;
      String? foundWord;

      for (final word in hardWords) {
        final idx = remaining.toLowerCase().indexOf(word.toLowerCase());
        if (idx != -1 && idx < earliestIndex) {
          earliestIndex = idx;
          foundWord = word;
        }
      }

      if (foundWord == null) {
        spans.add(TextSpan(
          text: remaining,
          style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark, fontSize: 13, height: 1.7),
        ));
        break;
      }

      if (earliestIndex > 0) {
        spans.add(TextSpan(
          text: remaining.substring(0, earliestIndex),
          style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark, fontSize: 13, height: 1.7),
        ));
      }

      spans.add(TextSpan(
        text: remaining.substring(earliestIndex, earliestIndex + foundWord.length),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.7,
          backgroundColor: Color(0x1A5B4FE8),
        ),
      ));

      remaining = remaining.substring(earliestIndex + foundWord.length);
    }

    return TextSpan(children: spans);
  }

  Widget _statChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Future<void> _analyze() async {
    if (_textCtrl.text.trim().isEmpty) return;
    setState(() { _isAnalyzing = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _pastedText = _textCtrl.text.trim();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }
}

class _VocabCard extends StatelessWidget {
  final String word;
  final int index;
  final bool isDark;

  const _VocabCard({required this.word, required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final defs = {
      'metamorphosis': 'A process of transformation or change',
      'esoteric': 'Intended for or understood by a small group only',
      'proliferated': 'Increased rapidly in numbers or amount',
      'paradigm': 'A typical example or pattern; a framework',
      'ramifications': 'Complex consequences of an action or event',
      'multifaceted': 'Having many different aspects or features',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                  defs[word.toLowerCase()] ?? 'Advanced vocabulary word — tap to learn more',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textWhite50 : AppColors.textMedium),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
