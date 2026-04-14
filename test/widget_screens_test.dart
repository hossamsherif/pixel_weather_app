import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/screens/favorites_screen.dart';
import 'package:pixel_weather_app/presentation/screens/forecast_screen.dart';
import 'package:pixel_weather_app/presentation/screens/now_screen.dart';
import 'package:pixel_weather_app/presentation/screens/search_screen.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';

void main() {
  Widget wrapWidget(Widget child, List overrides) {
    return ProviderScope(
      overrides: List.castFrom(overrides),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  WeatherReport buildReport({
    WeatherDataSource source = WeatherDataSource.network,
    List<HourlyForecast> hourly = const [],
    List<DailyForecast> daily = const [],
  }) {
    const location = WeatherLocation(
      latitude: 1,
      longitude: 2,
      name: 'Test City',
      country: 'TS',
      source: LocationSource.search,
    );

    return WeatherReport(
      location: location,
      current: CurrentWeather(
        observedAt: DateTime(2024, 1, 1, 10, 0),
        temperature: 21,
        feelsLike: 20,
        condition: const WeatherCondition(
          type: WeatherConditionType.clear,
          description: 'clear',
        ),
        humidity: 50,
        windSpeed: 4,
      ),
      hourly: hourly,
      daily: daily,
      updatedAt: DateTime(2024, 1, 1, 10, 0),
      dataSource: source,
    );
  }

  testWidgets('NowScreen shows empty state when no report', (tester) async {
    stubReport = null;
    await tester.pumpWidget(
      wrapWidget(const NowScreen(), [
        weatherControllerProvider.overrideWith(TestWeatherController.new),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('No weather yet'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);
  });

  testWidgets('NowScreen shows summary card when report exists', (
    tester,
  ) async {
    stubReport = buildReport();
    await tester.pumpWidget(
      wrapWidget(const NowScreen(), [
        weatherControllerProvider.overrideWith(TestWeatherController.new),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
        unitsProvider.overrideWith(() => TestUnitsController(Units.metric)),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test City, TS'), findsOneWidget);
    expect(find.textContaining('21'), findsOneWidget);
    expect(find.byIcon(Icons.star_border_outlined), findsOneWidget);
  });

  testWidgets('ForecastScreen shows hourly and daily sections', (tester) async {
    stubReport = buildReport(
      hourly: [
        HourlyForecast(
          time: DateTime(2024, 1, 1, 11, 0),
          temperature: 18,
          condition: const WeatherCondition(
            type: WeatherConditionType.clear,
            description: 'clear',
          ),
        ),
      ],
      daily: [
        DailyForecast(
          date: DateTime(2024, 1, 2),
          minTemp: 12,
          maxTemp: 20,
          condition: const WeatherCondition(
            type: WeatherConditionType.clear,
            description: 'clear',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      wrapWidget(const ForecastScreen(), [
        weatherControllerProvider.overrideWith(TestWeatherController.new),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
        unitsProvider.overrideWith(() => TestUnitsController(Units.metric)),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hourly'), findsOneWidget);
    expect(find.text('5-day'), findsOneWidget);
  });

  testWidgets('FavoritesScreen shows empty state', (tester) async {
    stubReport = null;
    await tester.pumpWidget(
      wrapWidget(const FavoritesScreen(), [
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
        weatherControllerProvider.overrideWith(TestWeatherController.new),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('SearchScreen shows initial empty state', (tester) async {
    await tester.pumpWidget(
      wrapWidget(const SearchScreen(), [
        searchResultsProvider.overrideWith((ref) async => <WeatherLocation>[]),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Search'), findsWidgets);
    expect(
      find.text(
        'Search for a city or enable location to see current conditions.',
      ),
      findsOneWidget,
    );
  });
}

class TestUnitsController extends UnitsController {
  TestUnitsController(this.initial);
  final Units initial;

  @override
  Units build() => initial;
}

class TestFavoritesController extends FavoritesController {
  TestFavoritesController(this.initial);
  final List<WeatherLocation> initial;

  @override
  List<WeatherLocation> build() => initial;
}

WeatherReport? stubReport;

class TestWeatherController extends WeatherController {
  @override
  Future<WeatherReport?> build() async => stubReport;
}
