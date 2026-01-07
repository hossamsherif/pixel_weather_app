import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'open_weather_cache_entry.dart';

class WeatherCache {
  WeatherCache(this._preferences);

  static const String _prefix = 'weather_cache_';

  final SharedPreferences _preferences;

  String _keyFor(String locationId) => '$_prefix$locationId';

  Future<OpenWeatherCacheEntry?> read(String locationId) async {
    final String? raw = _preferences.getString(_keyFor(locationId));
    if (raw == null) {
      return null;
    }
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return OpenWeatherCacheEntry.fromJson(json);
  }

  Future<void> write(OpenWeatherCacheEntry entry) async {
    final String raw = jsonEncode(entry.toJson());
    await _preferences.setString(_keyFor(entry.locationId), raw);
  }

  Future<void> delete(String locationId) async {
    await _preferences.remove(_keyFor(locationId));
  }
}
