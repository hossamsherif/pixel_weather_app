import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/favorites/favorites_store.dart';
import '../../domain/models/location.dart';
import 'app_providers.dart';

class FavoritesController extends Notifier<List<WeatherLocation>> {
  late final FavoritesStore _store;

  @override
  List<WeatherLocation> build() {
    _store = ref.read(favoritesStoreProvider);
    return _store.read();
  }

  bool isFavorite(WeatherLocation location) {
    return state.any(
      (WeatherLocation item) => item.cacheKey == location.cacheKey,
    );
  }

  Future<void> add(WeatherLocation location) async {
    if (isFavorite(location)) {
      return;
    }
    final WeatherLocation favorite = WeatherLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      name: location.name,
      country: location.country,
      state: location.state,
      source: LocationSource.favorite,
    );
    final List<WeatherLocation> updated = <WeatherLocation>[...state, favorite];
    state = updated;
    await _store.write(updated);
  }

  Future<void> remove(WeatherLocation location) async {
    final List<WeatherLocation> updated = state
        .where((WeatherLocation item) => item.cacheKey != location.cacheKey)
        .toList();
    state = updated;
    await _store.write(updated);
  }
}
