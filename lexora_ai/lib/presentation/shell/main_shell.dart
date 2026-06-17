import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: _shouldShowNav(location)
          ? _BottomNav(currentLocation: location, isDark: isDark)
          : null,
    );
  }

  bool _shouldShowNav(String location) {
    final noNavRoutes = ['/splash', '/onboarding', '/auth/login', '/auth/register', '/search'];
    return !noNavRoutes.any((r) => location.startsWith(r));
  }
}

class _BottomNav extends StatelessWidget {
  final String currentLocation;
  final bool isDark;

  const _BottomNav({required this.currentLocation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home', '/home'),
      _NavItem(Icons.search_rounded, Icons.search_outlined, 'Search', '/search'),
      _NavItem(Icons.psychology_rounded, Icons.psychology_outlined, 'AI Chat', '/ai-chat'),
      _NavItem(Icons.style_rounded, Icons.style_outlined, 'Cards', '/flashcards'),
      _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Progress', '/dashboard'),
    ];

    final currentIndex = items.indexWhere((i) => currentLocation.startsWith(i.route));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final isSelected = e.key == currentIndex;
              return _NavButton(
                item: e.value,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => context.go(e.value.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;
  final String route;

  _NavItem(this.selectedIcon, this.icon, this.label, this.route);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? AppColors.primary : (isDark ? AppColors.textWhite50 : AppColors.textLight),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
