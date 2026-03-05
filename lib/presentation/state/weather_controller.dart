import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../core/services/widget_service.dart';
import 'app_providers.dart';
import 'location_service.dart';

class WeatherController extends AsyncNotifier<WeatherReport?> {
  static const String _lastLocationKey = 'last_location';

  @override
  Future<WeatherReport?> build() async {
    final WeatherRepository repo = ref.watch(weatherRepositoryProvider);
    final Units units = ref.watch(unitsProvider);
    final String? languageCode = ref.watch(localeProvider)?.languageCode;
    final WeatherLocation? lastLocation = await _readLastLocation();

    if (lastLocation != null) {
      final report = await repo.getWeather(
        location: lastLocation,
        units: units,
        languageCode: languageCode,
      );
      WidgetService.updateWidget(report);
      return report;
    }

    final LocationService locationService = ref.read(locationServiceProvider);
    final bool canAccess = await locationService.canAccessLocation();
    if (!canAccess) {
      return null;
    }

    final position = await locationService.getCurrentPosition();
    final WeatherLocation location = await repo.resolveLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    await _saveLastLocation(location);
    final report = await repo.getWeather(
      location: location,
      units: units,
      languageCode: languageCode,
    );
    WidgetService.updateWidget(report);
    return report;
  }

  Future<void> loadForLocation(WeatherLocation location) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _saveLastLocation(location);
      final WeatherRepository repo = ref.read(weatherRepositoryProvider);
      final Units units = ref.read(unitsProvider);
      final String? languageCode = ref.read(localeProvider)?.languageCode;
      final report = await repo.getWeather(
        location: location,
        units: units,
        languageCode: languageCode,
      );
      WidgetService.updateWidget(report);
      return report;
    });
  }

  Future<void> loadForCurrentLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final WeatherRepository repo = ref.read(weatherRepositoryProvider);
      final LocationService locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      final WeatherLocation location = await repo.resolveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _saveLastLocation(location);
      final Units units = ref.read(unitsProvider);
      final String? languageCode = ref.read(localeProvider)?.languageCode;
      final report = await repo.getWeather(
        location: location,
        units: units,
        languageCode: languageCode,
      );
      WidgetService.updateWidget(report);
      return report;
    });
  }

  Future<void> refresh() async {
    final WeatherLocation? location = state.value?.location;
    if (location == null) {
      return;
    }
    await loadForLocation(location);
  }

  Future<WeatherLocation?> _readLastLocation() async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    final String? raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherLocation.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLastLocation(WeatherLocation location) async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }
}
