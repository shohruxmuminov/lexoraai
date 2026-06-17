import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isStudyMode = false;

  final List<Map<String, String>> _sampleCards = [
    {'word': 'Ephemeral', 'phonetic': '/ɪˈfem.ər.əl/', 'pos': 'adjective', 'definition': 'Lasting for only a short time; transitory.', 'example': 'Fame can be ephemeral — here today, gone tomorrow.', 'cefr': 'C1'},
    {'word': 'Resilience', 'phonetic': '/rɪˈzɪl.i.əns/', 'pos': 'noun', 'definition': 'The capacity to recover quickly from difficulties; toughness.', 'example': 'Her resilience in the face of adversity was remarkable.', 'cefr': 'B2'},
    {'word': 'Eloquent', 'phonetic': '/ˈel.ə.kwənt/', 'pos': 'adjective', 'definition': 'Fluent or persuasive in speaking or writing.', 'example': 'She gave an eloquent speech that moved the audience.', 'cefr': 'C1'},
    {'word': 'Meticulous', 'phonetic': '/məˈtɪk.jʊ.ləs/', 'pos': 'adjective', 'definition': 'Showing great attention to detail or being very careful.', 'example': 'He was meticulous in his research, checking every source twice.', 'cefr': 'C1'},
    {'word': 'Tenacious', 'phonetic': '/təˈneɪ.ʃəs/', 'pos': 'adjective', 'definition': 'Holding firmly to something; persistent.', 'example': 'A tenacious competitor, she never gave up.', 'cefr': 'B2'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text(
          'Flashcards',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
            label: const Text('Study', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            onPressed: () => setState(() => _isStudyMode = !_isStudyMode),
          ),
        ],
      ),
      body: _isStudyMode
          ? _buildStudyMode(isDark)
          : _buildDeckView(isDark),
    );
  }

  Widget _buildDeckView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SRS stats
          _SrsStats(isDark: isDark).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          Text(
            'Your Decks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          ..._deckData.map((d) => _DeckCard(deck: d, isDark: isDark,
            onStudy: () => setState(() => _isStudyMode = true))),

          const SizedBox(height: 16),

          // Add deck button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: const Text('Create New Deck', style: TextStyle(color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyMode(bool isDark) {
    if (_currentIndex >= _sampleCards.length) {
      return _buildCompletion(isDark);
    }

    final card = _sampleCards[_currentIndex];

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
                    '${_currentIndex + 1} / ${_sampleCards.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _isStudyMode = false;
                      _currentIndex = 0;
                      _isFlipped = false;
                    }),
                    child: const Text('Exit', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _sampleCards.length,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Flashcard
        GestureDetector(
          onTap: () => setState(() => _isFlipped = !_isFlipped),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return RotationYTransition(turns: animation, child: child);
            },
            child: _isFlipped
                ? _CardBack(card: card, isDark: isDark, key: const ValueKey('back'))
                : _CardFront(card: card, isDark: isDark, key: const ValueKey('front')),
          ),
        ),

        const Spacer(),

        // Action buttons
        if (_isFlipped)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Row(
              children: [
                Expanded(
                  child: _ratingBtn(
                    label: 'Hard',
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onTap: () => _next(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ratingBtn(
                    label: 'Good',
                    icon: Icons.check_rounded,
                    color: AppColors.secondary,
                    onTap: () => _next(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ratingBtn(
                    label: 'Easy',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    onTap: () => _next(true),
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _isFlipped = true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Show Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletion(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_sampleCards.length} cards reviewed • +${_sampleCards.length * 5} XP',
            style: const TextStyle(color: AppColors.textLight, fontSize: 15),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() {
              _currentIndex = 0;
              _isFlipped = false;
            }),
            child: const Text('Study Again'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _isStudyMode = false),
            child: const Text('Back to Decks', style: TextStyle(color: AppColors.textLight)),
          ),
        ],
      ),
    );
  }

  Widget _ratingBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _next(bool correct) {
    setState(() {
      _isFlipped = false;
      _currentIndex++;
    });
  }

  final List<Map<String, dynamic>> _deckData = [
    {'name': 'IELTS Academic', 'emoji': '🎓', 'count': 150, 'due': 12, 'color': '0xFF5B4FE8', 'progress': 0.45},
    {'name': 'Business English', 'emoji': '💼', 'count': 80, 'due': 5, 'color': '0xFF00C6A7', 'progress': 0.72},
    {'name': 'Daily Vocabulary', 'emoji': '📅', 'count': 200, 'due': 28, 'color': '0xFFFF8C42', 'progress': 0.30},
    {'name': 'Phrasal Verbs', 'emoji': '🔤', 'count': 60, 'due': 0, 'color': '0xFF9B59B6', 'progress': 0.88},
  ];
}

class _CardFront extends StatelessWidget {
  final Map<String, String> card;
  final bool isDark;

  const _CardFront({required this.card, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -30, right: -30, child: _circle(120)),
          Positioned(bottom: -40, left: -20, child: _circle(100)),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card['cefr'] ?? 'B2',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  card['word'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  card['phonetic'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  card['pos'] ?? '',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to reveal definition',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Map<String, String> card;
  final bool isDark;

  const _CardBack({required this.card, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card['word'] ?? '',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card['phonetic'] ?? '',
              style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const Divider(height: 24),
            Text(
              card['definition'] ?? '',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 3)),
              ),
              child: Text(
                '"${card['example']}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textWhite70 : AppColors.textMedium,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;

  const RotationYTransition({
    super.key,
    required Animation<double> turns,
    required this.child,
  }) : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform(
      transform: Matrix4.rotationY(animation.value * 3.14159),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _SrsStats extends StatelessWidget {
  final bool isDark;
  const _SrsStats({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _stat('45', 'Due Today', Icons.schedule_rounded),
          _divider(),
          _stat('124', 'Learned', Icons.check_circle_rounded),
          _divider(),
          _stat('78%', 'Accuracy', Icons.bar_chart_rounded),
          _divider(),
          _stat('7', 'Streak', Icons.local_fire_department_rounded),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2));
  }
}

class _DeckCard extends StatelessWidget {
  final Map<String, dynamic> deck;
  final bool isDark;
  final VoidCallback onStudy;

  const _DeckCard({required this.deck, required this.isDark, required this.onStudy});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(deck['color']));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(deck['emoji'], style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${deck['count']} cards • ${deck['due']} due',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: deck['progress'],
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onStudy,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.play_arrow_rounded, color: color, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
