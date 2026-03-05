import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/units.dart';
import 'open_weather_exceptions.dart';
import 'open_weather_models.dart';

class OpenWeatherClient {
  OpenWeatherClient({required this.apiKey, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _httpClient;

  static const String _host = 'api.openweathermap.org';

  Future<List<OpenWeatherGeocodingResult>> searchLocations({
    required String query,
    int limit = 5,
  }) async {
    _assertKey();
    final Uri uri = Uri.https(_host, '/geo/1.0/direct', <String, String>{
      'q': query,
      'limit': '$limit',
      'appid': apiKey,
    });

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw _exceptionFrom(response);
    }

    final List<dynamic> payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map(
          (dynamic item) =>
              OpenWeatherGeocodingResult.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<OpenWeatherGeocodingResult>> reverseGeocode({
    required double latitude,
    required double longitude,
    int limit = 1,
  }) async {
    _assertKey();
    final Uri uri = Uri.https(_host, '/geo/1.0/reverse', <String, String>{
      'lat': '$latitude',
      'lon': '$longitude',
      'limit': '$limit',
      'appid': apiKey,
    });

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw _exceptionFrom(response);
    }

    final List<dynamic> payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map(
          (dynamic item) =>
              OpenWeatherGeocodingResult.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<OpenWeatherOneCallResponse> fetchOneCall({
    required double lat,
    required double lon,
    required Units units,
    String? languageCode,
  }) async {
    _assertKey();
    final Uri uri = Uri.https(_host, '/data/2.5/onecall', <String, String>{
      'lat': '$lat',
      'lon': '$lon',
      'units': units.queryValue,
      'exclude': 'minutely,alerts',
      'appid': apiKey,
      if (languageCode != null) 'lang': languageCode,
    });

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw _exceptionFrom(response);
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    return OpenWeatherOneCallResponse.fromJson(payload);
  }

  Future<OpenWeatherCurrentResponse> fetchCurrentWeather({
    required double lat,
    required double lon,
    required Units units,
    String? languageCode,
  }) async {
    _assertKey();
    final Uri uri = Uri.https(_host, '/data/2.5/weather', <String, String>{
      'lat': '$lat',
      'lon': '$lon',
      'units': units.queryValue,
      'appid': apiKey,
      if (languageCode != null) 'lang': languageCode,
    });

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw _exceptionFrom(response);
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    return OpenWeatherCurrentResponse.fromJson(payload);
  }

  Future<OpenWeatherForecastResponse> fetchForecast({
    required double lat,
    required double lon,
    required Units units,
    String? languageCode,
  }) async {
    _assertKey();
    final Uri uri = Uri.https(_host, '/data/2.5/forecast', <String, String>{
      'lat': '$lat',
      'lon': '$lon',
      'units': units.queryValue,
      'appid': apiKey,
      if (languageCode != null) 'lang': languageCode,
    });

    final http.Response response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw _exceptionFrom(response);
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    return OpenWeatherForecastResponse.fromJson(payload);
  }

  void _assertKey() {
    if (apiKey.isEmpty) {
      throw const OpenWeatherApiKeyMissingException();
    }
  }

  OpenWeatherRequestException _exceptionFrom(http.Response response) {
    String message = 'OpenWeather request failed';
    try {
      final Object decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          decoded['message'] is String &&
          (decoded['message'] as String).trim().isNotEmpty) {
        message = decoded['message'] as String;
      }
    } catch (_) {}

    return OpenWeatherRequestException(
      statusCode: response.statusCode,
      message: message,
    );
  }
}
