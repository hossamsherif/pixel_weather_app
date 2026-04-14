import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/presentation/widgets/condition_icon.dart';

void main() {
  test('iconForCondition maps all weather types', () {
    expect(iconForCondition(WeatherConditionType.clear), Icons.wb_sunny_outlined);
    expect(iconForCondition(WeatherConditionType.clouds), Icons.cloud_outlined);
    expect(iconForCondition(WeatherConditionType.rain), Icons.grain);
    expect(iconForCondition(WeatherConditionType.thunder), Icons.flash_on_outlined);
    expect(iconForCondition(WeatherConditionType.snow), Icons.ac_unit);
    expect(iconForCondition(WeatherConditionType.fog), Icons.blur_on);
    expect(iconForCondition(WeatherConditionType.unknown), Icons.help_outline);
  });
}
