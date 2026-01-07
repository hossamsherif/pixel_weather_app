import '../../domain/models/location.dart';
import '../../domain/models/weather.dart';
import 'open_weather_models.dart';

class OpenWeatherMapper {
  const OpenWeatherMapper();

  WeatherReport toReport({
    required OpenWeatherOneCallResponse response,
    required WeatherLocation location,
    required DateTime updatedAt,
    required WeatherDataSource dataSource,
    int hourlyLimit = 24,
    int dailyLimit = 5,
  }) {
    final int offset = response.timezoneOffset;
    final CurrentWeather current = _mapCurrent(response.current, offset);
    final List<HourlyForecast> hourly = response.hourly
        .take(hourlyLimit)
        .map((OpenWeatherHourly item) => _mapHourly(item, offset))
        .toList();
    final List<DailyForecast> daily = response.daily
        .take(dailyLimit)
        .map((OpenWeatherDaily item) => _mapDaily(item, offset))
        .toList();

    return WeatherReport(
      location: location,
      current: current,
      hourly: hourly,
      daily: daily,
      updatedAt: updatedAt,
      dataSource: dataSource,
    );
  }

  WeatherReport toReportFromCurrent({
    required OpenWeatherCurrentResponse response,
    required WeatherLocation location,
    required DateTime updatedAt,
    required WeatherDataSource dataSource,
  }) {
    final int offset = response.timezone;
    final CurrentWeather current = _mapCurrentFromCurrentResponse(
      response,
      offset,
    );

    return WeatherReport(
      location: location,
      current: current,
      hourly: const <HourlyForecast>[],
      daily: const <DailyForecast>[],
      updatedAt: updatedAt,
      dataSource: dataSource,
    );
  }

  WeatherReport toReportFromForecast({
    required OpenWeatherForecastResponse forecast,
    required OpenWeatherCurrentResponse? current,
    required WeatherLocation location,
    required DateTime updatedAt,
    required WeatherDataSource dataSource,
    int hourlyLimit = 24,
    int dailyLimit = 5,
  }) {
    final int offset = forecast.city.timezone;
    final List<OpenWeatherForecastItem> items =
        List<OpenWeatherForecastItem>.of(forecast.list)
          ..sort((a, b) => a.dt.compareTo(b.dt));

    final CurrentWeather currentWeather = current != null
        ? _mapCurrentFromCurrentResponse(current, offset)
        : _mapCurrentFromForecast(items, offset, updatedAt);

    final List<HourlyForecast> hourly = items.take(hourlyLimit).map((
      OpenWeatherForecastItem item,
    ) {
      return _mapHourlyFromForecast(item, offset);
    }).toList();

    final List<DailyForecast> daily = _mapDailyFromForecast(
      items: items,
      offsetSeconds: offset,
      limit: dailyLimit,
    );

    return WeatherReport(
      location: location,
      current: currentWeather,
      hourly: hourly,
      daily: daily,
      updatedAt: updatedAt,
      dataSource: dataSource,
    );
  }

  WeatherCondition _mapCondition(List<OpenWeatherCondition> conditions) {
    if (conditions.isEmpty) {
      return const WeatherCondition(
        type: WeatherConditionType.unknown,
        description: 'Unknown',
      );
    }
    final OpenWeatherCondition condition = conditions.first;
    return WeatherCondition(
      type: _mapConditionType(condition.id),
      description: condition.description,
    );
  }

  WeatherConditionType _mapConditionType(int code) {
    if (code >= 200 && code <= 232) {
      return WeatherConditionType.thunder;
    }
    if (code >= 300 && code <= 321) {
      return WeatherConditionType.rain;
    }
    if (code >= 500 && code <= 531) {
      return WeatherConditionType.rain;
    }
    if (code >= 600 && code <= 622) {
      return WeatherConditionType.snow;
    }
    if (code >= 701 && code <= 781) {
      return WeatherConditionType.fog;
    }
    if (code == 800) {
      return WeatherConditionType.clear;
    }
    if (code >= 801 && code <= 804) {
      return WeatherConditionType.clouds;
    }
    return WeatherConditionType.unknown;
  }

  CurrentWeather _mapCurrent(OpenWeatherCurrent current, int offsetSeconds) {
    return CurrentWeather(
      observedAt: _toLocalTime(current.dt, offsetSeconds),
      temperature: current.temp,
      feelsLike: current.feelsLike,
      humidity: current.humidity,
      windSpeed: current.windSpeed,
      condition: _mapCondition(current.weather),
      sunrise: _mapOptionalTime(current.sunrise, offsetSeconds),
      sunset: _mapOptionalTime(current.sunset, offsetSeconds),
      precipitationChance: current.pop,
    );
  }

