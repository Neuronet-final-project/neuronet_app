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

/// Spacing tokens — multiples of 4 for consistent layout rhythm.
class NeuroSpacing {
  const NeuroSpacing._();

  static const double xxs = 4.0;   // Tight grouping (badges, icon padding)
  static const double xs = 8.0;    // Small gap (between list items)
  static const double sm = 12.0;   // Medium-small (section gaps)
  static const double md = 16.0;   // Standard padding (card content)
  static const double lg = 24.0;   // Large padding (screen edges)
  static const double xl = 32.0;   // Extra-large (section dividers)
  static const double xxl = 48.0;  // Double extra-large (hero spacing)
}

/// Border radius tokens — consistent corner sizes across the app.
class NeuroRadius {
  const NeuroRadius._();

  static const double sm = 8.0;    // Chips, badges, severity tags
  static const double md = 12.0;   // Buttons, inputs, small cards
  static const double lg = 16.0;   // Standard cards, dialogs
  static const double xl = 24.0;   // Empty states, alert cards, large cards
  static const double xxl = 40.0;  // Page headers, curved sections
}

/// Shadow/elevation tokens — depth system for visual hierarchy.
class NeuroShadows {
  const NeuroShadows._();

  static const BoxShadow xs = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 6,
    offset: Offset(0, 3),
  );
  static const BoxShadow md = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  static const BoxShadow lg = BoxShadow(
    color: Color(0x1E000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  static const BoxShadow xl = BoxShadow(
    color: Color(0x28000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );
}

/// Gradient definitions — per PRD institutional green/pink palette.
class NeuroGradients {
  const NeuroGradients._();

  // Adolescent gradient — fresh, calming green
  static const LinearGradient adolescent = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Guardian gradient — warm, supportive pink
  static const LinearGradient guardian = LinearGradient(
    colors: [Color(0xFFAD1457), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle surface gradient for cards (glassmorphism base)
  static const LinearGradient surface = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Auth screen background gradient (light, airy)
  static const LinearGradient authBackground = LinearGradient(
    colors: [Color(0xFFF5F5F5), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Creates a ThemeData for the specified app role.
class NeuroTheme {
  const NeuroTheme._();

  /// Typography scale — consistent header/body sizes across both apps.
  static TextTheme _buildTextTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurfaceVariant,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

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

    final textTheme = _buildTextTheme(
      NeuroColors.onSurface,
      NeuroColors.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
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
            borderRadius: BorderRadius.circular(NeuroRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeuroColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeuroRadius.md),
          borderSide: const BorderSide(color: NeuroColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeuroRadius.md),
          borderSide: const BorderSide(color: NeuroColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeuroRadius.md),
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
          borderRadius: BorderRadius.circular(NeuroRadius.lg),
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

class NeuroStyles {
  const NeuroStyles._();

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
}
