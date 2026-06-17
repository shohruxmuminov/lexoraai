import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/word_provider.dart';

class VocabularyBankScreen extends ConsumerWidget {
  const VocabularyBankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);

    final folders = [
      _Folder('⭐ Favorites', favorites.length, AppColors.xpGold, true),
      _Folder('🎓 IELTS Words', 150, AppColors.primary, false),
      _Folder('💼 Business', 45, AppColors.secondary, false),
      _Folder('📰 Academic', 88, AppColors.levelPurple, false),
      _Folder('💬 Daily Life', 120, AppColors.accent, false),
      _Folder('🔬 Science', 32, AppColors.info, false),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('Word Bank', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showCreateFolder(context, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                _statPill('${favorites.length} Saved', AppColors.primary, isDark),
                const SizedBox(width: 8),
                _statPill('435 Total', AppColors.secondary, isDark),
                const SizedBox(width: 8),
                _statPill('6 Folders', AppColors.accent, isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Folders
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...folders.asMap().entries.map((e) => _FolderTile(
                  folder: e.value,
                  isDark: isDark,
                  onTap: () => _openFolder(context, e.value),
                ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().slideX(begin: -0.1, end: 0)),

                const SizedBox(height: 16),

                // Recent words section
                Text('Recently Saved',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 12),

                if (favorites.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.textLight.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('No saved words yet', style: TextStyle(color: AppColors.textLight)),
                          const SizedBox(height: 8),
                          const Text('Search a word and bookmark it!',
                            style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ...favorites.take(5).map((w) => _WordTile(word: w, isDark: isDark)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  void _openFolder(BuildContext context, _Folder folder) {}

  void _showCreateFolder(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Folder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Folder name (e.g. "Medical Terms")',
                prefixIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Create'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

class _Folder {
  final String name;
  final int count;
  final Color color;
  final bool isDefault;

  _Folder(this.name, this.count, this.color, this.isDefault);
}

class _FolderTile extends StatelessWidget {
  final _Folder folder;
  final bool isDark;
  final VoidCallback onTap;

  const _FolderTile({required this.folder, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: folder.color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: folder.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(folder.name.substring(0, 2), style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name.substring(3),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textDark),
                  ),
                  Text('${folder.count} words',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.textWhite30 : AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  final dynamic word;
  final bool isDark;

  const _WordTile({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pos = word.meanings.isNotEmpty ? word.meanings.first.partOfSpeech : '';
    final def = word.meanings.isNotEmpty && word.meanings.first.definitions.isNotEmpty
        ? word.meanings.first.definitions.first.definition
        : '';

    return GestureDetector(
      onTap: () => context.go('/word/${word.word}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(word.word,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(width: 8),
                      if (pos.isNotEmpty)
                        Text(pos,
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  if (def.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(def, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.bookmark_rounded, color: AppColors.xpGold, size: 18),
          ],
        ),
      ),
    );
  }
}
