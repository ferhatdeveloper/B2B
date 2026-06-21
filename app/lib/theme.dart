import 'package:flutter/material.dart';

/// Modern, marketplace-style theme for the Zen B2B/C2C portal.
/// Improves on the reference portal with a cleaner palette, softer surfaces,
/// rounded cards and a vibrant indigo→violet brand accent.
class AppColors {
  static const Color brand = Color(0xFF4F46E5); // indigo
  static const Color brandAlt = Color(0xFF7C3AED); // violet
  static const Color accent = Color(0xFF10B981); // emerald
  static const Color warn = Color(0xFFF59E0B); // amber
  static const Color danger = Color(0xFFEF4444); // red
  static const Color sidebar = Color(0xFF111827); // slate-900
  static const Color sidebarAlt = Color(0xFF1F2937); // slate-800
  static const Color surface = Color(0xFFF8FAFC); // slate-50
  static const Color card = Colors.white;
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandAlt],
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    primary: AppColors.brand,
    secondary: AppColors.accent,
    surface: AppColors.card,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 6,
      shadowColor: const Color(0x14101828),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEEF2F7)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    chipTheme: const ChipThemeData(
      side: BorderSide(color: Color(0xFFE2E8F0)),
    ),
  );
}
