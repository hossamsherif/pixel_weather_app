import '../models/location.dart';
import '../models/units.dart';
import '../models/weather.dart';

abstract class WeatherRepository {
  Future<WeatherReport> getWeather({
    required WeatherLocation location,
    Units units,
  });

  Future<List<WeatherLocation>> searchLocations({
    required String query,
    int limit,
  });

  Future<WeatherLocation> resolveLocation({
    required double latitude,
    required double longitude,
  });
}
