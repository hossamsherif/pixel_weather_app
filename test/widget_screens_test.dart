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
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';

void main() {
  Widget _wrap(Widget child, List overrides) {
    return ProviderScope(
      overrides: List.castFrom(overrides),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  WeatherReport _report({
    WeatherDataSource source = WeatherDataSource.network,
    List<HourlyForecast> hourly = const [],
    List<DailyForecast> daily = const [],
  }) {
    final location = const WeatherLocation(
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
    _stubReport = null;
    await tester.pumpWidget(
      _wrap(
        const NowScreen(),
        [
          weatherControllerProvider.overrideWith(_TestWeatherController.new),
          favoritesControllerProvider.overrideWith(
            () => _TestFavoritesController(const []),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No weather yet'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);
  });

  testWidgets('NowScreen shows summary card when report exists', (tester) async {
    _stubReport = _report();
    await tester.pumpWidget(
      _wrap(
        const NowScreen(),
        [
          weatherControllerProvider.overrideWith(_TestWeatherController.new),
          favoritesControllerProvider.overrideWith(
            () => _TestFavoritesController(const []),
          ),
          unitsProvider.overrideWith(() => _TestUnitsController(Units.metric)),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test City, TS'), findsOneWidget);
    expect(find.textContaining('21°'), findsOneWidget);
    expect(find.byIcon(Icons.star_border_outlined), findsOneWidget);
  });

  testWidgets('ForecastScreen shows hourly and daily sections', (tester) async {
    _stubReport = _report(
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
      _wrap(
        const ForecastScreen(),
        [
          weatherControllerProvider.overrideWith(_TestWeatherController.new),
          favoritesControllerProvider.overrideWith(
            () => _TestFavoritesController(const []),
          ),
          unitsProvider.overrideWith(() => _TestUnitsController(Units.metric)),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hourly'), findsOneWidget);
    expect(find.text('5-day'), findsOneWidget);
  });

  testWidgets('FavoritesScreen shows empty state', (tester) async {
    _stubReport = null;
    await tester.pumpWidget(
      _wrap(
        const FavoritesScreen(),
        [
          favoritesControllerProvider.overrideWith(
            () => _TestFavoritesController(const []),
          ),
          weatherControllerProvider.overrideWith(_TestWeatherController.new),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('SearchScreen shows initial empty state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SearchScreen(),
        [
          searchResultsProvider.overrideWith(
            (ref) async => <WeatherLocation>[],
          ),
          favoritesControllerProvider.overrideWith(
            () => _TestFavoritesController(const []),
          ),
        ],
      ),
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

class _TestUnitsController extends UnitsController {
  _TestUnitsController(this.initial);
  final Units initial;

  @override
  Units build() => initial;
}

class _TestFavoritesController extends FavoritesController {
  _TestFavoritesController(this.initial);
  final List<WeatherLocation> initial;

  @override
  List<WeatherLocation> build() => initial;
}

late WeatherReport? _stubReport;

class _TestWeatherController extends WeatherController {
  @override
  Future<WeatherReport?> build() async => _stubReport;
}
