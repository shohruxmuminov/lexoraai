import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette – deep violet-blue
  static const Color primary = Color(0xFF5B4FE8);
  static const Color primaryLight = Color(0xFF7B70FF);
  static const Color primaryDark = Color(0xFF3D34C8);
  static const Color primaryGlow = Color(0xFF8B7FFF);

  // Secondary – vivid teal
  static const Color secondary = Color(0xFF00C6A7);
  static const Color secondaryLight = Color(0xFF00E5C1);
  static const Color secondaryDark = Color(0xFF00A08A);

  // Accent – amber-orange
  static const Color accent = Color(0xFFFF8C42);
  static const Color accentLight = Color(0xFFFFAD71);
  static const Color accentDark = Color(0xFFE06B1F);

  // Success / Error / Warning
  static const Color success = Color(0xFF2DD4B0);
  static const Color error = Color(0xFFFF4D6A);
  static const Color warning = Color(0xFFFFBB33);
  static const Color info = Color(0xFF5BB8F5);

  // Gamification
  static const Color xpGold = Color(0xFFFFD700);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color levelPurple = Color(0xFF9B59B6);

  // CEFR colors
  static const Color cefrA1 = Color(0xFF4CAF50);
  static const Color cefrA2 = Color(0xFF8BC34A);
  static const Color cefrB1 = Color(0xFF2196F3);
  static const Color cefrB2 = Color(0xFF03A9F4);
  static const Color cefrC1 = Color(0xFF9C27B0);
  static const Color cefrC2 = Color(0xFF673AB7);

  // Light mode surfaces
  static const Color backgroundLight = Color(0xFFF6F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E6F9);

  // Dark mode surfaces
  static const Color backgroundDark = Color(0xFF0E0C1E);
  static const Color surfaceDark = Color(0xFF1A1730);
  static const Color cardDark = Color(0xFF211E38);
  static const Color borderDark = Color(0xFF2E2A4A);

  // Text
  static const Color textDark = Color(0xFF1A1740);
  static const Color textMedium = Color(0xFF5A5680);
  static const Color textLight = Color(0xFF9E9BBF);
  static const Color textWhite = Color(0xFFF0EEFF);
  static const Color textWhite70 = Color(0xB3F0EEFF);
  static const Color textWhite50 = Color(0x80F0EEFF);
  static const Color textWhite30 = Color(0x4DF0EEFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B4FE8), Color(0xFF8B7FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00C6A7), Color(0xFF00E5C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFBB33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B4FE8), Color(0xFF00C6A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0E0C1E), Color(0xFF1A1730)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x335B4FE8), Color(0x005B4FE8)],
    radius: 1.0,
  );
}
