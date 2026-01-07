import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/location.dart';

class FavoritesStore {
  FavoritesStore(this._preferences);

  static const String _key = 'favorite_locations';

  final SharedPreferences _preferences;

  List<WeatherLocation> read() {
    final List<String> raw = _preferences.getStringList(_key) ?? <String>[];
    return raw
        .map(
          (String entry) => WeatherLocation.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> write(List<WeatherLocation> locations) async {
    final List<String> raw = locations
        .map((WeatherLocation location) => jsonEncode(location.toJson()))
        .toList();
    await _preferences.setStringList(_key, raw);
  }
}
