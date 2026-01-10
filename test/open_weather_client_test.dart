import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_client.dart';
import 'package:pixel_weather_app/domain/models/units.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient httpClient;
  late OpenWeatherClient client;
  const apiKey = 'test_api_key';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    httpClient = MockHttpClient();
    client = OpenWeatherClient(apiKey: apiKey, httpClient: httpClient);
  });

  group('OpenWeatherClient lang parameter', () {
    test('fetchOneCall includes lang parameter when provided', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'lat': 1.0,
            'lon': 2.0,
            'timezone': 'UTC',
            'timezone_offset': 0,
            'current': {
              'dt': 0,
              'temp': 280,
              'feels_like': 279,
              'humidity': 50,
              'wind_speed': 2,
              'weather': [
                {
                  'id': 800,
                  'main': 'Clear',
                  'description': 'clear',
                  'icon': '01d',
                },
              ],
            },
            'hourly': [],
            'daily': [],
          }),
          200,
        ),
      );

      await client.fetchOneCall(
        lat: 1.0,
        lon: 2.0,
        units: Units.metric,
        languageCode: 'ar',
      );

      final capturedUri =
          verify(() => httpClient.get(captureAny())).captured.first as Uri;
      expect(capturedUri.queryParameters['lang'], 'ar');
    });

    test('fetchCurrentWeather includes lang parameter when provided', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'coord': {'lat': 1.0, 'lon': 2.0},
            'weather': [
              {
                'id': 800,
                'main': 'Clear',
                'description': 'clear',
                'icon': '01d',
              },
            ],
            'main': {
              'temp': 280,
              'feels_like': 279,
              'temp_min': 278,
              'temp_max': 282,
              'pressure': 1000,
              'humidity': 50,
            },
            'wind': {'speed': 2, 'deg': 180},
            'clouds': {'all': 0},
            'sys': {'country': 'EG'},
            'name': 'Cairo',
            'dt': 0,
            'timezone': 0,
            'cod': 200,
            'base': 'stations',
            'visibility': 10000,
            'id': 1,
          }),
          200,
        ),
      );

      await client.fetchCurrentWeather(
        lat: 1.0,
        lon: 2.0,
        units: Units.metric,
        languageCode: 'ar',
      );

      final capturedUri =
          verify(() => httpClient.get(captureAny())).captured.first as Uri;
      expect(capturedUri.queryParameters['lang'], 'ar');
    });

    test('fetchForecast includes lang parameter when provided', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'list': [],
            'city': {
              'name': 'Cairo',
              'country': 'EG',
              'coord': {'lat': 1.0, 'lon': 2.0},
              'timezone': 0,
            },
            'cod': '200',
          }),
          200,
        ),
      );

      await client.fetchForecast(
        lat: 1.0,
        lon: 2.0,
        units: Units.metric,
        languageCode: 'ar',
      );

      final capturedUri =
          verify(() => httpClient.get(captureAny())).captured.first as Uri;
      expect(capturedUri.queryParameters['lang'], 'ar');
    });
  });
}
