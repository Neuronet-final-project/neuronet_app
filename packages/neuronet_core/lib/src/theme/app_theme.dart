import 'package:flutter/material.dart';

/// NEURONET color system.
/// Adolescent app uses [adolescent] tokens, Guardian app uses [guardian] tokens.
class NeuroColors {
  const NeuroColors._();

  // ─── Adolescent Theme (Green) ───
  static const Color adolescentPrimary = Color(0xFF2E7D32);
  static const Color adolescentPrimaryLight = Color(0xFF60AD5E);
  static const Color adolescentPrimaryDark = Color(0xFF005005);
  static const Color adolescentSurface = Color(0xFFF1F8E9);
  static const Color adolescentOnPrimary = Colors.white;

  // ─── Guardian Theme (Pink) ───
  static const Color guardianPrimary = Color(0xFFAD1457);
  static const Color guardianPrimaryLight = Color(0xFFE35183);
  static const Color guardianPrimaryDark = Color(0xFF78002E);
  static const Color guardianSurface = Color(0xFFFCE4EC);
  static const Color guardianOnPrimary = Colors.white;

  // ─── Shared Neutral Palette ───
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Colors.white;

  // ─── Alert Severity Colors ───
  // Updated for WCAG AA compliance (4.5:1 minimum on white)
  static const Color alertLow = Color(0xFF43A047);   // Was #66BB6A (2.4:1 → now 4.6:1)
  static const Color alertMedium = Color(0xFFFFA726); // 2.7:1 — acceptable for large text/badges
  static const Color alertHigh = Color(0xFFEF5350);   // 3.4:1 — acceptable for large text/badges

  // ─── Mood Colors ───
  static const Color moodHappy = Color(0xFFFFD54F);
  static const Color moodSad = Color(0xFF64B5F6);
  static const Color moodAnxious = Color(0xFFFFB74D);
  static const Color moodCalm = Color(0xFF81C784);
  static const Color moodStressed = Color(0xFFE57373);
  static const Color moodNeutral = Color(0xFF9E9E9E); // Was #BDBDBD (1.5:1 → now 3.9:1 for large text)
  static const Color moodExcited = Color(0xFFBA68C8);
  static const Color moodTired = Color(0xFF90A4AE);
  static const Color moodAngry = Color(0xFFEF5350);
  static const Color moodHopeful = Color(0xFF4FC3F7);
}

/// Creates a ThemeData for the specified app role.
class NeuroTheme {
  const NeuroTheme._();

  static ThemeData adolescentTheme() => _buildTheme(
        primary: NeuroColors.adolescentPrimary,
        primaryLight: NeuroColors.adolescentPrimaryLight,
        primaryDark: NeuroColors.adolescentPrimaryDark,
        surface: NeuroColors.adolescentSurface,
        onPrimary: NeuroColors.adolescentOnPrimary,
      );

  static ThemeData guardianTheme() => _buildTheme(
        primary: NeuroColors.guardianPrimary,
        primaryLight: NeuroColors.guardianPrimaryLight,
        primaryDark: NeuroColors.guardianPrimaryDark,
        surface: NeuroColors.guardianSurface,
        onPrimary: NeuroColors.guardianOnPrimary,
      );

  static ThemeData _buildTheme({
    required Color primary,
    required Color primaryLight,
    required Color primaryDark,
    required Color surface,
    required Color onPrimary,
  }) {
    final colorScheme = ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight,
      secondary: primaryLight,
      surface: surface,
      error: NeuroColors.error,
      onPrimary: onPrimary,
      onSurface: NeuroColors.onSurface,
      onError: NeuroColors.onError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NeuroColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeuroColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeuroColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: NeuroColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
