import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Palette (Default)
  static const Color darkBackground = Color(0xFF0D0F12);
  static const Color darkSurface = Color(0xFF16191E);
  static const Color darkCard = Color(0xFF1E222A);
  static const Color darkBorder = Color(0xFF2B303C);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEDF0F5);
  static const Color lightBorder = Color(0xFFE2E6EE);

  // Pure OLED Pitch Black for Ultimate Focus / AOD Mode
  static const Color oledBlack = Color(0xFF000000);

  // Text Colors (Dark Mode)
  static const Color darkTextPrimary = Color(0xFFF1F3F5);
  static const Color darkTextSecondary = Color(0xFF8A92A2);
  static const Color darkTextMuted = Color(0xFF4C5566);
  static const Color aodDimText = Color(0x33F1F3F5); // ~20% opacity

  // Text Colors (Light Mode)
  static const Color lightTextPrimary = Color(0xFF111418);
  static const Color lightTextSecondary = Color(0xFF636E7B);
  static const Color lightTextMuted = Color(0xFFA0A7B5);

  // Subtle Desaturated Accents
  static const Color accentDeepWork = Color(0xFF7A88BF); // Muted slate blue
  static const Color accentPomodoro = Color(0xFFCF6A6A); // Subtle desaturated crimson
  static const Color accentShortBreak = Color(0xFF5BA793); // Muted sage/teal
  static const Color accentLongBreak = Color(0xFF9E7CC1); // Muted violet
  static const Color accentFocus = Color(0xFFD4A359); // Muted amber

  static const Color cancelRed = Color(0xFFE54D42);
  static const Color successTeal = Color(0xFF38B2AC);
}
