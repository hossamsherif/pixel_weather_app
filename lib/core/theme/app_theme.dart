import 'package:flutter/material.dart';

@immutable
class PixelWeatherTokens extends ThemeExtension<PixelWeatherTokens> {
  const PixelWeatherTokens({
    required this.border,
    required this.hudFill,
    required this.forecastCardBorder,
    required this.forecastCardFill,
    required this.stateCardAccent,
    required this.stateCardFill,
    required this.favoriteRowAccent,
    required this.spriteBackdrop,
    required this.spriteFrame,
    required this.spriteShadow,
    required this.temperatureAccent,
    required this.statAccent,
  });

  final Color border;
  final Color hudFill;
  final Color forecastCardBorder;
  final Color forecastCardFill;
  final Color stateCardAccent;
  final Color stateCardFill;
  final Color favoriteRowAccent;
  final Color spriteBackdrop;
  final Color spriteFrame;
  final Color spriteShadow;
  final Color temperatureAccent;
  final Color statAccent;

  static PixelWeatherTokens of(BuildContext context) {
    return Theme.of(context).extension<PixelWeatherTokens>()!;
  }

  @override
  PixelWeatherTokens copyWith({
    Color? border,
    Color? hudFill,
    Color? forecastCardBorder,
    Color? forecastCardFill,
    Color? stateCardAccent,
    Color? stateCardFill,
    Color? favoriteRowAccent,
    Color? spriteBackdrop,
    Color? spriteFrame,
    Color? spriteShadow,
    Color? temperatureAccent,
    Color? statAccent,
  }) {
    return PixelWeatherTokens(
      border: border ?? this.border,
      hudFill: hudFill ?? this.hudFill,
      forecastCardBorder: forecastCardBorder ?? this.forecastCardBorder,
      forecastCardFill: forecastCardFill ?? this.forecastCardFill,
      stateCardAccent: stateCardAccent ?? this.stateCardAccent,
      stateCardFill: stateCardFill ?? this.stateCardFill,
      favoriteRowAccent: favoriteRowAccent ?? this.favoriteRowAccent,
      spriteBackdrop: spriteBackdrop ?? this.spriteBackdrop,
      spriteFrame: spriteFrame ?? this.spriteFrame,
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
      forecastCardBorder: Color.lerp(
        forecastCardBorder,
        other.forecastCardBorder,
        t,
      )!,
      forecastCardFill: Color.lerp(
        forecastCardFill,
        other.forecastCardFill,
        t,
      )!,
      stateCardAccent: Color.lerp(stateCardAccent, other.stateCardAccent, t)!,
      stateCardFill: Color.lerp(stateCardFill, other.stateCardFill, t)!,
      favoriteRowAccent: Color.lerp(
        favoriteRowAccent,
        other.favoriteRowAccent,
        t,
      )!,
      spriteBackdrop: Color.lerp(spriteBackdrop, other.spriteBackdrop, t)!,
      spriteFrame: Color.lerp(spriteFrame, other.spriteFrame, t)!,
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
          forecastCardBorder: scheme.outlineVariant,
          forecastCardFill: scheme.surfaceContainerLowest,
          stateCardAccent: scheme.primary,
          stateCardFill: scheme.primaryContainer.withValues(alpha: 0.18),
          favoriteRowAccent: scheme.secondary,
          spriteBackdrop: scheme.primaryContainer.withValues(alpha: 0.16),
          spriteFrame: scheme.primary,
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
          forecastCardBorder: scheme.outlineVariant,
          forecastCardFill: scheme.surfaceContainerLow,
          stateCardAccent: scheme.primary,
          stateCardFill: scheme.primaryContainer.withValues(alpha: 0.16),
          favoriteRowAccent: scheme.secondary,
          spriteBackdrop: scheme.primaryContainer.withValues(alpha: 0.18),
          spriteFrame: scheme.primary,
          spriteShadow: Colors.black.withValues(alpha: 0.48),
          temperatureAccent: const Color(0xFFFBBF24),
          statAccent: scheme.tertiary,
        ),
      ],
    );
  }
}
