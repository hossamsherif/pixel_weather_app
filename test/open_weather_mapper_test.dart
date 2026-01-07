import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_weather_app/data/open_weather/open_weather_mapper.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';

void main() {
  test('toReportFromForecast builds hourly and daily forecasts', () {
    final OpenWeatherMapper mapper = OpenWeatherMapper();
    final DateTime start = DateTime.utc(2025, 1, 1, 0);
    final List<OpenWeatherForecastItem> items = <OpenWeatherForecastItem>[];

    for (int day = 0; day < 5; day++) {
      for (int slot = 0; slot < 8; slot++) {
        final DateTime time = start.add(Duration(hours: day * 24 + slot * 3));
        items.add(
          _forecastItem(
            dt: time.millisecondsSinceEpoch ~/ 1000,
            temp: 280.0 + day,
            min: 279.0 + day,
            max: 281.0 + day,
          ),
        );
      }
    }

    final OpenWeatherForecastResponse forecast = OpenWeatherForecastResponse(
      list: items,
      city: OpenWeatherForecastCity(
        name: 'Test City',
        country: 'US',
        timezone: 0,
        coord: const OpenWeatherCoord(lat: 1, lon: 2),
      ),
      cod: 200,
    );

    final WeatherReport report = mapper.toReportFromForecast(
      forecast: forecast,
      current: null,
      location: const WeatherLocation(
        latitude: 1,
        longitude: 2,
        name: 'Test City',
        country: 'US',
        source: LocationSource.search,
      ),
      updatedAt: start,
      dataSource: WeatherDataSource.network,
    );

    expect(report.hourly.length, 24);
    expect(report.daily.length, 5);
    expect(report.current.temperature, 280);
    expect(report.daily.first.minTemp, 279);
    expect(report.daily.first.maxTemp, 281);
    expect(report.daily.first.date.year, 2025);
    expect(report.daily.first.date.month, 1);
    expect(report.daily.first.date.day, 1);
  });
}

OpenWeatherForecastItem _forecastItem({
  required int dt,
  required double temp,
  required double min,
  required double max,
}) {
  return OpenWeatherForecastItem(
    dt: dt,
    main: OpenWeatherMain(
      temp: temp,
      feelsLike: temp,
      tempMin: min,
      tempMax: max,
      pressure: 1000,
      humidity: 50,
      seaLevel: null,
      groundLevel: null,
    ),
    weather: const <OpenWeatherCondition>[
      OpenWeatherCondition(
        id: 800,
        main: 'Clear',
        description: 'clear sky',
        icon: '01d',
      ),
    ],
    wind: const OpenWeatherWind(speed: 3, deg: 180, gust: null),
    pop: 0.1,
  );
}
