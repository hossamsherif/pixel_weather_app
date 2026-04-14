import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/data/cache/open_weather_cache_entry.dart';
import 'package:pixel_weather_app/data/cache/weather_cache.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_client.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_exceptions.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_repository.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockOpenWeatherClient extends Mock implements OpenWeatherClient {}

class _MockWeatherCache extends Mock implements WeatherCache {}

class _FakeCacheEntry extends Fake implements OpenWeatherCacheEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(_FakeCacheEntry());
    registerFallbackValue(Units.metric);
  });

  group('OpenWeatherClient error handling', () {
    late _MockHttpClient httpClient;
    late OpenWeatherClient client;

    setUp(() {
      httpClient = _MockHttpClient();
      client = OpenWeatherClient(apiKey: 'k', httpClient: httpClient);
    });

    test('searchLocations throws request exception with response message', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"message":"bad query"}', 400),
      );

      await expectLater(
        () => client.searchLocations(query: 'x'),
        throwsA(
          isA<OpenWeatherRequestException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'bad query'),
        ),
      );
    });

    test('reverseGeocode throws request exception with default message', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('not-json', 500),
      );

      await expectLater(
        () => client.reverseGeocode(latitude: 1, longitude: 2),
        throwsA(
          isA<OpenWeatherRequestException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having(
                (e) => e.message,
                'message',
                'OpenWeather request failed',
              ),
        ),
      );
    });

    test('empty API key throws api-key-missing exception', () async {
      final emptyKeyClient = OpenWeatherClient(apiKey: '', httpClient: httpClient);
      await expectLater(
        () => emptyKeyClient.fetchForecast(lat: 1, lon: 2, units: Units.metric),
        throwsA(isA<OpenWeatherApiKeyMissingException>()),
      );
    });

    test('fetchCurrentWeather throws exception for non-200', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'message': 'denied'}), 403),
      );

      await expectLater(
        () => client.fetchCurrentWeather(lat: 1, lon: 2, units: Units.metric),
        throwsA(isA<OpenWeatherRequestException>()),
      );
    });
  });

  group('OpenWeatherRepository API fallbacks and cache', () {
    late _MockOpenWeatherClient client;
    late _MockWeatherCache cache;
    late OpenWeatherRepository repository;

    setUp(() {
      client = _MockOpenWeatherClient();
      cache = _MockWeatherCache();
      repository = OpenWeatherRepository(client: client, cache: cache);
      when(() => cache.write(any())).thenAnswer((_) async {});
      when(() => cache.read(any())).thenAnswer((_) async => null);
    });

    test('401 triggers fallback current+forecast path', () async {
      final location = _location();

      when(
        () => client.fetchOneCall(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(
        const OpenWeatherRequestException(statusCode: 401, message: 'unauth'),
      );

      when(
        () => client.fetchCurrentWeather(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => _currentResponse());

      when(
        () => client.fetchForecast(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => _forecastResponse());

      final report = await repository.getWeather(location: location);

      expect(report.dataSource, WeatherDataSource.network);
      expect(report.location.name, isNotEmpty);
      verifyNever(() => cache.read(any()));
    });

    test('403 fallback fails then cache used', () async {
      final location = _location();
      final cached = OpenWeatherCacheEntry(
        locationId: location.cacheKey,
        storedAt: DateTime(2024, 1, 1),
        payload: _oneCall(),
      );

      when(
        () => client.fetchOneCall(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(
        const OpenWeatherRequestException(statusCode: 403, message: 'forbidden'),
      );

      when(
        () => client.fetchCurrentWeather(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(Exception('fail current'));
      when(
        () => client.fetchForecast(
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
          units: any(named: 'units'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(Exception('fail forecast'));
      when(() => cache.read(location.cacheKey)).thenAnswer((_) async => cached);

      final report = await repository.getWeather(location: location);
      expect(report.dataSource, WeatherDataSource.cache);
    });
  });
}

WeatherLocation _location() => const WeatherLocation(
      latitude: 30,
      longitude: 31,
      name: 'Cairo',
      country: 'EG',
      source: LocationSource.search,
    );

OpenWeatherOneCallResponse _oneCall() => OpenWeatherOneCallResponse(
      lat: 30,
      lon: 31,
      timezone: 'Africa/Cairo',
      timezoneOffset: 7200,
      current: OpenWeatherCurrent(
        dt: 1,
        temp: 20,
        feelsLike: 19,
        humidity: 60,
        windSpeed: 4,
        weather: const [
          OpenWeatherCondition(
            id: 800,
            main: 'Clear',
            description: 'clear',
            icon: '01d',
          )
        ],
      ),
      hourly: const [],
      daily: const [],
    );

OpenWeatherCurrentResponse _currentResponse() => OpenWeatherCurrentResponse(
      coord: const OpenWeatherCoord(lat: 30, lon: 31),
      weather: const [
        OpenWeatherCondition(
          id: 800,
          main: 'Clear',
          description: 'clear',
          icon: '01d',
        )
      ],
      main: const OpenWeatherMain(
        temp: 20,
        feelsLike: 19,
        tempMin: 18,
        tempMax: 22,
        pressure: 1000,
        humidity: 60,
      ),
      wind: const OpenWeatherWind(speed: 4, deg: 100),
      clouds: const OpenWeatherClouds(all: 0),
      sys: const OpenWeatherSys(country: 'EG'),
      dt: 1,
      timezone: 7200,
      name: 'Cairo',
      cod: 200,
      base: 'stations',
      visibility: 10000,
      id: 1,
    );

OpenWeatherForecastResponse _forecastResponse() => OpenWeatherForecastResponse(
      list: const [
        OpenWeatherForecastItem(
          dt: 1,
          main: OpenWeatherMain(
            temp: 21,
            feelsLike: 20,
            tempMin: 19,
            tempMax: 23,
            pressure: 1001,
            humidity: 58,
          ),
          weather: [
            OpenWeatherCondition(
              id: 801,
              main: 'Clouds',
              description: 'few clouds',
              icon: '02d',
            )
          ],
          wind: OpenWeatherWind(speed: 4, deg: 120),
        )
      ],
      city: const OpenWeatherForecastCity(
        name: 'Cairo',
        country: 'EG',
        timezone: 7200,
        coord: OpenWeatherCoord(lat: 30, lon: 31),
      ),
      cod: 200,
    );
