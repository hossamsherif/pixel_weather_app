import 'package:flutter/widgets.dart';

import '../../domain/models/weather.dart';

const String _assetRoot = 'assets/weather/pixel/exported';

String conditionAssetFor(WeatherCondition condition, {required bool isDay}) {
  final String variant = isDay ? 'day' : 'night';
  return '$_assetRoot/$variant/${_assetName(condition.type)}.png';
}

ImageProvider conditionImageFor(
  WeatherCondition condition, {
  required bool isDay,
}) {
  return AssetImage(conditionAssetFor(condition, isDay: isDay));
}

String _assetName(WeatherConditionType type) {
  switch (type) {
    case WeatherConditionType.clear:
      return 'clear';
    case WeatherConditionType.clouds:
      return 'clouds';
    case WeatherConditionType.rain:
      return 'rain';
    case WeatherConditionType.thunder:
      return 'thunder';
    case WeatherConditionType.snow:
      return 'snow';
    case WeatherConditionType.fog:
      return 'fog';
    case WeatherConditionType.unknown:
      return 'unknown';
  }
}

bool isDayForCurrentWeather(CurrentWeather current) {
  if (current.condition.hasDayIcon) {
    return true;
  }
  if (current.condition.hasNightIcon) {
    return false;
  }
  final DateTime? sunrise = current.sunrise;
  final DateTime? sunset = current.sunset;
  if (sunrise != null && sunset != null) {
    return !current.observedAt.isBefore(sunrise) &&
        current.observedAt.isBefore(sunset);
  }
  return true;
}
