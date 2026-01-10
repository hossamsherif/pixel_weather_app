import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_weather_app/app.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';

class ArabicLocaleController extends LocaleController {
  @override
  Locale? build() => const Locale('ar');
}

void main() {
  testWidgets('App loads Forecast tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const PixelWeatherApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Forecast'), findsOneWidget);
  });

  testWidgets('App loads in Arabic', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          localeProvider.overrideWith(ArabicLocaleController.new),
        ],
        child: const PixelWeatherApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('التوقعات'), findsOneWidget);
  });
}
