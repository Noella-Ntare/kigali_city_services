import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0D1B2A);
  static const navyMid = Color(0xFF152338);
  static const navyCard = Color(0xFF1A2C42);
  static const navyLight = Color(0xFF1F3450);
  static const gold = Color(0xFFF0B429);
  static const goldDim = Color(0xFFC8952A);
  static const textPrimary = Color(0xFFE8EEF4);
  static const textMuted = Color(0xFF7A9BB5);
  static const textDim = Color(0xFF4A6480);
  static const error = Color(0xFFE74C3C);
  static const success = Color(0xFF4CAF94);
}

ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      surface: AppColors.navyCard,
      onPrimary: AppColors.navy,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    fontFamily: 'Sora',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navyMid,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textDim,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      hintStyle: const TextStyle(color: AppColors.textDim),
      labelStyle: const TextStyle(color: AppColors.textMuted),
    ),
    cardTheme: CardThemeData(
      color: AppColors.navyCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
  );
}
