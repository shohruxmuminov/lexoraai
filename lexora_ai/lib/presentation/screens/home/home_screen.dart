import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/word_provider.dart';
import '../../widgets/common/gradient_card.dart';
import '../../widgets/word/word_of_day_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Lexora AI',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                onPressed: () {},
              ),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Greeting
                  Text(
                    _greeting(user?.displayName ?? 'Learner'),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 4),

                  Text(
                    'Keep up the great work! 🔥',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 20),

                  // Stats row
                  _StatsRow(user: user).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Search bar
                  _SearchBar().animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ).animate(delay: 350.ms).fadeIn(),

                  const SizedBox(height: 14),

                  _QuickActions().animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Word of the day
                  Text(
                    'Word of the Day',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ).animate(delay: 450.ms).fadeIn(),

                  const SizedBox(height: 14),

                  const WordOfDayCard().animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Daily challenge
                  _DailyChallenge().animate(delay: 550.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Continue learning
                  Text(
                    'Continue Learning',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ).animate(delay: 600.ms).fadeIn(),

                  const SizedBox(height: 14),

                  _ContinueLearning().animate(delay: 650.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening';
    return 'Good $part, ${name.split(' ').first}! 👋';
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic user;
  const _StatsRow({this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.streakOrange,
          value: '${user?.streakDays ?? 0}',
          label: 'Streak',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.xpGold,
          value: '${user?.xp ?? 0}',
          label: 'XP',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.secondary,
          value: '${user?.wordsLearned ?? 0}',
          label: 'Words',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.star_rounded,
          iconColor: AppColors.primary,
          value: 'Lv.${user?.level ?? 1}',
          label: 'Level',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite50 : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.go('/search'),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              'Search any word...',
              style: TextStyle(
                color: isDark ? AppColors.textWhite30 : AppColors.textLight,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.style_rounded, 'Flashcards', AppColors.primary, '/flashcards'),
      _QA(Icons.quiz_rounded, 'Quiz', AppColors.secondary, '/quiz'),
      _QA(Icons.chat_rounded, 'AI Chat', AppColors.accent, '/ai-chat'),
      _QA(Icons.record_voice_over_rounded, 'Speaking', AppColors.error, '/speaking'),
      _QA(Icons.auto_stories_rounded, 'IELTS', AppColors.levelPurple, '/ielts'),
      _QA(Icons.camera_alt_rounded, 'Scanner', AppColors.info, '/camera'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _QuickActionTile(action: actions[i]),
    );
  }
}

class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  _QA(this.icon, this.label, this.color, this.route);
}

class _QuickActionTile extends StatelessWidget {
  final _QA action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.go(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: action.color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4FE8), Color(0xFF8B7FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔥 Daily Challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn 20 IELTS words today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '12 / 20 completed',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.go('/quiz'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _LearningItem('Business Vocabulary', 'B2', Icons.business_center_rounded, AppColors.secondary, 0.45),
      _LearningItem('IELTS Academic Words', 'C1', Icons.school_rounded, AppColors.levelPurple, 0.72),
      _LearningItem('Daily Conversation', 'B1', Icons.chat_bubble_rounded, AppColors.accent, 0.30),
    ];

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.level,
                            style: TextStyle(
                              color: item.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: item.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(item.color),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(item.progress * 100).toInt()}% complete',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textWhite30 : AppColors.textLight,
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _LearningItem {
  final String title;
  final String level;
  final IconData icon;
  final Color color;
  final double progress;
  _LearningItem(this.title, this.level, this.icon, this.color, this.progress);
}
