import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('My Progress',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Progress
            _XpCard(user: user, isDark: isDark).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // Stats grid
            _StatsGrid(user: user, isDark: isDark).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 24),

            // Weekly chart
            _sectionTitle('Weekly Activity', isDark),
            const SizedBox(height: 14),
            _WeeklyChart(isDark: isDark).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 24),

            // Skills breakdown
            _sectionTitle('Skills Breakdown', isDark),
            const SizedBox(height: 14),
            _SkillsBreakdown(isDark: isDark).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 24),

            // Achievements
            _sectionTitle('Recent Achievements', isDark),
            const SizedBox(height: 14),
            _AchievementsRow().animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
    );
  }
}

class _XpCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _XpCard({this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final xp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final progress = (xp % 500) / 500.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Level $level',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
              const Spacer(),
              Text('$xp XP total',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${xp % 500} / 500 XP',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${((1 - progress) * 500).toInt()} XP until Level ${level + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _StatsGrid({this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem('Words Learned', '${user?.wordsLearned ?? 124}', Icons.menu_book_rounded, AppColors.primary, '+12 this week'),
      _StatItem('Mastery Score', '${((user?.masteryScore ?? 0.68) * 100).toInt()}%', Icons.bar_chart_rounded, AppColors.secondary, '↑ 5% from last week'),
      _StatItem('Streak', '${user?.streakDays ?? 7} days 🔥', Icons.local_fire_department_rounded, AppColors.streakOrange, 'Personal best!'),
      _StatItem('Study Time', '4h 32m', Icons.timer_rounded, AppColors.accent, 'This week'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatCard(stat: stats[i], isDark: isDark),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  _StatItem(this.label, this.value, this.icon, this.color, this.subtitle);
}

class _StatCard extends StatelessWidget {
  final _StatItem stat;
  final bool isDark;

  const _StatCard({required this.stat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(stat.icon, color: stat.color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              Text(stat.label,
                style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              const SizedBox(height: 2),
              Text(stat.subtitle,
                style: TextStyle(fontSize: 10, color: stat.color, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final bool isDark;

  const _WeeklyChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final data = [8, 15, 12, 20, 18, 25, 14]; // Words per day
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: BarChart(
        BarChartData(
          maxY: 30,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark ? AppColors.borderDark : AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  days[value.toInt()],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),
          barGroups: data.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.6), AppColors.primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }
}

class _SkillsBreakdown extends StatelessWidget {
  final bool isDark;

  const _SkillsBreakdown({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final skills = [
      _Skill('Vocabulary', 0.78, AppColors.primary),
      _Skill('Grammar', 0.62, AppColors.secondary),
      _Skill('Speaking', 0.45, AppColors.accent),
      _Skill('Reading', 0.88, AppColors.success),
      _Skill('Writing', 0.55, AppColors.levelPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: skills.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(s.label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textWhite : AppColors.textDark)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s.value,
                    backgroundColor: s.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(s.color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(s.value * 100).toInt()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.color),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _Skill {
  final String label;
  final double value;
  final Color color;
  _Skill(this.label, this.value, this.color);
}

class _AchievementsRow extends StatelessWidget {
  final List<Map<String, dynamic>> _achievements = [
    {'emoji': '🔥', 'title': '7-Day Streak', 'color': 0xFFFF6B35},
    {'emoji': '📚', 'title': '100 Words', 'color': 0xFF5B4FE8},
    {'emoji': '🎯', 'title': 'Perfect Quiz', 'color': 0xFF00C6A7},
    {'emoji': '⚡', 'title': 'Speed Learner', 'color': 0xFFFFD700},
    {'emoji': '🗣️', 'title': 'Speaker', 'color': 0xFFFF4D6A},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _achievements.length,
        itemBuilder: (context, i) {
          final a = _achievements[i];
          final color = Color(a['color'] as int);
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(a['emoji'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(a['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700),
                  maxLines: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}
