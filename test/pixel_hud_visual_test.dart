import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/widgets/weather_summary_card.dart';

void main() {
  setUpAll(_loadScreenshotFonts);

  final List<_Scenario> scenarios = <_Scenario>[
    _Scenario(
      name: 'pixel_hud_light_en_clear',
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'Cairo',
        country: 'Egypt',
        condition: const WeatherCondition(
          type: WeatherConditionType.clear,
          description: 'Clear sky',
          iconCode: '01d',
        ),
        temperature: 31,
      ),
    ),
    _Scenario(
      name: 'pixel_hud_dark_en_thunder',
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'Tokyo',
        country: 'Japan',
        condition: const WeatherCondition(
          type: WeatherConditionType.thunder,
          description: 'Thunderstorm',
          iconCode: '11n',
        ),
        temperature: 22,
      ),
    ),
    _Scenario(
      name: 'pixel_hud_light_ar_rain',
      locale: const Locale('ar'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'القاهرة',
        country: 'مصر',
        condition: const WeatherCondition(
          type: WeatherConditionType.rain,
          description: 'أمطار خفيفة',
          iconCode: '10d',
        ),
        temperature: 27,
      ),
    ),
    _Scenario(
      name: 'pixel_hud_dark_ar_clouds',
      locale: const Locale('ar'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'دبي',
        country: 'الإمارات',
        condition: const WeatherCondition(
          type: WeatherConditionType.clouds,
          description: 'غيوم متفرقة',
          iconCode: '03n',
        ),
        temperature: 29,
      ),
    ),
  ];

  for (final _Scenario scenario in scenarios) {
    testWidgets(
      'captures ${scenario.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 720));
        await tester.pumpWidget(_VisualApp(scenario: scenario));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await tester.pump();

        await expectLater(
          find.byType(_VisualApp),
          matchesGoldenFile('goldens/${scenario.name}.png'),
        );
      },
      // Screenshot capture only; run manually with --update-goldens.
      skip: true,
    );
  }
}

Future<void> _loadScreenshotFonts() async {
  final FontLoader loader = FontLoader('ScreenshotSans');
  final List<File> candidates = <File>[
    File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf'),
    File('/Library/Fonts/Arial Unicode.ttf'),
  ];
  final File font = candidates.firstWhere(
    (candidate) => candidate.existsSync(),
    orElse: () => candidates.first,
  );
  if (font.existsSync()) {
    loader.addFont(
      font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
  }
  await loader.load();
}

class _Scenario {
  const _Scenario({
    required this.name,
    required this.locale,
    required this.themeMode,
    required this.report,
  });

  final String name;
  final Locale locale;
  final ThemeMode themeMode;
  final WeatherReport report;
}

class _VisualApp extends StatelessWidget {
  const _VisualApp({required this.scenario});

  final _Scenario scenario;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: scenario.locale,
      theme: _withScreenshotFont(AppTheme.lightTheme()),
      darkTheme: _withScreenshotFont(AppTheme.darkTheme()),
      themeMode: scenario.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final strings = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(strings.tabForecast)),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                WeatherSummaryCard(
                  report: scenario.report,
                  units: Units.metric,
                  strings: strings,
                  isFavorite: false,
                  onToggleFavorite: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

ThemeData _withScreenshotFont(ThemeData theme) {
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'ScreenshotSans'),
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamily: 'ScreenshotSans',
    ),
  );
}

WeatherReport _report({
  required String city,
  required String country,
  required WeatherCondition condition,
  required double temperature,
}) {
  return WeatherReport(
    location: WeatherLocation(
      name: city,
      country: country,
      latitude: 30,
      longitude: 31,
      source: LocationSource.search,
    ),
    updatedAt: DateTime(2026, 6, 13, 18, 30),
    current: CurrentWeather(
      observedAt: DateTime(2026, 6, 13, 18),
      temperature: temperature,
      feelsLike: temperature - 1,
      humidity: 58,
      windSpeed: 5,
      sunrise: DateTime(2026, 6, 13, 5),
      sunset: DateTime(2026, 6, 13, 19),
      condition: condition,
    ),
    hourly: const <HourlyForecast>[],
    daily: const <DailyForecast>[],
    dataSource: WeatherDataSource.network,
  );
}
