import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  _FavoritesController(this.initial);
  final List<WeatherLocation> initial;

  @override
  List<WeatherLocation> build() => initial;

  @override
  Future<void> remove(WeatherLocation location) async {
    state = state.where((item) => item.cacheKey != location.cacheKey).toList();
  }

  @override
  Future<void> add(WeatherLocation location) async {
    state = <WeatherLocation>[...state, location];
  }
}

class _WeatherController extends WeatherController {
  _WeatherController(this.report);
  final WeatherReport? report;

  @override
  Future<WeatherReport?> build() async => report;
}

void main() {
  testWidgets('ForecastScreen shows empty forecast card', (tester) async {
    final report = _report();

    await tester.pumpWidget(
      _wrap(
        const ForecastScreen(),
        overrides: [
          weatherControllerProvider.overrideWith(() => _WeatherController(report)),
          favoritesControllerProvider.overrideWith(
            () => _FavoritesController(const []),
          ),
          unitsProvider.overrideWith(_UnitsController.new),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No forecast data'), findsOneWidget);
  });

  testWidgets('ForecastScreen toggles favorite state', (tester) async {
    final location = _location();
    final report = _report(location: location, hourly: _hourly(), daily: _daily());

    await tester.pumpWidget(
      _wrap(
        const ForecastScreen(),
        overrides: [
          weatherControllerProvider.overrideWith(() => _WeatherController(report)),
          favoritesControllerProvider.overrideWith(
            () => _FavoritesController(const []),
          ),
          unitsProvider.overrideWith(_UnitsController.new),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_border_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}

Widget _wrap(Widget child, {required List overrides}) {
  return ProviderScope(
    overrides: List.castFrom(overrides),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

WeatherLocation _location() {
  return const WeatherLocation(
    name: 'Tokyo',
    country: 'Japan',
    latitude: 35.6,
    longitude: 139.6,
    source: LocationSource.search,
  );
}

WeatherReport _report({
  WeatherLocation? location,
  List<HourlyForecast>? hourly,
  List<DailyForecast>? daily,
}) {
  return WeatherReport(
    location: location ?? _location(),
    updatedAt: DateTime(2024, 1, 1, 12, 0),
    current: CurrentWeather(
      observedAt: DateTime(2024, 1, 1, 11),
      temperature: 22,
      feelsLike: 20,
      humidity: 60,
      windSpeed: 3.2,
      condition: const WeatherCondition(
        type: WeatherConditionType.clear,
        description: 'Clear',
      ),
    ),
    hourly: hourly ?? const <HourlyForecast>[],
    daily: daily ?? const <DailyForecast>[],
    dataSource: WeatherDataSource.network,
  );
}

List<HourlyForecast> _hourly() {
  return <HourlyForecast>[
    HourlyForecast(
      time: DateTime(2024, 1, 1, 12),
      temperature: 20,
      condition: const WeatherCondition(
        type: WeatherConditionType.clouds,
        description: 'Clouds',
      ),
    ),
  ];
}

List<DailyForecast> _daily() {
  return <DailyForecast>[
    DailyForecast(
      date: DateTime(2024, 1, 2),
      minTemp: 16,
      maxTemp: 24,
      condition: const WeatherCondition(
        type: WeatherConditionType.clear,
        description: 'Clear',
      ),
    ),
  ];
}
