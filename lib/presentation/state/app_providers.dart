import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/cache/weather_cache.dart';
import '../../data/favorites/favorites_store.dart';
import '../../data/open_weather/open_weather_mapper.dart';
import '../../data/open_weather/open_weather_repository.dart';
import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../core/services/widget_service.dart';
export '../../core/services/widget_service.dart';
import 'location_service.dart';

/// Provider for WidgetService - can be overridden in tests
final Provider<WidgetService> widgetServiceProvider =
    Provider<WidgetService>((ref) => WidgetService());

final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) {
      throw UnimplementedError('SharedPreferences not initialized.');
    });

final Provider<WeatherRepository> weatherRepositoryProvider =
    Provider<WeatherRepository>((ref) {
      final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
      return OpenWeatherRepository.withDefaults(preferences: prefs);
    });

final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((ref) => GeolocatorLocationService());

final NotifierProvider<UnitsController, Units> unitsProvider =
    NotifierProvider<UnitsController, Units>(UnitsController.new);

final Provider<FavoritesStore> favoritesStoreProvider =
    Provider<FavoritesStore>((ref) {
      final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
      return FavoritesStore(prefs);
    });

final NotifierProvider<SearchQueryController, String> searchQueryProvider =
    NotifierProvider<SearchQueryController, String>(SearchQueryController.new);

const Duration _favoriteCacheTtl = Duration(hours: 1);

final favoriteWeatherProvider =
    FutureProvider.family<WeatherReport?, WeatherLocation>((
      ref,
      location,
    ) async {
      final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
      final WeatherCache cache = WeatherCache(prefs);
      final entry = await cache.read(location.cacheKey);
      if (entry != null) {
        final Duration age = DateTime.now().difference(entry.storedAt);
        if (age <= _favoriteCacheTtl) {
          return const OpenWeatherMapper().toReport(
            response: entry.payload,
            location: location,
            updatedAt: entry.storedAt,
            dataSource: WeatherDataSource.cache,
          );
        }
      }

      final WeatherRepository repo = ref.watch(weatherRepositoryProvider);
      final Units units = ref.watch(unitsProvider);
      try {
        return await repo.getWeather(location: location, units: units);
      } catch (_) {
        if (entry == null) {
          return null;
        }
        return const OpenWeatherMapper().toReport(
          response: entry.payload,
          location: location,
          updatedAt: entry.storedAt,
          dataSource: WeatherDataSource.cache,
        );
      }
    });

final FutureProvider<List<WeatherLocation>> searchResultsProvider =
    FutureProvider.autoDispose<List<WeatherLocation>>((ref) async {
      final String query = ref.watch(searchQueryProvider).trim();
      if (query.isEmpty) {
        return <WeatherLocation>[];
      }
      final WeatherRepository repo = ref.watch(weatherRepositoryProvider);
      return repo.searchLocations(query: query);
    });

final NotifierProvider<LocaleController, Locale?> localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class UnitsController extends Notifier<Units> {
  @override
  Units build() => Units.metric;

  void setUnits(Units units) => state = units;
}

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) => state = locale;

  void toggleLocale() {
    if (state?.languageCode == 'ar') {
      state = const Locale('en');
    } else {
      state = const Locale('ar');
    }
  }
}

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}