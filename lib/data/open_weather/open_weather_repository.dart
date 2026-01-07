import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../cache/open_weather_cache_entry.dart';
import '../cache/weather_cache.dart';
import 'open_weather_client.dart';
import 'open_weather_exceptions.dart';
import 'open_weather_mapper.dart';
import 'open_weather_models.dart';

class OpenWeatherRepository implements WeatherRepository {
  OpenWeatherRepository({
    required OpenWeatherClient client,
    required WeatherCache cache,
    OpenWeatherMapper mapper = const OpenWeatherMapper(),
    DateTime Function()? now,
  }) : _client = client,
       _cache = cache,
       _mapper = mapper,
       _now = now ?? DateTime.now;

  factory OpenWeatherRepository.withDefaults({
    http.Client? httpClient,
    SharedPreferences? preferences,
  }) {
    final SharedPreferences prefs =
        preferences ?? (throw StateError('SharedPreferences not provided.'));
    return OpenWeatherRepository(
      client: OpenWeatherClient(
        apiKey: AppConfig.openWeatherKey,
        httpClient: httpClient,
      ),
      cache: WeatherCache(prefs),
    );
  }

  final OpenWeatherClient _client;
  final WeatherCache _cache;
  final OpenWeatherMapper _mapper;
  final DateTime Function() _now;

  @override
  Future<WeatherReport> getWeather({
    required WeatherLocation location,
    Units units = Units.metric,
  }) async {
    final String locationId = location.cacheKey;
    try {
      final OpenWeatherOneCallResponse response = await _client.fetchOneCall(
        lat: location.latitude,
        lon: location.longitude,
        units: units,
      );
      final DateTime storedAt = _now();
      final OpenWeatherCacheEntry entry = OpenWeatherCacheEntry(
        locationId: locationId,
        storedAt: storedAt,
        payload: response,
      );
      await _cache.write(entry);
      return _mapper.toReport(
        response: response,
        location: location,
        updatedAt: storedAt,
        dataSource: WeatherDataSource.network,
      );
    } on OpenWeatherRequestException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        final WeatherReport? fallback = await _fetchForecastReport(
          location,
          units,
        );
        if (fallback != null) {
          return fallback;
        }
        final OpenWeatherCacheEntry? cached = await _cache.read(locationId);
        if (cached != null) {
          return _mapper.toReport(
            response: cached.payload,
            location: location,
            updatedAt: cached.storedAt,
            dataSource: WeatherDataSource.cache,
          );
        }
        rethrow;
      }
      final OpenWeatherCacheEntry? cached = await _cache.read(locationId);
      if (cached != null) {
        return _mapper.toReport(
          response: cached.payload,
          location: location,
          updatedAt: cached.storedAt,
          dataSource: WeatherDataSource.cache,
        );
      }
      rethrow;
    } catch (error) {
      final OpenWeatherCacheEntry? cached = await _cache.read(locationId);
      if (cached != null) {
        return _mapper.toReport(
          response: cached.payload,
          location: location,
          updatedAt: cached.storedAt,
          dataSource: WeatherDataSource.cache,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<WeatherLocation>> searchLocations({
    required String query,
    int limit = 5,
  }) async {
    final List<OpenWeatherGeocodingResult> results = await _client
        .searchLocations(query: query, limit: limit);
    return results
        .map(
          (OpenWeatherGeocodingResult result) => WeatherLocation(
            latitude: result.lat,
            longitude: result.lon,
            name: result.name,
            country: result.country,
            state: result.state,
            source: LocationSource.search,
          ),
        )
        .toList();
  }

  @override
  Future<WeatherLocation> resolveLocation({
    required double latitude,
    required double longitude,
  }) async {
    final List<OpenWeatherGeocodingResult> results = await _client
        .reverseGeocode(latitude: latitude, longitude: longitude, limit: 1);
    if (results.isEmpty) {
      return WeatherLocation(
        latitude: latitude,
        longitude: longitude,
        name: 'Current location',
        country: '',
        source: LocationSource.gps,
      );
    }
    final OpenWeatherGeocodingResult resolved = results.first;
    return WeatherLocation(
      latitude: resolved.lat,
      longitude: resolved.lon,
      name: resolved.name,
      country: resolved.country,
      state: resolved.state,
      source: LocationSource.gps,
    );
  }

  Future<WeatherReport?> _fetchForecastReport(
    WeatherLocation location,
    Units units,
  ) async {
    OpenWeatherCurrentResponse? current;
    OpenWeatherForecastResponse? forecast;

    try {
      current = await _client.fetchCurrentWeather(
        lat: location.latitude,
        lon: location.longitude,
        units: units,
      );
    } catch (_) {}

    try {
      forecast = await _client.fetchForecast(
        lat: location.latitude,
        lon: location.longitude,
        units: units,
      );
    } catch (_) {}

    if (current == null && forecast == null) {
      return null;
    }

    final DateTime storedAt = _now();

    if (forecast != null) {
      return _mapper.toReportFromForecast(
        forecast: forecast,
        current: current,
        location: _mergeLocationFromForecast(location, forecast),
        updatedAt: storedAt,
        dataSource: WeatherDataSource.network,
      );
    }

    return _mapper.toReportFromCurrent(
      response: current!,
      location: _mergeLocationFromCurrent(location, current),
      updatedAt: storedAt,
      dataSource: WeatherDataSource.network,
    );
  }

  WeatherLocation _mergeLocationFromCurrent(
    WeatherLocation location,
    OpenWeatherCurrentResponse response,
  ) {
    final String name = response.name.isNotEmpty
        ? response.name
        : location.name;
    final String country = response.sys.country.isNotEmpty
        ? response.sys.country
        : location.country;
    return WeatherLocation(
      latitude: response.coord.lat == 0
          ? location.latitude
          : response.coord.lat,
      longitude: response.coord.lon == 0
          ? location.longitude
          : response.coord.lon,
      name: name,
      country: country,
      state: location.state,
      source: location.source,
    );
  }

  WeatherLocation _mergeLocationFromForecast(
    WeatherLocation location,
    OpenWeatherForecastResponse forecast,
  ) {
    final String name = forecast.city.name.isNotEmpty
        ? forecast.city.name
        : location.name;
    final String country = forecast.city.country.isNotEmpty
        ? forecast.city.country
        : location.country;
    return WeatherLocation(
      latitude: forecast.city.coord.lat == 0
          ? location.latitude
          : forecast.city.coord.lat,
      longitude: forecast.city.coord.lon == 0
          ? location.longitude
          : forecast.city.coord.lon,
      name: name,
      country: country,
      state: location.state,
      source: location.source,
    );
  }
}
