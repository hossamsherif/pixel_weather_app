import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/screens/favorites_screen.dart';
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
}

class _WeatherController extends WeatherController {
  _WeatherController(this.report);
  final WeatherReport? report;

  @override
  Future<WeatherReport?> build() async => report;
}

void main() {
  testWidgets('FavoritesScreen shows offline badge and list', (tester) async {
    final favorite = _location();
    final report = _report(
      location: favorite,
      dataSource: WeatherDataSource.cache,
    );

    await tester.pumpWidget(
      _wrap(
        const FavoritesScreen(),
        overrides: [
          favoritesControllerProvider.overrideWith(
            () => _FavoritesController([favorite]),
          ),
          weatherControllerProvider.overrideWith(
            () => _WeatherController(report),
          ),
          unitsProvider.overrideWith(_UnitsController.new),
          favoriteWeatherProvider(favorite).overrideWith((ref) async => report),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text(favorite.displayName), findsOneWidget);
    expect(find.textContaining('°C'), findsOneWidget);
  });

  testWidgets('FavoritesScreen removes favorite on dismiss', (tester) async {
    final favorite = _location();

    await tester.pumpWidget(
      _wrap(
        const FavoritesScreen(),
        overrides: [
          favoritesControllerProvider.overrideWith(
            () => _FavoritesController([favorite]),
          ),
          weatherControllerProvider.overrideWith(
            () => _WeatherController(null),
          ),
          unitsProvider.overrideWith(_UnitsController.new),
          favoriteWeatherProvider(favorite).overrideWith((ref) async => null),
        ],
      ),
    );

    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text(favorite.displayName), findsNothing);
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
    name: 'Paris',
    country: 'France',
    latitude: 48.8,
    longitude: 2.3,
    source: LocationSource.search,
  );
}

WeatherReport _report({
  required WeatherLocation location,
  WeatherDataSource dataSource = WeatherDataSource.network,
}) {
  return WeatherReport(
    location: location,
    updatedAt: DateTime(2024, 1, 1, 12, 0),
    current: CurrentWeather(
      observedAt: DateTime(2024, 1, 1, 11),
      temperature: 18,
      feelsLike: 16,
      humidity: 55,
      windSpeed: 4.6,
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
