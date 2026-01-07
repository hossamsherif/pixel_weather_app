import 'location.dart';

enum WeatherConditionType { clear, clouds, rain, thunder, snow, fog, unknown }

class WeatherCondition {
  const WeatherCondition({required this.type, required this.description});

  final WeatherConditionType type;
  final String description;
}

class CurrentWeather {
  const CurrentWeather({
    required this.observedAt,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    this.sunrise,
    this.sunset,
    this.precipitationChance,
  });

  final DateTime observedAt;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final WeatherCondition condition;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? precipitationChance;
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    this.precipitationChance,
  });

  final DateTime time;
  final double temperature;
  final WeatherCondition condition;
  final double? precipitationChance;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    this.sunrise,
    this.sunset,
    this.precipitationChance,
  });

  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final WeatherCondition condition;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? precipitationChance;
}

enum WeatherDataSource { network, cache }

class WeatherReport {
  const WeatherReport({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.updatedAt,
    required this.dataSource,
  });

  final WeatherLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime updatedAt;
  final WeatherDataSource dataSource;
}
