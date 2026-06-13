import 'package:flutter/material.dart';

@immutable
class PixelWeatherTokens extends ThemeExtension<PixelWeatherTokens> {
  const PixelWeatherTokens({
    required this.border,
    required this.hudFill,
    required this.spriteBackdrop,
    required this.spriteShadow,
    required this.temperatureAccent,
    required this.statAccent,
  });

  final Color border;
  final Color hudFill;
  final Color spriteBackdrop;
  final Color spriteShadow;
  final Color temperatureAccent;
  final Color statAccent;

  @override
  PixelWeatherTokens copyWith({
    Color? border,
    Color? hudFill,
    Color? spriteBackdrop,
    Color? spriteShadow,
    Color? temperatureAccent,
    Color? statAccent,
  }) {
    return PixelWeatherTokens(
      border: border ?? this.border,
      hudFill: hudFill ?? this.hudFill,
      spriteBackdrop: spriteBackdrop ?? this.spriteBackdrop,
      spriteShadow: spriteShadow ?? this.spriteShadow,
      temperatureAccent: temperatureAccent ?? this.temperatureAccent,
      statAccent: statAccent ?? this.statAccent,
    );
  }

  @override
  PixelWeatherTokens lerp(ThemeExtension<PixelWeatherTokens>? other, double t) {
    if (other is! PixelWeatherTokens) {
      return this;
    }
    return PixelWeatherTokens(
      border: Color.lerp(border, other.border, t)!,
      hudFill: Color.lerp(hudFill, other.hudFill, t)!,
      spriteBackdrop: Color.lerp(spriteBackdrop, other.spriteBackdrop, t)!,
      spriteShadow: Color.lerp(spriteShadow, other.spriteShadow, t)!,
      temperatureAccent: Color.lerp(
        temperatureAccent,
        other.temperatureAccent,
        t,
      )!,
      statAccent: Color.lerp(statAccent, other.statAccent, t)!,
    );
  }
}

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
      extensions: <ThemeExtension<dynamic>>[
        PixelWeatherTokens(
          border: scheme.primary,
          hudFill: scheme.primaryContainer.withValues(alpha: 0.24),
          spriteBackdrop: const Color(0xFFE9F7FF),
          spriteShadow: scheme.shadow.withValues(alpha: 0.24),
          temperatureAccent: const Color(0xFFB45309),
          statAccent: scheme.tertiary,
        ),
      ],
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
      extensions: <ThemeExtension<dynamic>>[
        PixelWeatherTokens(
          border: scheme.primary,
          hudFill: scheme.primaryContainer.withValues(alpha: 0.22),
          spriteBackdrop: const Color(0xFF0B1F2F),
          spriteShadow: Colors.black.withValues(alpha: 0.48),
          temperatureAccent: const Color(0xFFFBBF24),
          statAccent: scheme.tertiary,
        ),
      ],
    );
  }
}
