import 'package:json_annotation/json_annotation.dart';

part 'open_weather_models.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenWeatherCurrentResponse {
  const OpenWeatherCurrentResponse({
    required this.coord,
    required this.weather,
    required this.main,
    required this.wind,
    required this.clouds,
    required this.sys,
    required this.dt,
    required this.timezone,
    required this.name,
    required this.cod,
    required this.base,
    required this.visibility,
    required this.id,
  });

  final OpenWeatherCoord coord;
  @JsonKey(defaultValue: <OpenWeatherCondition>[])
  final List<OpenWeatherCondition> weather;
  @JsonKey(defaultValue: '')
  final String base;
  final OpenWeatherMain main;
  @JsonKey(defaultValue: 0)
  final int visibility;
  final OpenWeatherWind wind;
  final OpenWeatherClouds clouds;
  @JsonKey(defaultValue: 0)
  final int dt;
  final OpenWeatherSys sys;
  @JsonKey(defaultValue: 0)
  final int timezone;
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(fromJson: _intFromJson, defaultValue: 0)
  final int cod;

  factory OpenWeatherCurrentResponse.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherCurrentResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherCurrentResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherForecastResponse {
  const OpenWeatherForecastResponse({
    required this.list,
    required this.city,
    required this.cod,
  });

  @JsonKey(defaultValue: <OpenWeatherForecastItem>[])
  final List<OpenWeatherForecastItem> list;
  final OpenWeatherForecastCity city;
  @JsonKey(fromJson: _intFromJson, defaultValue: 0)
  final int cod;

  factory OpenWeatherForecastResponse.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherForecastResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherForecastResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherForecastItem {
  const OpenWeatherForecastItem({
    required this.dt,
    required this.main,
    required this.weather,
    required this.wind,
    this.pop,
  });

  @JsonKey(defaultValue: 0)
  final int dt;
  final OpenWeatherMain main;
  @JsonKey(defaultValue: <OpenWeatherCondition>[])
  final List<OpenWeatherCondition> weather;
  final OpenWeatherWind wind;
  final double? pop;

  factory OpenWeatherForecastItem.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherForecastItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherForecastItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherForecastCity {
  const OpenWeatherForecastCity({
    required this.name,
    required this.country,
    required this.timezone,
    required this.coord,
  });

  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String country;
  @JsonKey(defaultValue: 0)
  final int timezone;
  final OpenWeatherCoord coord;

  factory OpenWeatherForecastCity.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherForecastCityFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherForecastCityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherOneCallResponse {
  const OpenWeatherOneCallResponse({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneOffset,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  @JsonKey(defaultValue: 0)
  final double lat;
  @JsonKey(defaultValue: 0)
  final double lon;
  final String timezone;
  @JsonKey(name: 'timezone_offset', defaultValue: 0)
  final int timezoneOffset;
  final OpenWeatherCurrent current;
  final List<OpenWeatherHourly> hourly;
  final List<OpenWeatherDaily> daily;

  factory OpenWeatherOneCallResponse.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherOneCallResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherOneCallResponseToJson(this);
}

@JsonSerializable()
class OpenWeatherCoord {
  const OpenWeatherCoord({required this.lon, required this.lat});

  @JsonKey(defaultValue: 0)
  final double lon;
  @JsonKey(defaultValue: 0)
  final double lat;

  factory OpenWeatherCoord.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherCoordFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherCoordToJson(this);
}

@JsonSerializable()
class OpenWeatherMain {
  const OpenWeatherMain({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    this.seaLevel,
    this.groundLevel,
  });

  @JsonKey(defaultValue: 0)
  final double temp;
  @JsonKey(name: 'feels_like', defaultValue: 0)
  final double feelsLike;
  @JsonKey(name: 'temp_min', defaultValue: 0)
  final double tempMin;
  @JsonKey(name: 'temp_max', defaultValue: 0)
  final double tempMax;
  @JsonKey(defaultValue: 0)
  final int pressure;
  @JsonKey(defaultValue: 0)
  final int humidity;
  @JsonKey(name: 'sea_level')
  final int? seaLevel;
  @JsonKey(name: 'grnd_level')
  final int? groundLevel;

  factory OpenWeatherMain.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherMainFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherMainToJson(this);
}

@JsonSerializable()
class OpenWeatherWind {
  const OpenWeatherWind({required this.speed, required this.deg, this.gust});

  @JsonKey(defaultValue: 0)
  final double speed;
  @JsonKey(defaultValue: 0)
  final int deg;
  final double? gust;

  factory OpenWeatherWind.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherWindFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherWindToJson(this);
}

@JsonSerializable()
class OpenWeatherClouds {
  const OpenWeatherClouds({required this.all});

  @JsonKey(defaultValue: 0)
  final int all;

  factory OpenWeatherClouds.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherCloudsFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherCloudsToJson(this);
}

@JsonSerializable()
class OpenWeatherSys {
  const OpenWeatherSys({
    required this.country,
    this.type,
    this.id,
    this.sunrise,
    this.sunset,
  });

  @JsonKey(defaultValue: '')
  final String country;
  final int? type;
  final int? id;
  final int? sunrise;
  final int? sunset;

  factory OpenWeatherSys.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherSysFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherSysToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherCurrent {
  const OpenWeatherCurrent({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weather,
    this.sunrise,
    this.sunset,
    this.pop,
  });

  @JsonKey(defaultValue: 0)
  final int dt;
  final int? sunrise;
  final int? sunset;
  @JsonKey(defaultValue: 0)
  final double temp;
  @JsonKey(name: 'feels_like', defaultValue: 0)
  final double feelsLike;
  @JsonKey(defaultValue: 0)
  final int humidity;
  @JsonKey(name: 'wind_speed', defaultValue: 0)
  final double windSpeed;
  final List<OpenWeatherCondition> weather;
  final double? pop;

  factory OpenWeatherCurrent.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherCurrentFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherCurrentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherHourly {
  const OpenWeatherHourly({
    required this.dt,
    required this.temp,
    required this.weather,
    this.pop,
  });

  @JsonKey(defaultValue: 0)
  final int dt;
  @JsonKey(defaultValue: 0)
  final double temp;
  final List<OpenWeatherCondition> weather;
  final double? pop;

  factory OpenWeatherHourly.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherHourlyFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherHourlyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenWeatherDaily {
  const OpenWeatherDaily({
    required this.dt,
    required this.temp,
    required this.weather,
    this.sunrise,
    this.sunset,
    this.pop,
  });

  @JsonKey(defaultValue: 0)
  final int dt;
  final int? sunrise;
  final int? sunset;
  final OpenWeatherDailyTemp temp;
  final List<OpenWeatherCondition> weather;
  final double? pop;

  factory OpenWeatherDaily.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherDailyFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherDailyToJson(this);
}

@JsonSerializable()
class OpenWeatherDailyTemp {
  const OpenWeatherDailyTemp({required this.min, required this.max});

  @JsonKey(defaultValue: 0)
  final double min;
  @JsonKey(defaultValue: 0)
  final double max;

  factory OpenWeatherDailyTemp.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherDailyTempFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherDailyTempToJson(this);
}

@JsonSerializable()
class OpenWeatherCondition {
  const OpenWeatherCondition({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  final String main;
  final String description;
  final String icon;

  factory OpenWeatherCondition.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherConditionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherConditionToJson(this);
}

@JsonSerializable()
class OpenWeatherGeocodingResult {
  const OpenWeatherGeocodingResult({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
    this.state,
  });

  final String name;
  @JsonKey(defaultValue: 0)
  final double lat;
  @JsonKey(defaultValue: 0)
  final double lon;
  final String country;
  final String? state;

  factory OpenWeatherGeocodingResult.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherGeocodingResultFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherGeocodingResultToJson(this);
}

int _intFromJson(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
