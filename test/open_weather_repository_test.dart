import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_client.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_repository.dart';
import 'package:pixel_weather_app/data/cache/open_weather_cache_entry.dart';
import 'package:pixel_weather_app/data/cache/weather_cache.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_mapper.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';

class MockOpenWeatherClient extends Mock implements OpenWeatherClient {}

class MockWeatherCache extends Mock implements WeatherCache {}

class OpenWeatherCacheEntryFake extends Fake implements OpenWeatherCacheEntry {}

void main() {
  late MockOpenWeatherClient client;
  late MockWeatherCache cache;
  late OpenWeatherRepository repository;

  setUpAll(() {
    registerFallbackValue(OpenWeatherCacheEntryFake());
    registerFallbackValue(Units.metric);
  });

  setUp(() {
    client = MockOpenWeatherClient();
    cache = MockWeatherCache();
    repository = OpenWeatherRepository(client: client, cache: cache);

    when(() => cache.write(any())).thenAnswer((_) async {});
    when(() => cache.read(any())).thenAnswer((_) async => null);
  });

  test('getWeather passes languageCode to client', () async {
    final location = const WeatherLocation(
      latitude: 1.0,
      longitude: 2.0,
      name: 'Test',
      country: 'TS',
      source: LocationSource.search,
    );

    when(
      () => client.fetchOneCall(
        lat: any(named: 'lat'),
        lon: any(named: 'lon'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => _fakeOneCall());

    await repository.getWeather(
      location: location,
      units: Units.metric,
      languageCode: 'ar',
    );

    verify(
      () => client.fetchOneCall(
        lat: 1.0,
        lon: 2.0,
        units: Units.metric,
        languageCode: 'ar',
      ),
    ).called(1);
  });

  test('getWeather caches response on success', () async {
    final location = const WeatherLocation(
      latitude: 1.0,
      longitude: 2.0,
      name: 'Test',
      country: 'TS',
      source: LocationSource.search,
    );

    when(
      () => client.fetchOneCall(
        lat: any(named: 'lat'),
        lon: any(named: 'lon'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => _fakeOneCall());

    await repository.getWeather(location: location);

    verify(() => cache.write(any())).called(1);
  });

  test('getWeather falls back to cache on client exception', () async {
    final location = const WeatherLocation(
      latitude: 1.0,
      longitude: 2.0,
      name: 'Test',
      country: 'TS',
      source: LocationSource.search,
    );

    final cached = OpenWeatherCacheEntry(
      locationId: location.cacheKey,
      storedAt: DateTime(2024, 1, 1),
      payload: _fakeOneCall(),
    );

    when(
      () => client.fetchOneCall(
        lat: any(named: 'lat'),
        lon: any(named: 'lon'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(Exception('network'));

    when(() => cache.read(location.cacheKey)).thenAnswer((_) async => cached);

    final report = await repository.getWeather(location: location);

    expect(report.dataSource, WeatherDataSource.cache);
  });

  test('searchLocations maps results', () async {
    when(
      () => client.searchLocations(query: any(named: 'query'), limit: 5),
    ).thenAnswer(
      (_) async => [
        const OpenWeatherGeocodingResult(
          name: 'Test',
          lat: 1,
          lon: 2,
          country: 'TS',
          state: 'State',
        ),
      ],
    );

    final results = await repository.searchLocations(query: 'Te');

    expect(results, hasLength(1));
    expect(results.first.name, 'Test');
    expect(results.first.state, 'State');
  });

  test('resolveLocation returns fallback when empty', () async {
    when(
      () => client.reverseGeocode(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        limit: 1,
      ),
    ).thenAnswer((_) async => []);

    final location = await repository.resolveLocation(
      latitude: 10,
      longitude: 20,
    );

    expect(location.name, 'Current location');
    expect(location.source, LocationSource.gps);
  });

  test('resolveLocation maps first result', () async {
    when(
      () => client.reverseGeocode(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        limit: 1,
      ),
    ).thenAnswer(
      (_) async => [
        const OpenWeatherGeocodingResult(
          name: 'Test',
          lat: 1,
          lon: 2,
          country: 'TS',
          state: 'State',
        ),
      ],
    );

    final location = await repository.resolveLocation(
      latitude: 10,
      longitude: 20,
    );

    expect(location.name, 'Test');
    expect(location.country, 'TS');
  });
}

OpenWeatherOneCallResponse _fakeOneCall() {
  return OpenWeatherOneCallResponse(
    lat: 1.0,
    lon: 2.0,
    timezone: 'UTC',
    timezoneOffset: 0,
    current: OpenWeatherCurrent(
      dt: 0,
      temp: 280,
      feelsLike: 279,
      humidity: 50,
      windSpeed: 2,
      weather: const [
        OpenWeatherCondition(
          id: 800,
          main: 'Clear',
          description: 'clear',
          icon: '01d',
        ),
      ],
      sunrise: null,
      sunset: null,
      pop: null,
    ),
    hourly: const [],
    daily: const [],
  );
}
