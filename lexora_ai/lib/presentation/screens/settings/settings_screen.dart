import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final nativeLanguageProvider = StateProvider<String>((ref) => 'Uzbek');
final dailyGoalProvider = StateProvider<int>((ref) => 20);
final notificationsProvider = StateProvider<bool>((ref) => true);
final soundProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final nativeLang = ref.watch(nativeLanguageProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final notifications = ref.watch(notificationsProvider);
    final sound = ref.watch(soundProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('Settings', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Appearance', isDark, [
            _SettingTile(
              icon: Icons.palette_rounded,
              iconColor: AppColors.primary,
              title: 'Theme',
              subtitle: theme == ThemeMode.dark ? 'Dark' : theme == ThemeMode.light ? 'Light' : 'System',
              isDark: isDark,
              onTap: () => _showThemePicker(context, ref),
            ),
          ]),

          _section('Learning', isDark, [
            _SettingTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.secondary,
              title: 'Native Language',
              subtitle: nativeLang,
              isDark: isDark,
              onTap: () => _showLanguagePicker(context, ref),
            ),
            _SettingTile(
              icon: Icons.flag_rounded,
              iconColor: AppColors.accent,
              title: 'Daily Goal',
              subtitle: '$dailyGoal words per day',
              isDark: isDark,
              onTap: () => _showGoalPicker(context, ref),
            ),
          ]),

          _section('Notifications', isDark, [
            _SwitchTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.info,
              title: 'Push Notifications',
              subtitle: 'Daily reminders and achievements',
              value: notifications,
              isDark: isDark,
              onChanged: (v) => ref.read(notificationsProvider.notifier).state = v,
            ),
            _SwitchTile(
              icon: Icons.volume_up_rounded,
              iconColor: AppColors.success,
              title: 'Sound Effects',
              subtitle: 'Audio feedback during learning',
              value: sound,
              isDark: isDark,
              onChanged: (v) => ref.read(soundProvider.notifier).state = v,
            ),
          ]),

          _section('AI & API', isDark, [
            _SettingTile(
              icon: Icons.key_rounded,
              iconColor: AppColors.primary,
              title: 'OpenAI API Key',
              subtitle: 'Configure your AI integration',
              isDark: isDark,
              onTap: () => _showApiKeyDialog(context),
            ),
          ]),

          _section('About', isDark, [
            _SettingTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textLight,
              title: 'App Version',
              subtitle: '1.0.0 (Build 1)',
              isDark: isDark,
              onTap: null,
            ),
            _SettingTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.textLight,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              isDark: isDark,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 1,
            )),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...[ThemeMode.system, ThemeMode.light, ThemeMode.dark].map((m) => ListTile(
              leading: Icon(m == ThemeMode.dark ? Icons.dark_mode_rounded : m == ThemeMode.light ? Icons.light_mode_rounded : Icons.brightness_auto_rounded),
              title: Text(m == ThemeMode.dark ? 'Dark' : m == ThemeMode.light ? 'Light' : 'System'),
              trailing: ref.watch(themeProvider) == m ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                ref.read(themeProvider.notifier).state = m;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final langs = ['Uzbek', 'Russian', 'Turkish', 'Arabic', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Native Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...langs.map((l) => ListTile(
              title: Text(l),
              trailing: ref.watch(nativeLanguageProvider) == l ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                ref.read(nativeLanguageProvider.notifier).state = l;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref) {
    final goals = [5, 10, 15, 20, 30, 50];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Daily Word Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...goals.map((g) => ListTile(
              title: Text('$g words per day'),
              trailing: ref.watch(dailyGoalProvider) == g ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                ref.read(dailyGoalProvider.notifier).state = g;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('OpenAI API Key'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'sk-...'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Store API key securely
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
          color: isDark ? Colors.white : AppColors.textDark)),
      subtitle: Text(subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.textWhite30 : AppColors.textLight)
          : null,
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
          color: isDark ? Colors.white : AppColors.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
