import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/widgets/weather_summary_card.dart';

void main() {
  testWidgets('WeatherSummaryCard shows offline badge and favorite toggle',
      (tester) async {
    var toggled = false;
    final report = _report(dataSource: WeatherDataSource.cache);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
            return Scaffold(
              body: WeatherSummaryCard(
                report: report,
                units: Units.metric,
                strings: strings,
                isFavorite: true,
                onToggleFavorite: () => toggled = true,
              ),
            );
          },
        ),
      ),
    );

    expect(find.text(report.location.displayName), findsOneWidget);
    expect(find.textContaining('°C'), findsWidgets);
    expect(find.textContaining('m/s'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

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

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
            return Scaffold(
              body: WeatherSummaryCard(
                report: report,
                units: Units.imperial,
                strings: strings,
              ),
            );
          },
        ),
      ),
    );

    expect(find.textContaining('°F'), findsWidgets);
    expect(find.textContaining('mph'), findsOneWidget);
  });
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
    current: current ??
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
