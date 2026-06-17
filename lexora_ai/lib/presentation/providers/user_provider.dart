import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/app_constants.dart';

class UserState {
  final UserEntity? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  UserState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    // Firebase Auth integration goes here
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: UserEntity(
        id: 'demo_user',
        email: email,
        displayName: 'Lexora User',
        xp: 1240,
        level: 3,
        streakDays: 7,
        wordsLearned: 124,
        masteryScore: 0.68,
        dailyGoalWords: 20,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: const UserEntity(
        id: 'google_user',
        email: 'user@gmail.com',
        displayName: 'Google User',
      ),
    );
  }

  Future<void> signOut() async {
    state = const UserState();
  }

  void addXp(int amount) {
    if (state.user == null) return;
    final newXp = state.user!.xp + amount;
    final newLevel = (newXp / 500).floor() + 1;
    state = state.copyWith(
      user: state.user!.copyWith(xp: newXp, level: newLevel),
    );
  }

  void incrementWordsLearned() {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(
        wordsLearned: state.user!.wordsLearned + 1,
        xp: state.user!.xp + AppConstants.xpPerWord,
      ),
    );
  }

  void updateStreak() {
    if (state.user == null) return;
    final now = DateTime.now();
    final last = state.user!.lastActiveDate;
    int streak = state.user!.streakDays;

    if (last != null) {
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    state = state.copyWith(
      user: state.user!.copyWith(
        streakDays: streak,
        lastActiveDate: now,
      ),
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
