import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/core/theme/temperature_text_style.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/screens/favorites_screen.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';

class _UnitsController extends UnitsController {
  _UnitsController([this.initial = Units.metric]);

  final Units initial;

  @override
  Units build() => initial;
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
  testWidgets('FavoritesScreen shows pixel offline badge and sprite row', (
    tester,
  ) async {
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
    expect(
      find.byKey(const ValueKey<String>('favorite-weather-sprite')),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsNothing);
  });

  testWidgets('FavoritesScreen renders dark HUD placeholders for cached miss', (
    tester,
  ) async {
    final favorite = _location();

    await tester.pumpWidget(
      _wrap(
        const FavoritesScreen(),
        themeMode: ThemeMode.dark,
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

    expect(find.text(favorite.displayName), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'FavoritesScreen keeps Arabic row numbers LTR and delete directional',
    (tester) async {
      final favorite = _location(
        name: 'القاهرة',
        country: 'مصر',
        latitude: 30.0444,
        longitude: 31.2357,
      );
      final report = _report(location: favorite);

      await tester.pumpWidget(
        _wrap(
          const FavoritesScreen(),
          locale: const Locale('ar'),
          overrides: [
            favoritesControllerProvider.overrideWith(
              () => _FavoritesController([favorite]),
            ),
            weatherControllerProvider.overrideWith(
              () => _WeatherController(report),
            ),
            unitsProvider.overrideWith(_UnitsController.new),
            favoriteWeatherProvider(
              favorite,
            ).overrideWith((ref) async => report),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(favorite.displayName), findsOneWidget);
      expect(find.text(favorite.cacheKey), findsOneWidget);
      expect(find.text('18°C'), findsOneWidget);

      final cacheDirection = tester
          .element(find.text(favorite.cacheKey))
          .findAncestorWidgetOfExactType<Directionality>();
      final temperatureDirection = tester
          .element(find.text('18°C'))
          .findAncestorWidgetOfExactType<Directionality>();
      expect(cacheDirection?.textDirection, TextDirection.ltr);
      expect(temperatureDirection?.textDirection, TextDirection.ltr);
      final Text temperature = tester.widget<Text>(find.text('18°C'));
      expect(temperature.style?.fontFamily, temperaturePixelFontFamily);

      await tester.drag(find.byType(Dismissible), const Offset(120, 0));
      await tester.pump();

      final deleteBackground = tester.widget<Container>(
        find.byKey(const ValueKey<String>('favorite-delete-background')).first,
      );
      expect(deleteBackground.alignment, AlignmentDirectional.centerEnd);
    },
  );

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

  testWidgets(
    'FavoritesScreen applies pixel numerals to English imperial rows',
    (tester) async {
      final favorite = _location();
      final report = _report(location: favorite);

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
            unitsProvider.overrideWith(() => _UnitsController(Units.imperial)),
            favoriteWeatherProvider(
              favorite,
            ).overrideWith((ref) async => report),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final Text temperature = tester.widget<Text>(find.text('18°F'));
      expect(temperature.style?.fontFamily, temperaturePixelFontFamily);
    },
  );
}

Widget _wrap(
  Widget child, {
  required List overrides,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: List.castFrom(overrides),
    child: MaterialApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

WeatherLocation _location({
  String name = 'Paris',
  String country = 'France',
  double latitude = 48.8,
  double longitude = 2.3,
}) {
  return WeatherLocation(
    name: name,
    country: country,
    latitude: latitude,
    longitude: longitude,
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
