import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/word_detail/word_detail_screen.dart';
import '../../presentation/screens/ai_chat/ai_chat_screen.dart';
import '../../presentation/screens/flashcards/flashcards_screen.dart';
import '../../presentation/screens/quiz/quiz_screen.dart';
import '../../presentation/screens/speaking/speaking_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/ielts/ielts_screen.dart';
import '../../presentation/screens/vocabulary_bank/vocabulary_bank_screen.dart';
import '../../presentation/screens/reading/reading_screen.dart';
import '../../presentation/screens/camera/camera_screen.dart';
import '../../presentation/shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/ai-chat', builder: (_, __) => const AiChatScreen()),
        GoRoute(path: '/flashcards', builder: (_, __) => const FlashcardsScreen()),
        GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
        GoRoute(path: '/speaking', builder: (_, __) => const SpeakingScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/ielts', builder: (_, __) => const IeltsScreen()),
        GoRoute(path: '/vocabulary-bank', builder: (_, __) => const VocabularyBankScreen()),
        GoRoute(path: '/reading', builder: (_, __) => const ReadingScreen()),
        GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(
          path: '/word/:word',
          builder: (_, state) => WordDetailScreen(word: state.pathParameters['word'] ?? ''),
        ),
      ],
    ),
  ],
);