  CurrentWeather _mapCurrentFromCurrentResponse(
    OpenWeatherCurrentResponse response,
    int offsetSeconds,
  ) {
    return CurrentWeather(
      observedAt: _toLocalTime(response.dt, offsetSeconds),
      temperature: response.main.temp,
      feelsLike: response.main.feelsLike,
      humidity: response.main.humidity,
      windSpeed: response.wind.speed,
      condition: _mapCondition(response.weather),
      sunrise: _mapOptionalTime(response.sys.sunrise, offsetSeconds),
      sunset: _mapOptionalTime(response.sys.sunset, offsetSeconds),
    );
  }

  HourlyForecast _mapHourly(OpenWeatherHourly hourly, int offsetSeconds) {
    return HourlyForecast(
      time: _toLocalTime(hourly.dt, offsetSeconds),
      temperature: hourly.temp,
      condition: _mapCondition(hourly.weather),
      precipitationChance: hourly.pop,
    );
  }

  DailyForecast _mapDaily(OpenWeatherDaily daily, int offsetSeconds) {
    return DailyForecast(
      date: _toLocalTime(daily.dt, offsetSeconds),
      minTemp: daily.temp.min,
      maxTemp: daily.temp.max,
      condition: _mapCondition(daily.weather),
      sunrise: _mapOptionalTime(daily.sunrise, offsetSeconds),
      sunset: _mapOptionalTime(daily.sunset, offsetSeconds),
      precipitationChance: daily.pop,
    );
  }

  CurrentWeather _mapCurrentFromForecast(
    List<OpenWeatherForecastItem> items,
    int offsetSeconds,
    DateTime updatedAt,
  ) {
    if (items.isEmpty) {
      return CurrentWeather(
        observedAt: updatedAt,
        temperature: 0,
        feelsLike: 0,
        humidity: 0,
        windSpeed: 0,
        condition: const WeatherCondition(
          type: WeatherConditionType.unknown,
          description: 'Unknown',
        ),
      );
    }
    final OpenWeatherForecastItem first = items.first;
    return CurrentWeather(
      observedAt: _toLocalTime(first.dt, offsetSeconds),
      temperature: first.main.temp,
      feelsLike: first.main.feelsLike,
      humidity: first.main.humidity,
      windSpeed: first.wind.speed,
      condition: _mapCondition(first.weather),
    );
  }

  HourlyForecast _mapHourlyFromForecast(
    OpenWeatherForecastItem item,
    int offsetSeconds,
  ) {
    return HourlyForecast(
      time: _toLocalTime(item.dt, offsetSeconds),
      temperature: item.main.temp,
      condition: _mapCondition(item.weather),
      precipitationChance: item.pop,
    );
  }

  List<DailyForecast> _mapDailyFromForecast({
    required List<OpenWeatherForecastItem> items,
    required int offsetSeconds,
    required int limit,
  }) {
    final Map<DateTime, List<OpenWeatherForecastItem>> grouped =
        <DateTime, List<OpenWeatherForecastItem>>{};
    for (final OpenWeatherForecastItem item in items) {
      final DateTime local = _toLocalTime(item.dt, offsetSeconds);
      final DateTime key = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(key, () => <OpenWeatherForecastItem>[]).add(item);
    }

    final List<DateTime> keys = grouped.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return keys.take(limit).map((DateTime day) {
      final List<OpenWeatherForecastItem> dayItems = grouped[day]!;
      final OpenWeatherForecastItem representative = _selectMiddayItem(
        dayItems,
        offsetSeconds,
      );
      double minTemp = dayItems.first.main.tempMin;
      double maxTemp = dayItems.first.main.tempMax;
      double? pop;
      for (final OpenWeatherForecastItem item in dayItems) {
        if (item.main.tempMin < minTemp) {
          minTemp = item.main.tempMin;
        }
        if (item.main.tempMax > maxTemp) {
          maxTemp = item.main.tempMax;
        }
        if (item.pop != null) {
          final double value = item.pop!.clamp(0, 1).toDouble();
          pop = pop == null || value > pop ? value : pop;
        }
      }

      return DailyForecast(
        date: day,
        minTemp: minTemp,
        maxTemp: maxTemp,
        condition: _mapCondition(representative.weather),
        precipitationChance: pop,
      );
    }).toList();
  }

  OpenWeatherForecastItem _selectMiddayItem(
    List<OpenWeatherForecastItem> items,
    int offsetSeconds,
  ) {
    OpenWeatherForecastItem best = items.first;
    int bestDelta = 24;
    for (final OpenWeatherForecastItem item in items) {
      final DateTime local = _toLocalTime(item.dt, offsetSeconds);
      final int delta = (local.hour - 12).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = item;
      }
    }
    return best;
  }

  DateTime _toLocalTime(int seconds, int offsetSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).add(Duration(seconds: offsetSeconds));
  }

  DateTime? _mapOptionalTime(int? seconds, int offsetSeconds) {
    if (seconds == null) {
      return null;
    }
    return _toLocalTime(seconds, offsetSeconds);
  }
}
