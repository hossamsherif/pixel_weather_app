import 'package:flutter/material.dart';

import '../../domain/models/weather.dart';

IconData iconForCondition(WeatherConditionType type) {
  switch (type) {
    case WeatherConditionType.clear:
      return Icons.wb_sunny_outlined;
    case WeatherConditionType.clouds:
      return Icons.cloud_outlined;
    case WeatherConditionType.rain:
      return Icons.grain;
    case WeatherConditionType.thunder:
      return Icons.flash_on_outlined;
    case WeatherConditionType.snow:
      return Icons.ac_unit;
    case WeatherConditionType.fog:
      return Icons.blur_on;
    case WeatherConditionType.unknown:
      return Icons.help_outline;
  }
}
