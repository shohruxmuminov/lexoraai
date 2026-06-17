import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _inQuiz = false;
  String _selectedType = 'Multiple Choice';
  String _selectedDifficulty = 'Intermediate';
  int _currentQ = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What does "ephemeral" mean?',
      'word': 'ephemeral',
      'options': ['Lasting forever', 'Very expensive', 'Short-lived', 'Extremely large'],
      'correct': 'Short-lived',
      'explanation': '"Ephemeral" comes from Greek "ephemeros" meaning "lasting only a day". It describes something that lasts for a very short time.',
    },
    {
      'question': 'Choose the best synonym for "meticulous":',
      'word': 'meticulous',
      'options': ['Careless', 'Thorough', 'Quick', 'Noisy'],
      'correct': 'Thorough',
      'explanation': '"Meticulous" means showing great attention to detail. "Thorough" is the closest synonym.',
    },
    {
      'question': 'Which sentence uses "eloquent" correctly?',
      'word': 'eloquent',
      'options': [
        'The eloquent rock sat quietly.',
        'She gave an eloquent speech that inspired everyone.',
        'The soup was very eloquent.',
        'He ran eloquently to the store.',
      ],
      'correct': 'She gave an eloquent speech that inspired everyone.',
      'explanation': '"Eloquent" means fluent or persuasive in speaking or writing. It correctly describes a speech.',
    },
    {
      'question': 'What is the CEFR level for "resilience"?',
      'word': 'resilience',
      'options': ['A1 – Beginner', 'A2 – Elementary', 'B2 – Upper Intermediate', 'C2 – Mastery'],
      'correct': 'B2 – Upper Intermediate',
      'explanation': '"Resilience" is a B2-level word commonly tested in IELTS and academic writing.',
    },
    {
      'question': 'Complete: "Her _____ in the face of adversity inspired everyone."',
      'word': 'tenacity',
      'options': ['laziness', 'tenacity', 'silence', 'confusion'],
      'correct': 'tenacity',
      'explanation': '"Tenacity" means persistent determination. It fits perfectly here to describe someone who overcomes adversity.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text(
          'Quiz',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        ),
      ),
      body: _inQuiz
          ? (_currentQ >= _questions.length ? _buildResults(isDark) : _buildQuiz(isDark))
          : _buildSetup(isDark),
    );
  }

  Widget _buildSetup(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🧠', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text(
                  'Test Your Knowledge',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI-generated questions tailored to your level',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          _sectionTitle('Quiz Type', isDark),
          const SizedBox(height: 12),
          _options(['Multiple Choice', 'Fill in the Blank', 'Matching', 'Listening'], _selectedType,
              (v) => setState(() => _selectedType = v), isDark),

          const SizedBox(height: 24),

          _sectionTitle('Difficulty', isDark),
          const SizedBox(height: 12),
          _options(['Beginner', 'Intermediate', 'Advanced', 'IELTS Mode'], _selectedDifficulty,
              (v) => setState(() => _selectedDifficulty = v), isDark),

          const SizedBox(height: 24),

          _sectionTitle('Category', isDark),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _categoryChip('🎓 IELTS Vocab', AppColors.primary, isDark),
              _categoryChip('💼 Business', AppColors.secondary, isDark),
              _categoryChip('📰 Academic', AppColors.levelPurple, isDark),
              _categoryChip('💬 Daily Life', AppColors.accent, isDark),
              _categoryChip('🔬 Science', AppColors.info, isDark),
              _categoryChip('📚 Literature', AppColors.error, isDark),
            ],
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _inQuiz = true),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildQuiz(bool isDark) {
    final q = _questions[_currentQ];
    final correct = q['correct'] as String;

    return Column(
      children: [
        // Progress
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Question ${_currentQ + 1}/${_questions.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.xpGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.xpGold, size: 14),
                        Text(
                          '$_score pts',
                          style: const TextStyle(
                            color: AppColors.xpGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentQ + 1) / _questions.length,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        q['question'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(_currentQ)).fadeIn().slideY(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                // Options
                ...(q['options'] as List<String>).asMap().entries.map((e) {
                  final option = e.value;
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == correct;
                  Color? bgColor;
                  Color? borderColor;
                  Color textColor = isDark ? Colors.white : AppColors.textDark;

                  if (_answered) {
                    if (isCorrect) {
                      bgColor = AppColors.success.withOpacity(0.12);
                      borderColor = AppColors.success;
                      textColor = AppColors.success;
                    } else if (isSelected && !isCorrect) {
                      bgColor = AppColors.error.withOpacity(0.12);
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                    }
                  } else if (isSelected) {
                    bgColor = AppColors.primary.withOpacity(0.1);
                    borderColor = AppColors.primary;
                    textColor = AppColors.primary;
                  }

                  return GestureDetector(
                    onTap: _answered ? null : () => _selectAnswer(option, correct),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor ?? (isDark ? AppColors.cardDark : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor ?? (isDark ? AppColors.borderDark : AppColors.border),
                          width: borderColor != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: (borderColor ?? AppColors.primary).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + e.key),
                                style: TextStyle(
                                  color: borderColor ?? AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
                          else if (_answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                        ],
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: 100 * e.key)).fadeIn().slideX(begin: 0.1, end: 0);
                }),

                if (_answered) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q['explanation'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? AppColors.textWhite70 : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentQ < _questions.length - 1 ? 'Next Question →' : 'See Results',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ).animate().fadeIn(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(bool isDark) {
    final percentage = (_score / (_questions.length * 20) * 100).clamp(0, 100);
    final passed = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(passed ? '🎉' : '💪', style: const TextStyle(fontSize: 64))
                .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              passed ? 'Great job!' : 'Keep practicing!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_score / ${_questions.length * 20}',
              style: const TextStyle(fontSize: 18, color: AppColors.textLight),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toInt()}% accuracy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: passed ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _resultStat('${_questions.length}', 'Questions', AppColors.primary),
                const SizedBox(width: 24),
                _resultStat('$_score XP', 'Earned', AppColors.xpGold),
                const SizedBox(width: 24),
                _resultStat('${percentage.toInt()}%', 'Score', AppColors.success),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() {
                _inQuiz = false;
                _currentQ = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
              }),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Try Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }

  void _selectAnswer(String answer, String correct) {
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) _score += 20;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQ++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
    );
  }

  Widget _options(List<String> opts, String selected, Function(String) onSelect, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opts.map((o) => GestureDetector(
        onTap: () => onSelect(o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected == o ? AppColors.primary : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected == o ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Text(
            o,
            style: TextStyle(
              color: selected == o ? Colors.white : (isDark ? AppColors.textWhite : AppColors.textDark),
              fontWeight: selected == o ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _categoryChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}
