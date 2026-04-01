import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NEURONET color system — "Semantic Ink"
class NeuroColors {
  const NeuroColors._();

  // ─── Adolescent Theme ("Sanctuary") ───
  static const Color adolescentPrimary = Color(0xFF0D9488); // Teal 600
  static const Color adolescentSecondary = Color(0xFF4338CA); // Indigo 700
  static const Color adolescentSurface = Color(0xFFF0FDFA);
  static const List<Color> adolescentMesh = [
    Color(0xFFCCFBF1),
    Color(0xFFE0E7FF),
    Color(0xFFF3E8FF),
  ];

  // ─── Guardian Theme ("Command Center") ───
  static const Color commandPrimary = Color(0xFF6366F1); // Indigo 500
  static const Color commandSurface = Color(0xFF0F172A); // Slate 900
  static const Color commandCard = Color(0xFF1E293B); // Slate 800
  static const Color commandAlertPink = Color(0xFFF43F5E); // Rose 500
  static const List<Color> guardianMesh = [
    Color(0xFF0F172A),
    Color(0xFF1E1B4B), // Deep Indigo
    Color(0xFF0F172A),
  ];

  // ─── Shared Neutral Palette ───
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;

  // ─── Alert Severity Colors ───
  static const Color alertLow = Color(0xFF10B981);
  static const Color alertMedium = Color(0xFFF59E0B);
  static const Color alertHigh = Color(0xFFEF4444);
}

/// Glassmorphism mixin for premium containers.
mixin Glassmorphism {
  BoxDecoration glassDecoration({
    double opacity = 0.1,
    double blur = 20.0,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );
  }
}

class NeuroTheme {
  const NeuroTheme._();

  static ThemeData adolescentTheme() => _buildTheme(
        brightness: Brightness.light,
        primary: NeuroColors.adolescentPrimary,
        surface: NeuroColors.adolescentSurface,
        onSurface: NeuroColors.onSurface,
        background: NeuroColors.background,
      );

  static ThemeData guardianTheme() => _buildTheme(
        brightness: Brightness.dark,
        primary: NeuroColors.commandPrimary,
        surface: NeuroColors.commandSurface,
        onSurface: Colors.white,
        background: NeuroColors.commandSurface,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color onSurface,
    required Color background,
  }) {
    final baseTextTheme = brightness == Brightness.dark 
        ? ThemeData.dark().textTheme 
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        surface: surface,
        onSurface: onSurface,
        error: NeuroColors.error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme).copyWith(
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: brightness == Brightness.dark ? NeuroColors.commandCard : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: brightness == Brightness.dark ? Colors.white10 : NeuroColors.outline),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
    );
  }
}
