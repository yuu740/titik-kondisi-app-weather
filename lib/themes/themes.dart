import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightText),
    bodyMedium: TextStyle(color: AppColors.lightText),
    headlineMedium: TextStyle(
      color: AppColors.lightText,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardColor: Colors.grey[50],
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.lightAccent),
    trackColor: WidgetStateProperty.all(
      AppColors.lightPrimary.withOpacity(0.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightAccent),
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkText),
    bodyMedium: TextStyle(color: AppColors.darkText),
    headlineMedium: TextStyle(
      color: AppColors.darkText,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardColor: Colors.grey[850],
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.darkAccent),
    trackColor: WidgetStateProperty.all(AppColors.darkPrimary.withOpacity(0.5)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkAccent),
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
