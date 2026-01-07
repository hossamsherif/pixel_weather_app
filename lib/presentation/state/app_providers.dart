import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/favorites/favorites_store.dart';
import '../../data/open_weather/open_weather_repository.dart';
import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/repositories/weather_repository.dart';
import 'location_service.dart';

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

final FutureProvider<List<WeatherLocation>> searchResultsProvider =
    FutureProvider.autoDispose<List<WeatherLocation>>((ref) async {
      final String query = ref.watch(searchQueryProvider).trim();
      if (query.isEmpty) {
        return <WeatherLocation>[];
      }
      final WeatherRepository repo = ref.watch(weatherRepositoryProvider);
      return repo.searchLocations(query: query);
    });

class UnitsController extends Notifier<Units> {
  @override
  Units build() => Units.metric;

  void setUnits(Units units) => state = units;
}

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}
