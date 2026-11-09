import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFF060612);
  static const Color bg2 = Color(0xFF0C0C1D);
  static const Color bg3 = Color(0xFF14142B);
  
  static const Color border = Color(0x266366F1); // rgba(99, 102, 241, 0.15)
  static const Color borderHover = Color(0x407B5CFF);
  
  static const Color textPrimary = Color(0xFFE6EAF0);
  static const Color textSecondary = Color(0xFF7C8497);
  static const Color textMuted = Color(0xFF4A5168);
  static const Color textHero = Color(0xFF8B8BA7);
  
  static const Color accent = Color(0xFF5227FF);
  static const Color accentLight = Color(0xFF7B5CFF);
  static const Color accentGlow = Color(0x266366F1); // rgba(99, 102, 241, 0.15)
  
  static const Color green = Color(0xFF00D68F);
  static const Color greenGlow = Color(0x1F00D68F);
  
  static const Color red = Color(0xFFFF4C6A);
  static const Color redGlow = Color(0x1FFF4C6A);
  
  static const Color yellow = Color(0xFFFFB020);
  static const Color yellowGlow = Color(0x1FFFB020);
  
  static const Color pink = Color(0xFFE040FB);
  static const Color purple = Color(0xFF8B5CF6);

  // Exact Hero Gradient from the Demo Reel
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5227FF),
      Color(0xFF7B5CFF),
      Color(0xFFE040FB),
      Color(0xFFFF4C6A),
    ],
    stops: [0.0, 0.3, 0.6, 0.9],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.accent,
      cardColor: AppColors.bg2,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.bg2,
        error: AppColors.red,
      ),
    );
  }
}
