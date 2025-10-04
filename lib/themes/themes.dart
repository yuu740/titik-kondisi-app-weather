import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightAccent,
    background: AppColors.lightBackground,
    surface: AppColors.lightCard,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightText),
    bodyMedium: TextStyle(color: AppColors.lightText),
    headlineMedium: TextStyle(
      color: AppColors.lightText,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(color: Colors.white), // Untuk text di dalam button
  ),
  cardColor: AppColors.lightCard,
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.lightPrimary),
    trackColor: WidgetStateProperty.all(
      AppColors.lightPrimary.withOpacity(0.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey.withOpacity(0.1),
    selectedColor: AppColors.lightPrimary,
    labelStyle: const TextStyle(color: AppColors.lightText),
    secondaryLabelStyle: const TextStyle(
      color: Colors.white,
    ), // Warna teks saat chip dipilih
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    selectedShadowColor: AppColors.lightPrimary.withOpacity(0.3),
    elevation: 2,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    color: AppColors.lightCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: AppColors.lightPrimary,
    unselectedItemColor: Colors.grey,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkAccent,
    background: AppColors.darkBackground,
    surface: AppColors.darkCard,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkText),
    bodyMedium: TextStyle(color: AppColors.darkText),
    headlineMedium: TextStyle(
      color: AppColors.darkText,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(
      color: AppColors.darkText,
    ), // Untuk text di dalam button
  ),
  cardColor: AppColors.darkCard,
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.darkPrimary),
    trackColor: WidgetStateProperty.all(AppColors.darkPrimary.withOpacity(0.5)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkText,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey.withOpacity(0.2),
    selectedColor: AppColors.darkPrimary,
    labelStyle: const TextStyle(color: AppColors.darkText),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.darkText,
    ), // Warna teks saat chip dipilih
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    selectedShadowColor: AppColors.darkPrimary.withOpacity(0.3),
    elevation: 2,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    color: AppColors.darkCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black.withOpacity(0.2),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: AppColors.darkAccent,
    unselectedItemColor: Colors.grey,
  ),
);
