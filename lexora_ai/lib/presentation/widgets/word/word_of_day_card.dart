import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/word_provider.dart';

class WordOfDayCard extends ConsumerWidget {
  const WordOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordOfTheDayProvider);

    return wordAsync.when(
      loading: () => _skeleton(),
      error: (_, __) => _fallbackCard(context),
      data: (word) {
        if (word == null) return _fallbackCard(context);
        final definition = word.meanings.isNotEmpty && word.meanings.first.definitions.isNotEmpty
            ? word.meanings.first.definitions.first.definition
            : 'A fascinating English word';
        final pos = word.meanings.isNotEmpty ? word.meanings.first.partOfSpeech : '';

        return GestureDetector(
          onTap: () => context.go('/word/${word.word}'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6A7), Color(0xFF5B4FE8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Word of the Day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (word.cefrLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          word.cefrLevel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (pos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          pos,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),

                if (word.phonetic != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    word.phonetic!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Text(
                  definition,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _actionBtn(Icons.volume_up_rounded, 'Listen'),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.bookmark_border_rounded, 'Save'),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.chat_outlined, 'Ask AI'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Explore →',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _fallbackCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/word/ephemeral'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6A7), Color(0xFF5B4FE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('☀️ Word of the Day',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            const Text('ephemeral',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('/ɪˈfem.ər.əl/',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            const Text(
              'Lasting for only a short time; transitory.',
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
