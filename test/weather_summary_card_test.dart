import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/presentation/widgets/weather_summary_card.dart';

void main() {
  testWidgets('WeatherSummaryCard shows offline badge and favorite toggle', (
    tester,
  ) async {
    var toggled = false;
    final report = _report(dataSource: WeatherDataSource.cache);

    await tester.pumpWidget(
      _wrap(
        report: report,
        isFavorite: true,
        onToggleFavorite: () => toggled = true,
      ),
    );

    expect(find.text(report.location.displayName), findsOneWidget);
    expect(find.textContaining('°C'), findsWidgets);
    expect(find.textContaining('m/s'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final Image sprite = tester.widget<Image>(find.byType(Image));
    expect(sprite.filterQuality, FilterQuality.none);

    await tester.tap(find.byIcon(Icons.star));
    expect(toggled, isTrue);
  });

  testWidgets('WeatherSummaryCard renders imperial units', (tester) async {
    final report = _report(
      current: CurrentWeather(
        observedAt: DateTime(2024, 1, 1, 11),
        temperature: 72.4,
        feelsLike: 71.8,
        humidity: 45,
        windSpeed: 10.2,
        condition: const WeatherCondition(
          type: WeatherConditionType.clear,
          description: 'Clear skies',
        ),
      ),
    );

    await tester.pumpWidget(_wrap(report: report, units: Units.imperial));

    expect(find.textContaining('°F'), findsWidgets);
    expect(find.textContaining('mph'), findsOneWidget);
  });

  for (final (Locale locale, ThemeMode mode) in <(Locale, ThemeMode)>[
    (Locale('en'), ThemeMode.light),
    (Locale('en'), ThemeMode.dark),
    (Locale('ar'), ThemeMode.light),
    (Locale('ar'), ThemeMode.dark),
  ]) {
    testWidgets('WeatherSummaryCard renders ${locale.languageCode} $mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          report: _report(
            current: CurrentWeather(
              observedAt: DateTime(2024, 1, 1, 21),
              temperature: 18,
              feelsLike: 17,
              humidity: 68,
              windSpeed: 4,
              condition: const WeatherCondition(
                type: WeatherConditionType.rain,
                description: 'Rain',
                iconCode: '10n',
              ),
            ),
          ),
          locale: locale,
          themeMode: mode,
        ),
      );

      expect(find.byType(WeatherSummaryCard), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      if (locale.languageCode == 'ar') {
        final Text windValue = tester.widget<Text>(find.text('4 m/s'));
        expect(windValue.textDirection, TextDirection.ltr);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _wrap({
  required WeatherReport report,
  Units units = Units.metric,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool? isFavorite,
  VoidCallback? onToggleFavorite,
}) {
  return MaterialApp(
    locale: locale,
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    themeMode: themeMode,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        final strings = AppLocalizations.of(context)!;
        return Scaffold(
          body: WeatherSummaryCard(
            report: report,
            units: units,
            strings: strings,
            isFavorite: isFavorite,
            onToggleFavorite: onToggleFavorite,
          ),
        );
      },
    ),
  );
}

WeatherReport _report({
  WeatherDataSource dataSource = WeatherDataSource.network,
  CurrentWeather? current,
}) {
  return WeatherReport(
    location: const WeatherLocation(
      name: 'London',
      country: 'UK',
      latitude: 51.5,
      longitude: 0.1,
      source: LocationSource.search,
    ),
    updatedAt: DateTime(2024, 1, 1, 12, 0),
    current:
        current ??
        CurrentWeather(
          observedAt: DateTime(2024, 1, 1, 11),
          temperature: 20.4,
          feelsLike: 19.2,
          humidity: 60,
          windSpeed: 3.4,
          condition: const WeatherCondition(
            type: WeatherConditionType.clouds,
            description: 'Cloudy',
          ),
        ),
    hourly: const <HourlyForecast>[],
    daily: const <DailyForecast>[],
    dataSource: dataSource,
  );
}
