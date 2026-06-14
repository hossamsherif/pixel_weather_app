import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';

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
}
