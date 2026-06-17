import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class IeltsScreen extends StatelessWidget {
  const IeltsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final modules = [
      _IeltsModule('Vocabulary', '🔤', 'Master 3000+ IELTS words by band', AppColors.primary, '/quiz', 0.72),
      _IeltsModule('Writing', '✍️', 'Task 1 & Task 2 practice with AI feedback', AppColors.secondary, '/ai-chat', 0.45),
      _IeltsModule('Speaking', '🗣️', 'Part 1, 2, 3 mock tests', AppColors.accent, '/speaking', 0.58),
      _IeltsModule('Reading', '📖', 'Timed passage practice', AppColors.success, '/reading', 0.30),
      _IeltsModule('Listening', '👂', 'Section 1-4 audio tests', AppColors.levelPurple, '/quiz', 0.20),
      _IeltsModule('Grammar', '📐', 'Common IELTS grammar errors', AppColors.info, '/ai-chat', 0.65),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('IELTS Hub', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Band score estimator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Estimated Band Score',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        const Text('6.5', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800, height: 1)),
                        const SizedBox(height: 4),
                        const Text('Upper Intermediate • B2',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Target: Band 7.0 →',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      _bandCircle('R', '7.0', AppColors.success),
                      const SizedBox(height: 8),
                      _bandCircle('L', '6.5', AppColors.secondary),
                      const SizedBox(height: 8),
                      _bandCircle('W', '6.0', AppColors.accent),
                      const SizedBox(height: 8),
                      _bandCircle('S', '6.5', AppColors.info),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text('Study Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: modules.length,
              itemBuilder: (context, i) => _ModuleCard(module: modules[i], isDark: isDark)
                .animate(delay: Duration(milliseconds: 100 + i * 60)).fadeIn().slideY(begin: 0.2, end: 0),
            ),

            const SizedBox(height: 24),

            // IELTS tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: AppColors.warning, size: 18),
                      SizedBox(width: 8),
                      Text('AI Study Tips', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Learn 20 new academic words daily from the AWL (Academic Word List)',
                    'Practice writing introductions — they\'re worth 25% of your Writing score',
                    'Focus on paraphrasing for Reading — never copy the question exactly',
                  ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                        Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.4))),
                      ],
                    ),
                  )),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _bandCircle(String skill, String score, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(skill, style: const TextStyle(color: Colors.white70, fontSize: 9)),
          Text(score, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

class _IeltsModule {
  final String title;
  final String emoji;
  final String desc;
  final Color color;
  final String route;
  final double progress;

  _IeltsModule(this.title, this.emoji, this.desc, this.color, this.route, this.progress);
}

class _ModuleCard extends StatelessWidget {
  final _IeltsModule module;
  final bool isDark;

  const _ModuleCard({required this.module, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(module.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: module.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(module.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: module.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(module.progress * 100).toInt()}%',
                    style: TextStyle(color: module.color, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              module.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module.desc,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: module.progress,
                backgroundColor: module.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(module.color),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
