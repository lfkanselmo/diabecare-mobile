import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material 3 es la base en ambas plataformas (color/tipografía de marca
/// consistentes); los widgets de navegación/diálogos se adaptan por
/// plataforma en tiempo de construcción de cada pantalla, no aquí — ver
/// DESIGN_GUIDELINES.md sección 1 (principio "adaptativo, no genérico").
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      error: AppColors.danger,
      surface: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Inter',
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryDark,
      error: AppColors.dangerDark,
      surface: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Inter',
    );
  }
}
