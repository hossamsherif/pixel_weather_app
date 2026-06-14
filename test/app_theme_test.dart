import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/core/theme/temperature_text_style.dart';

void main() {
  testWidgets('light and dark themes resolve complete PixelWeatherTokens', (
    tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      AppTheme.lightTheme(),
      AppTheme.darkTheme(),
    ]) {
      PixelWeatherTokens? tokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (BuildContext context) {
              tokens = PixelWeatherTokens.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tokens, isNotNull);
      expect(tokens!.border, isA<Color>());
      expect(tokens!.hudFill, isA<Color>());
      expect(tokens!.forecastCardBorder, isA<Color>());
      expect(tokens!.forecastCardFill, isA<Color>());
      expect(tokens!.stateCardAccent, isA<Color>());
      expect(tokens!.stateCardFill, isA<Color>());
      expect(tokens!.favoriteRowAccent, isA<Color>());
      expect(tokens!.spriteBackdrop, isA<Color>());
      expect(tokens!.spriteFrame, isA<Color>());
      expect(tokens!.spriteShadow, isA<Color>());
      expect(tokens!.temperatureAccent, isA<Color>());
      expect(tokens!.statAccent, isA<Color>());
    }
  });

  testWidgets('temperature pixel style is scoped and keeps readable fallback', (
    tester,
  ) async {
    TextStyle? style;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Builder(
          builder: (BuildContext context) {
            style = temperaturePixelTextStyle(
              context,
              Theme.of(context).textTheme.titleMedium,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(style?.fontFamily, temperaturePixelFontFamily);
    expect(style?.fontFamilyFallback, isNotNull);
    expect(style?.fontFeatures, isNotEmpty);
  });
}
