import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/word_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchState = ref.watch(wordSearchProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
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
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search any word...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textWhite30 : AppColors.textLight,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          suffixIcon: searchState.query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: isDark ? AppColors.textWhite50 : AppColors.textLight,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _ctrl.clear();
                                    ref.read(wordSearchProvider.notifier).clear();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            ref.read(wordSearchProvider.notifier).search(v);
                          }
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Results
            Expanded(
              child: _buildBody(context, searchState, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WordSearchState state, bool isDark) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: AppColors.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textWhite50 : AppColors.textMedium,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => ref.read(wordSearchProvider.notifier).search(_ctrl.text),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              label: const Text('Try again', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }

    if (state.result != null) {
      // Navigate to word detail
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/word/${state.result!.word}');
      });
    }

    // Show recent words and suggestions
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentWords.isNotEmpty) ...[
            _sectionHeader('Recent Searches', isDark),
            const SizedBox(height: 12),
            ...state.recentWords.take(8).map((w) => _wordTile(context, w.word, w.meanings.isNotEmpty
                ? w.meanings.first.partOfSpeech
                : '', isDark)),
          ],

          const SizedBox(height: 24),

          _sectionHeader('Popular Searches', isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'ephemeral', 'resilience', 'ambiguous', 'eloquent',
              'meticulous', 'profound', 'tenacious', 'serendipity',
              'lucid', 'ponder', 'articulate', 'pragmatic',
            ].map((w) => _popularChip(context, w)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
    );
  }

  Widget _wordTile(BuildContext context, String word, String pos, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
      ),
      title: Text(
        word,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textDark,
        ),
      ),
      subtitle: pos.isNotEmpty
          ? Text(pos, style: const TextStyle(color: AppColors.textLight, fontSize: 12))
          : null,
      trailing: Icon(
        Icons.north_west_rounded,
        size: 16,
        color: isDark ? AppColors.textWhite30 : AppColors.textLight,
      ),
      onTap: () {
        _ctrl.text = word;
        ref.read(wordSearchProvider.notifier).search(word);
      },
    );
  }

  Widget _popularChip(BuildContext context, String word) {
    return GestureDetector(
      onTap: () {
        _ctrl.text = word;
        ref.read(wordSearchProvider.notifier).search(word);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Text(
          word,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }
}
