import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.psychology_alt_rounded,
      gradient: AppColors.primaryGradient,
      title: 'AI-Powered Dictionary',
      subtitle: 'Get deep explanations, examples, pronunciations, and cultural notes for every English word.',
      features: ['GPT-4o explanations', 'Native speaker audio', 'CEFR & IELTS levels'],
    ),
    _OnboardingPage(
      icon: Icons.style_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF00C6A7), Color(0xFF5B4FE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Smart Flashcards & SRS',
      subtitle: 'Scientifically proven spaced repetition helps you never forget a word again.',
      features: ['Leitner System', 'Picture & Audio cards', 'Personalized schedule'],
    ),
    _OnboardingPage(
      icon: Icons.record_voice_over_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF8C42), Color(0xFFFF4D6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Speak & Score',
      subtitle: 'Practice pronunciation and get instant AI feedback on your accuracy.',
      features: ['Real-time scoring', 'Native comparison', 'IELTS speaking prep'],
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF9B59B6), Color(0xFF5B4FE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Compete & Achieve',
      subtitle: 'Earn XP, maintain streaks, and compete on the global leaderboard.',
      features: ['Daily challenges', 'Achievement badges', 'Global leaderboard'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),

          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth/login'),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started
                    _currentPage < _pages.length - 1
                        ? _circleButton(
                            icon: Icons.arrow_forward_rounded,
                            onTap: () => _controller.nextPage(
                              duration: 400.ms,
                              curve: Curves.easeInOut,
                            ),
                          )
                        : _getStartedButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(page.icon, color: Colors.white, size: 60),
              )
                  .animate(key: ValueKey(page.title))
                  .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              )
                  .animate(key: ValueKey('title_${page.title}'))
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),

              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              )
                  .animate(key: ValueKey('sub_${page.title}'))
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 32),

              // Features
              ...page.features.asMap().entries.map((e) => _featureRow(e.value, e.key)),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String text, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 450 + index * 100))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 26),
      ),
    );
  }

  Widget _getStartedButton() {
    return GestureDetector(
      onTap: () => context.go('/auth/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingPage {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String subtitle;
  final List<String> features;

  _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}
