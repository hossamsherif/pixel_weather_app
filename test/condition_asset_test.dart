import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/presentation/widgets/condition_asset.dart';

void main() {
  test('conditionAssetFor maps every condition to day and night sprites', () {
    for (final WeatherConditionType type in WeatherConditionType.values) {
      final WeatherCondition condition = WeatherCondition(
        type: type,
        description: type.name,
      );

      expect(
        conditionAssetFor(condition, isDay: true),
        'assets/weather/pixel/exported/day/${type.name}.png',
      );
      expect(
        conditionAssetFor(condition, isDay: false),
        'assets/weather/pixel/exported/night/${type.name}.png',
      );
    }
  });

  test('isDayForCurrentWeather prefers OpenWeather icon variant', () {
    expect(
      isDayForCurrentWeather(_current(iconCode: '01d', observedHour: 23)),
      isTrue,
    );
    expect(
      isDayForCurrentWeather(_current(iconCode: '01n', observedHour: 12)),
      isFalse,
    );
  });

  test('isDayForCurrentWeather falls back to sunrise and sunset', () {
    expect(isDayForCurrentWeather(_current(observedHour: 12)), isTrue);
    expect(isDayForCurrentWeather(_current(observedHour: 22)), isFalse);
  });
}

CurrentWeather _current({String? iconCode, required int observedHour}) {
  return CurrentWeather(
    observedAt: DateTime(2024, 1, 1, observedHour),
    temperature: 22,
    feelsLike: 20,
    humidity: 60,
    windSpeed: 3,
    sunrise: DateTime(2024, 1, 1, 6),
    sunset: DateTime(2024, 1, 1, 18),
    condition: WeatherCondition(
      type: WeatherConditionType.clear,
      description: 'Clear',
      iconCode: iconCode,
    ),
  );
}
