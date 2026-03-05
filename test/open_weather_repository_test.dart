import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_client.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_repository.dart';
import 'package:pixel_weather_app/data/cache/open_weather_cache_entry.dart';
import 'package:pixel_weather_app/data/cache/weather_cache.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';

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
    ).thenAnswer(
      (_) async => OpenWeatherOneCallResponse(
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
      ),
    );

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
}
