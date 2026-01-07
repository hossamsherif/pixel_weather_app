import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 3,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: scheme.outlineVariant, width: 1.2),
        ),
      ),
    );
  }
}
