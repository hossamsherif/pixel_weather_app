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
import 'package:pixel_weather_app/presentation/screens/favorites_screen.dart';
import 'package:pixel_weather_app/presentation/screens/now_screen.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';

class _UnitsController extends UnitsController {
  @override
  Units build() => Units.metric;
}

class _FavoritesController extends FavoritesController {
  _FavoritesController(this.favorite);

  final WeatherLocation favorite;

  @override
  List<WeatherLocation> build() => <WeatherLocation>[favorite];
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
      name: 'light_en',
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'Cairo',
        country: 'Egypt',
        description: 'Clear sky',
        condition: WeatherConditionType.clear,
        iconCode: '01d',
      ),
    ),
    _Scenario(
      name: 'dark_en',
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'Reykjavik',
        country: 'Iceland',
        description: 'Snow showers',
        condition: WeatherConditionType.snow,
        iconCode: '13n',
      ),
    ),
    _Scenario(
      name: 'light_ar',
      locale: const Locale('ar'),
      themeMode: ThemeMode.light,
      report: _report(
        city: 'القاهرة',
        country: 'مصر',
        description: 'أمطار خفيفة',
        condition: WeatherConditionType.rain,
        iconCode: '10d',
      ),
    ),
    _Scenario(
      name: 'dark_ar',
      locale: const Locale('ar'),
      themeMode: ThemeMode.dark,
      report: _report(
        city: 'دبي',
        country: 'الإمارات',
        description: 'غيوم متفرقة',
        condition: WeatherConditionType.clouds,
        iconCode: '03n',
      ),
    ),
  ];

  for (final _Scenario scenario in scenarios) {
    testWidgets(
      'captures now_${scenario.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 720));
        await tester.pumpWidget(
          _VisualApp(scenario: scenario, child: const NowScreen()),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await tester.pump();

        await expectLater(
          find.byType(_VisualApp),
          matchesGoldenFile('goldens/now_surface_${scenario.name}.png'),
        );
      },
      // Screenshot capture only; run manually with --update-goldens.
      skip: true,
    );

    testWidgets(
      'captures favorites_${scenario.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 720));
        await tester.pumpWidget(
          _VisualApp(scenario: scenario, child: const FavoritesScreen()),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await tester.pump();

        await expectLater(
          find.byType(_VisualApp),
          matchesGoldenFile('goldens/favorites_surface_${scenario.name}.png'),
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
  const _VisualApp({required this.scenario, required this.child});

  final _Scenario scenario;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final WeatherLocation favorite = scenario.report.location;

    return ProviderScope(
      overrides: [
        weatherControllerProvider.overrideWith(
          () => _WeatherController(scenario.report),
        ),
        favoritesControllerProvider.overrideWith(
          () => _FavoritesController(favorite),
        ),
        unitsProvider.overrideWith(_UnitsController.new),
        favoriteWeatherProvider(
          favorite,
        ).overrideWith((ref) async => scenario.report),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: scenario.locale,
        theme: _withScreenshotFont(AppTheme.lightTheme()),
        darkTheme: _withScreenshotFont(AppTheme.darkTheme()),
        themeMode: scenario.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
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
  required String description,
  required WeatherConditionType condition,
  required String iconCode,
}) {
  final DateTime observedAt = DateTime(2024, 1, 1, 14);
  return WeatherReport(
    location: WeatherLocation(
      name: city,
      country: country,
      latitude: 30.0444,
      longitude: 31.2357,
      source: LocationSource.search,
    ),
    updatedAt: observedAt,
    current: CurrentWeather(
      observedAt: observedAt,
      temperature: 24,
      feelsLike: 23,
      humidity: 48,
      windSpeed: 5,
      sunrise: DateTime(2024, 1, 1, 6),
      sunset: DateTime(2024, 1, 1, 18),
      condition: WeatherCondition(
        type: condition,
        description: description,
        iconCode: iconCode,
      ),
    ),
    hourly: const <HourlyForecast>[],
    daily: const <DailyForecast>[],
    dataSource: WeatherDataSource.cache,
  );
}
