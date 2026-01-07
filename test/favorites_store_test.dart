import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_weather_app/data/favorites/favorites_store.dart';
import 'package:pixel_weather_app/domain/models/location.dart';

void main() {
  test('FavoritesStore persists and restores locations', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FavoritesStore store = FavoritesStore(prefs);

    final List<WeatherLocation> favorites = <WeatherLocation>[
      const WeatherLocation(
        latitude: 1,
        longitude: 2,
        name: 'Cairo',
        country: 'EG',
        source: LocationSource.favorite,
      ),
      const WeatherLocation(
        latitude: 3,
        longitude: 4,
        name: 'Paris',
        country: 'FR',
        source: LocationSource.favorite,
      ),
    ];

    await store.write(favorites);
    final List<WeatherLocation> restored = store.read();

    expect(restored.length, 2);
    expect(restored.first.displayName, 'Cairo, EG');
    expect(restored.last.displayName, 'Paris, FR');
  });
}
