import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/screens/forecast_screen.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';

class _UnitsController extends UnitsController {
  @override
  Units build() => Units.metric;
}

class _FavoritesController extends FavoritesController {
  @override
  List<WeatherLocation> build() => const <WeatherLocation>[];
}

class _WeatherController extends WeatherController {
  _WeatherController(this.report);

  final WeatherReport report;

  @override
  Future<WeatherReport?> build() async => report;
}

void main() {
  setUpAll(_loadScreenshotFonts);

  final List<_Scenario> scenarios = <_Scenario>[
    _Scenario(
      name: 'forecast_cards_light_en',
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'Cairo',
        country: 'Egypt',
        conditionDescription: 'Clear sky',
      ),
    ),
    _Scenario(
      name: 'forecast_cards_dark_en',
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'Tokyo',
        country: 'Japan',
        conditionDescription: 'Storm cells',
      ),
    ),
    _Scenario(
      name: 'forecast_cards_light_ar',
      locale: const Locale('ar'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'القاهرة',
        country: 'مصر',
        conditionDescription: 'أمطار خفيفة',
      ),
    ),
    _Scenario(
      name: 'forecast_cards_dark_ar',
      locale: const Locale('ar'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'دبي',
        country: 'الإمارات',
        conditionDescription: 'غيوم متفرقة',
      ),
    ),
  ];

  for (final _Scenario scenario in scenarios) {
    testWidgets(
      'captures ${scenario.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 780));
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
      // Manual screenshot capture; host font rasterization differs in CI.
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
    return ProviderScope(
      overrides: [
        weatherControllerProvider.overrideWith(
          () => _WeatherController(scenario.report),
        ),
        favoritesControllerProvider.overrideWith(_FavoritesController.new),
        unitsProvider.overrideWith(_UnitsController.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: scenario.locale,
        theme: _withScreenshotFont(AppTheme.lightTheme()),
        darkTheme: _withScreenshotFont(AppTheme.darkTheme()),
        themeMode: scenario.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ForecastScreen(),
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
  required String conditionDescription,
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
      temperature: 31,
      feelsLike: 30,
      humidity: 58,
      windSpeed: 5,
      sunrise: DateTime(2026, 6, 13, 5),
      sunset: DateTime(2026, 6, 13, 19),
      condition: const WeatherCondition(
        type: WeatherConditionType.clear,
        description: 'Clear sky',
        iconCode: '01d',
      ),
    ),
    hourly: <HourlyForecast>[
      HourlyForecast(
        time: DateTime(2026, 6, 13, 21),
        temperature: 28,
        precipitationChance: 0.35,
        condition: const WeatherCondition(
          type: WeatherConditionType.clouds,
          description: 'Clouds',
          iconCode: '03n',
        ),
      ),
      HourlyForecast(
        time: DateTime(2026, 6, 14, 9),
        temperature: 30,
        precipitationChance: 0.08,
        condition: const WeatherCondition(
          type: WeatherConditionType.clear,
          description: 'Clear',
          iconCode: '01d',
        ),
      ),
      HourlyForecast(
        time: DateTime(2026, 6, 14, 15),
        temperature: 34,
        precipitationChance: 0.2,
        condition: const WeatherCondition(
          type: WeatherConditionType.rain,
          description: 'Rain',
          iconCode: '10d',
        ),
      ),
    ],
    daily: <DailyForecast>[
      DailyForecast(
        date: DateTime(2026, 6, 14),
        minTemp: 24,
        maxTemp: 34,
        precipitationChance: 0.2,
        condition: WeatherCondition(
          type: WeatherConditionType.clear,
          description: conditionDescription,
          iconCode: '01d',
        ),
      ),
      DailyForecast(
        date: DateTime(2026, 6, 15),
        minTemp: 23,
        maxTemp: 31,
        precipitationChance: 0.42,
        condition: const WeatherCondition(
          type: WeatherConditionType.rain,
          description: 'Rain showers',
          iconCode: '10n',
        ),
      ),
      DailyForecast(
        date: DateTime(2026, 6, 16),
        minTemp: 22,
        maxTemp: 29,
        precipitationChance: 0.12,
        condition: const WeatherCondition(
          type: WeatherConditionType.clouds,
          description: 'Clouds',
        ),
      ),
    ],
    dataSource: WeatherDataSource.network,
  );
}
