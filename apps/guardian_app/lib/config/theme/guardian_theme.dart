import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuronet_core/neuronet_core.dart';

class GuardianTheme {
  const GuardianTheme._();

  static ThemeData build() {
    final baseTheme = NeuroTheme.guardianTheme();

    // Clean background for Bento style
    const backgroundColor = Color(0xFFF9FAFB);

    // Typography: Figtree for headlines, Noto Sans for body
    final notoSansTextTheme = GoogleFonts.notoSansTextTheme(baseTheme.textTheme);
    
    final figtreeHeadlineLarge = GoogleFonts.figtree(
      textStyle: notoSansTextTheme.headlineLarge,
      fontWeight: FontWeight.w800,
      color: NeuroColors.guardianPrimaryDark,
      letterSpacing: -1.0,
    );
    
    final figtreeHeadlineMedium = GoogleFonts.figtree(
      textStyle: notoSansTextTheme.headlineMedium,
      fontWeight: FontWeight.bold,
      color: NeuroColors.guardianPrimaryDark,
      letterSpacing: -0.5,
    );

    final figtreeTitleLarge = GoogleFonts.figtree(
      textStyle: notoSansTextTheme.titleLarge,
      fontWeight: FontWeight.bold,
      color: NeuroColors.guardianPrimaryDark,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      textTheme: notoSansTextTheme.copyWith(
        headlineLarge: figtreeHeadlineLarge,
        headlineMedium: figtreeHeadlineMedium,
        titleLarge: figtreeTitleLarge,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: backgroundColor,
        foregroundColor: NeuroColors.guardianPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        color: Colors.white,
      ),
    );
  }
}

class GuardianStyles {
  const GuardianStyles._();

  // Subtle accent gradient for primary cards
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFAD1457), Color(0xFFD81B60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color surface = Colors.white;
}
