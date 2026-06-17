import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(user: user, isDark: isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatsSection(user: user, isDark: isDark).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  _MenuSection(isDark: isDark).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ProfileHeader({this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1730), const Color(0xFF2A2440)]
              : [const Color(0xFFEEECFF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.displayName.substring(0, 1).toUpperCase() ?? 'L',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.backgroundDark : Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Lexora User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'user@lexora.ai',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _badge('Level ${user?.level ?? 1}', AppColors.primary),
                const SizedBox(width: 8),
                _badge('${user?.streakDays ?? 0} Day Streak 🔥', AppColors.streakOrange),
                if (user?.isPremium == true) ...[
                  const SizedBox(width: 8),
                  _badge('⭐ Premium', AppColors.xpGold),
                ],
              ],
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
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _StatsSection({this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _stat('${user?.wordsLearned ?? 124}', 'Words\nLearned', AppColors.primary),
          _divider(),
          _stat('${user?.xp ?? 1240}', 'Total\nXP', AppColors.xpGold),
          _divider(),
          _stat('${((user?.masteryScore ?? 0.68) * 100).toInt()}%', 'Mastery\nScore', AppColors.success),
          _divider(),
          _stat('${user?.streakDays ?? 7}', 'Day\nStreak', AppColors.streakOrange),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.3)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

class _MenuSection extends ConsumerWidget {
  final bool isDark;
  const _MenuSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(Icons.bar_chart_rounded, 'My Progress', 'Track your learning journey', '/dashboard'),
      _MenuItem(Icons.bookmark_rounded, 'Word Bank', 'Your saved vocabulary', '/vocabulary-bank'),
      _MenuItem(Icons.style_rounded, 'My Flashcards', 'Review your cards', '/flashcards'),
      _MenuItem(Icons.workspace_premium_rounded, 'Upgrade to Premium', 'Unlock all features', null, isHighlight: true),
      _MenuItem(Icons.settings_rounded, 'Settings', 'App preferences', '/settings'),
      _MenuItem(Icons.help_outline_rounded, 'Help & Support', 'Get assistance', null),
    ];

    return Column(
      children: [
        ...menuItems.map((item) => _MenuTile(item: item, isDark: isDark,
          onTap: item.route != null ? () => context.go(item.route!) : null)),
        const SizedBox(height: 8),
        ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
          ),
          title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          onTap: () {
            ref.read(userProvider.notifier).signOut();
            context.go('/auth/login');
          },
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final bool isHighlight;

  _MenuItem(this.icon, this.title, this.subtitle, this.route, {this.isHighlight = false});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isDark;
  final VoidCallback? onTap;

  const _MenuTile({required this.item, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item.isHighlight) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          tileColor: AppColors.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
          onTap: onTap,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: AppColors.primary, size: 20),
        ),
        title: Text(item.title,
          style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        trailing: Icon(Icons.chevron_right_rounded,
          color: isDark ? AppColors.textWhite30 : AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
