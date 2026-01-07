import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_weather_app/data/cache/open_weather_cache_entry.dart';
import 'package:pixel_weather_app/data/cache/weather_cache.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';

void main() {
  test('WeatherCache writes and reads entries', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final WeatherCache cache = WeatherCache(prefs);

    final OpenWeatherOneCallResponse payload = OpenWeatherOneCallResponse(
      lat: 1,
      lon: 2,
      timezone: 'UTC',
      timezoneOffset: 0,
      current: OpenWeatherCurrent(
        dt: 0,
        temp: 280,
        feelsLike: 279,
        humidity: 50,
        windSpeed: 2,
        weather: const <OpenWeatherCondition>[
          OpenWeatherCondition(
            id: 800,
            main: 'Clear',
            description: 'clear sky',
            icon: '01d',
          ),
        ],
        sunrise: null,
        sunset: null,
        pop: null,
      ),
      hourly: const <OpenWeatherHourly>[],
      daily: const <OpenWeatherDaily>[],
    );

    final OpenWeatherCacheEntry entry = OpenWeatherCacheEntry(
      locationId: '1,2',
      storedAt: DateTime.utc(2025, 1, 1),
      payload: payload,
    );

    await cache.write(entry);
    final OpenWeatherCacheEntry? restored = await cache.read('1,2');

    expect(restored, isNotNull);
    expect(restored!.locationId, '1,2');
    expect(restored.payload.current.temp, 280);
  });

  test('WeatherCache returns null when missing', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final WeatherCache cache = WeatherCache(prefs);

    final OpenWeatherCacheEntry? restored = await cache.read('missing');
    expect(restored, isNull);
  });
}
