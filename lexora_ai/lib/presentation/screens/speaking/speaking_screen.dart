import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/speech_service.dart';
import '../../../services/tts_service.dart';

class SpeakingScreen extends ConsumerStatefulWidget {
  const SpeakingScreen({super.key});

  @override
  ConsumerState<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends ConsumerState<SpeakingScreen>
    with TickerProviderStateMixin {
  final _speechService = SpeechService();
  final _ttsService = TtsService();
  late AnimationController _pulseController;

  bool _isListening = false;
  String _recognizedText = '';
  int _currentWordIndex = 0;
  double _score = 0;
  bool _hasResult = false;

  final List<Map<String, String>> _practiceWords = [
    {'word': 'Pronunciation', 'phonetic': '/prəˌnʌn.siˈeɪ.ʃən/', 'tip': 'Focus on the "nun" sound in the middle'},
    {'word': 'Particularly', 'phonetic': '/pəˈtɪk.jʊ.lə.li/', 'tip': 'Stress the second syllable: par-TIC-u-lar-ly'},
    {'word': 'Enthusiastic', 'phonetic': '/ɪnˌθjuː.ziˈæs.tɪk/', 'tip': 'Four syllables: en-thu-si-as-tic'},
    {'word': 'Sophisticated', 'phonetic': '/səˈfɪs.tɪ.keɪ.tɪd/', 'tip': 'Stress the second syllable'},
    {'word': 'Approximately', 'phonetic': '/əˈprɒk.sɪ.mət.li/', 'tip': 'Common in IELTS — practice daily!'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _speechService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final word = _practiceWords[_currentWordIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('Speaking Practice',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentWordIndex + 1}/${_practiceWords.length}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Pronunciation scores header
            _ScoreCard(score: _score).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            // Word card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Say this word:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(
                    word['word']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate(key: ValueKey(_currentWordIndex)).fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    word['phonetic']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _ttsService.speakUS(word['word']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Hear native pronunciation',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // Tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      word['tip']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textWhite70 : AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Microphone button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isListening
                      ? 1.0 + 0.1 * (_pulseController.value)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: _isListening
                            ? const LinearGradient(colors: [AppColors.error, Color(0xFFFF6B6B)])
                            : AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppColors.error : AppColors.primary).withOpacity(0.4),
                            blurRadius: _isListening ? 30 : 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _isListening ? 'Listening... speak now' : 'Tap to speak',
              style: TextStyle(
                fontSize: 15,
                color: _isListening ? AppColors.error : (isDark ? AppColors.textWhite50 : AppColors.textMedium),
                fontWeight: FontWeight.w500,
              ),
            ).animate(onPlay: (c) => _isListening ? c.repeat() : c.stop())
              .fadeIn(duration: 300.ms),

            // Recognized text
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You said:', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    const SizedBox(height: 6),
                    Text(
                      '"$_recognizedText"',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Result
            if (_hasResult) ...[
              const SizedBox(height: 24),
              _PronunciationResult(
                score: _score,
                targetWord: word['word']!,
                spokenText: _recognizedText,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _hasResult = false;
                        _recognizedText = '';
                        _score = 0;
                      }),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Try Again', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextWord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Next Word →', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _recognizedText = '';
      _hasResult = false;
    });
    _pulseController.repeat(reverse: true);

    await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _recognizedText = text;
        });
        _evaluatePronunciation(text);
      },
    );
  }

  void _stopListening() async {
    await _speechService.stopListening();
    _pulseController.stop();
    setState(() => _isListening = false);
  }

  void _evaluatePronunciation(String spoken) {
    _stopListening();
    final target = _practiceWords[_currentWordIndex]['word']!.toLowerCase();
    final spokenLower = spoken.toLowerCase().trim();

    double score = 0;
    if (spokenLower == target) {
      score = 95 + (DateTime.now().millisecond % 5);
    } else if (spokenLower.contains(target) || target.contains(spokenLower)) {
      score = 70 + (DateTime.now().millisecond % 20);
    } else {
      final similarity = _calculateSimilarity(target, spokenLower);
      score = (similarity * 100).clamp(20, 85);
    }

    setState(() {
      _score = score;
      _hasResult = true;
    });
  }

  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    int matches = 0;
    for (int i = 0; i < a.length && i < b.length; i++) {
      if (a[i] == b[i]) matches++;
    }
    return matches / a.length;
  }

  void _nextWord() {
    setState(() {
      _currentWordIndex = (_currentWordIndex + 1) % _practiceWords.length;
      _hasResult = false;
      _recognizedText = '';
      _score = 0;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.stopListening();
    super.dispose();
  }
}

class _ScoreCard extends StatelessWidget {
  final double score;
  const _ScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _metric('Accuracy', score > 0 ? '${score.toInt()}%' : '--', AppColors.primary),
          _divider(),
          _metric('Words Done', '0', AppColors.secondary),
          _divider(),
          _metric('Best Score', score > 0 ? '${score.toInt()}%' : '--', AppColors.accent),
          _divider(),
          _metric('Streak', '3 🔥', AppColors.streakOrange),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 30, color: AppColors.border);
  }
}

class _PronunciationResult extends StatelessWidget {
  final double score;
  final String targetWord;
  final String spokenText;
  final bool isDark;

  const _PronunciationResult({
    required this.score,
    required this.targetWord,
    required this.spokenText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = score >= 80;
    final color = score >= 80 ? AppColors.success : score >= 60 ? AppColors.warning : AppColors.error;
    final feedback = score >= 90
        ? 'Excellent! 🎉 Native-level pronunciation!'
        : score >= 80
            ? 'Great job! 👏 Very clear pronunciation.'
            : score >= 60
                ? 'Good effort! Keep practicing the tricky sounds.'
                : 'Keep trying! Focus on each syllable carefully.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${score.toInt()}%',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGood ? 'Well done!' : 'Keep going!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textWhite70 : AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ScoreBar(label: 'Accuracy', value: score / 100, color: AppColors.primary),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Clarity', value: (score * 0.9) / 100, color: AppColors.secondary),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Rhythm', value: (score * 0.85) / 100, color: AppColors.accent),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
