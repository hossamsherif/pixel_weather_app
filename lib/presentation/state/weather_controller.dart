import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import 'app_providers.dart';
import 'location_service.dart';

class WeatherController extends AsyncNotifier<WeatherReport?> {
  @override
  Future<WeatherReport?> build() async {
    return null;
  }

  Future<void> loadForLocation(WeatherLocation location) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final WeatherRepository repo = ref.read(weatherRepositoryProvider);
      final Units units = ref.read(unitsProvider);
      return repo.getWeather(location: location, units: units);
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
      final Units units = ref.read(unitsProvider);
      return repo.getWeather(location: location, units: units);
    });
  }

  Future<void> refresh() async {
    final WeatherLocation? location = state.value?.location;
    if (location == null) {
      return;
    }
    await loadForLocation(location);
  }
}
