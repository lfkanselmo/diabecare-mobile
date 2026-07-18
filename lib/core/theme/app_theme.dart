import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

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

    return _build(colorScheme: colorScheme, scaffoldBackground: AppColors.backgroundLight);
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

    return _build(colorScheme: colorScheme, scaffoldBackground: AppColors.backgroundDark);
  }

  static ThemeData _build({required ColorScheme colorScheme, required Color scaffoldBackground}) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme, fontFamily: 'Inter');
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg));
    final fieldShape = OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md));

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: _textTheme(base.textTheme),
      cardTheme: CardThemeData(shape: shape, margin: const EdgeInsets.all(AppSpacing.s2)),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: fieldShape,
        enabledBorder: fieldShape,
        focusedBorder: fieldShape.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
        ),
      ),
    );
  }

  /// Escala tipográfica de marca (`--font-size-*` en `_tokens.scss`) sobre la
  /// base del `TextTheme` de Material 3 — se preserva su `fontWeight`/altura
  /// de línea por rol (ya cumple contraste/Dynamic Type, ver
  /// DESIGN_GUIDELINES.md sección 6), solo se ajusta el tamaño.
  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    headlineMedium: base.headlineMedium?.copyWith(fontSize: AppFontSizes.metric),
    headlineSmall: base.headlineSmall?.copyWith(fontSize: AppFontSizes.xl2),
    titleLarge: base.titleLarge?.copyWith(fontSize: AppFontSizes.xl),
    titleMedium: base.titleMedium?.copyWith(fontSize: AppFontSizes.lg),
    titleSmall: base.titleSmall?.copyWith(fontSize: AppFontSizes.md),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: AppFontSizes.md),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: AppFontSizes.sm),
    bodySmall: base.bodySmall?.copyWith(fontSize: AppFontSizes.xs),
    labelLarge: base.labelLarge?.copyWith(fontSize: AppFontSizes.sm),
    labelMedium: base.labelMedium?.copyWith(fontSize: AppFontSizes.xs),
    labelSmall: base.labelSmall?.copyWith(fontSize: AppFontSizes.xs),
  );
}
