// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_weather_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenWeatherCurrentResponse _$OpenWeatherCurrentResponseFromJson(
  Map<String, dynamic> json,
) => OpenWeatherCurrentResponse(
  coord: OpenWeatherCoord.fromJson(json['coord'] as Map<String, dynamic>),
  weather:
      (json['weather'] as List<dynamic>?)
          ?.map((e) => OpenWeatherCondition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  main: OpenWeatherMain.fromJson(json['main'] as Map<String, dynamic>),
  wind: OpenWeatherWind.fromJson(json['wind'] as Map<String, dynamic>),
  clouds: OpenWeatherClouds.fromJson(json['clouds'] as Map<String, dynamic>),
  sys: OpenWeatherSys.fromJson(json['sys'] as Map<String, dynamic>),
  dt: (json['dt'] as num?)?.toInt() ?? 0,
  timezone: (json['timezone'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  cod: json['cod'] == null ? 0 : _intFromJson(json['cod']),
  base: json['base'] as String? ?? '',
  visibility: (json['visibility'] as num?)?.toInt() ?? 0,
  id: (json['id'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OpenWeatherCurrentResponseToJson(
  OpenWeatherCurrentResponse instance,
) => <String, dynamic>{
  'coord': instance.coord.toJson(),
  'weather': instance.weather.map((e) => e.toJson()).toList(),
  'base': instance.base,
  'main': instance.main.toJson(),
  'visibility': instance.visibility,
  'wind': instance.wind.toJson(),
  'clouds': instance.clouds.toJson(),
  'dt': instance.dt,
  'sys': instance.sys.toJson(),
  'timezone': instance.timezone,
  'id': instance.id,
  'name': instance.name,
  'cod': instance.cod,
};

OpenWeatherForecastResponse _$OpenWeatherForecastResponseFromJson(
  Map<String, dynamic> json,
) => OpenWeatherForecastResponse(
  list:
      (json['list'] as List<dynamic>?)
          ?.map(
            (e) => OpenWeatherForecastItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  city: OpenWeatherForecastCity.fromJson(json['city'] as Map<String, dynamic>),
  cod: json['cod'] == null ? 0 : _intFromJson(json['cod']),
);

Map<String, dynamic> _$OpenWeatherForecastResponseToJson(
  OpenWeatherForecastResponse instance,
) => <String, dynamic>{
  'list': instance.list.map((e) => e.toJson()).toList(),
  'city': instance.city.toJson(),
  'cod': instance.cod,
};

OpenWeatherForecastItem _$OpenWeatherForecastItemFromJson(
  Map<String, dynamic> json,
) => OpenWeatherForecastItem(
  dt: (json['dt'] as num?)?.toInt() ?? 0,
  main: OpenWeatherMain.fromJson(json['main'] as Map<String, dynamic>),
  weather:
      (json['weather'] as List<dynamic>?)
          ?.map((e) => OpenWeatherCondition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  wind: OpenWeatherWind.fromJson(json['wind'] as Map<String, dynamic>),
  pop: (json['pop'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OpenWeatherForecastItemToJson(
  OpenWeatherForecastItem instance,
) => <String, dynamic>{
  'dt': instance.dt,
  'main': instance.main.toJson(),
  'weather': instance.weather.map((e) => e.toJson()).toList(),
  'wind': instance.wind.toJson(),
  'pop': instance.pop,
};

OpenWeatherForecastCity _$OpenWeatherForecastCityFromJson(
  Map<String, dynamic> json,
) => OpenWeatherForecastCity(
  name: json['name'] as String? ?? '',
  country: json['country'] as String? ?? '',
  timezone: (json['timezone'] as num?)?.toInt() ?? 0,
  coord: OpenWeatherCoord.fromJson(json['coord'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenWeatherForecastCityToJson(
  OpenWeatherForecastCity instance,
) => <String, dynamic>{
  'name': instance.name,
  'country': instance.country,
  'timezone': instance.timezone,
  'coord': instance.coord.toJson(),
};

OpenWeatherOneCallResponse _$OpenWeatherOneCallResponseFromJson(
  Map<String, dynamic> json,
) => OpenWeatherOneCallResponse(
  lat: (json['lat'] as num?)?.toDouble() ?? 0,
  lon: (json['lon'] as num?)?.toDouble() ?? 0,
  timezone: json['timezone'] as String,
  timezoneOffset: (json['timezone_offset'] as num?)?.toInt() ?? 0,
  current: OpenWeatherCurrent.fromJson(json['current'] as Map<String, dynamic>),
  hourly: (json['hourly'] as List<dynamic>)
      .map((e) => OpenWeatherHourly.fromJson(e as Map<String, dynamic>))
      .toList(),
  daily: (json['daily'] as List<dynamic>)
      .map((e) => OpenWeatherDaily.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenWeatherOneCallResponseToJson(
  OpenWeatherOneCallResponse instance,
) => <String, dynamic>{
  'lat': instance.lat,
  'lon': instance.lon,
  'timezone': instance.timezone,
  'timezone_offset': instance.timezoneOffset,
  'current': instance.current.toJson(),
  'hourly': instance.hourly.map((e) => e.toJson()).toList(),
  'daily': instance.daily.map((e) => e.toJson()).toList(),
};

OpenWeatherCoord _$OpenWeatherCoordFromJson(Map<String, dynamic> json) =>
    OpenWeatherCoord(
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$OpenWeatherCoordToJson(OpenWeatherCoord instance) =>
    <String, dynamic>{'lon': instance.lon, 'lat': instance.lat};

OpenWeatherMain _$OpenWeatherMainFromJson(Map<String, dynamic> json) =>
    OpenWeatherMain(
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 0,
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 0,
      pressure: (json['pressure'] as num?)?.toInt() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      seaLevel: (json['sea_level'] as num?)?.toInt(),
      groundLevel: (json['grnd_level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OpenWeatherMainToJson(OpenWeatherMain instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.feelsLike,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
      'pressure': instance.pressure,
      'humidity': instance.humidity,
      'sea_level': instance.seaLevel,
      'grnd_level': instance.groundLevel,
    };

OpenWeatherWind _$OpenWeatherWindFromJson(Map<String, dynamic> json) =>
    OpenWeatherWind(
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      deg: (json['deg'] as num?)?.toInt() ?? 0,
      gust: (json['gust'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OpenWeatherWindToJson(OpenWeatherWind instance) =>
    <String, dynamic>{
      'speed': instance.speed,
      'deg': instance.deg,
      'gust': instance.gust,
    };

OpenWeatherClouds _$OpenWeatherCloudsFromJson(Map<String, dynamic> json) =>
    OpenWeatherClouds(all: (json['all'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$OpenWeatherCloudsToJson(OpenWeatherClouds instance) =>
    <String, dynamic>{'all': instance.all};

OpenWeatherSys _$OpenWeatherSysFromJson(Map<String, dynamic> json) =>
    OpenWeatherSys(
      country: json['country'] as String? ?? '',
      type: (json['type'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      sunrise: (json['sunrise'] as num?)?.toInt(),
      sunset: (json['sunset'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OpenWeatherSysToJson(OpenWeatherSys instance) =>
    <String, dynamic>{
      'country': instance.country,
      'type': instance.type,
      'id': instance.id,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
    };

OpenWeatherCurrent _$OpenWeatherCurrentFromJson(Map<String, dynamic> json) =>
    OpenWeatherCurrent(
      dt: (json['dt'] as num?)?.toInt() ?? 0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0,
      weather: (json['weather'] as List<dynamic>)
          .map((e) => OpenWeatherCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      sunrise: (json['sunrise'] as num?)?.toInt(),
      sunset: (json['sunset'] as num?)?.toInt(),
      pop: (json['pop'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OpenWeatherCurrentToJson(OpenWeatherCurrent instance) =>
    <String, dynamic>{
      'dt': instance.dt,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'temp': instance.temp,
      'feels_like': instance.feelsLike,
      'humidity': instance.humidity,
      'wind_speed': instance.windSpeed,
      'weather': instance.weather.map((e) => e.toJson()).toList(),
      'pop': instance.pop,
    };

OpenWeatherHourly _$OpenWeatherHourlyFromJson(Map<String, dynamic> json) =>
    OpenWeatherHourly(
      dt: (json['dt'] as num?)?.toInt() ?? 0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      weather: (json['weather'] as List<dynamic>)
          .map((e) => OpenWeatherCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      pop: (json['pop'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OpenWeatherHourlyToJson(OpenWeatherHourly instance) =>
    <String, dynamic>{
      'dt': instance.dt,
      'temp': instance.temp,
      'weather': instance.weather.map((e) => e.toJson()).toList(),
      'pop': instance.pop,
    };

OpenWeatherDaily _$OpenWeatherDailyFromJson(Map<String, dynamic> json) =>
    OpenWeatherDaily(
      dt: (json['dt'] as num?)?.toInt() ?? 0,
      temp: OpenWeatherDailyTemp.fromJson(json['temp'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => OpenWeatherCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      sunrise: (json['sunrise'] as num?)?.toInt(),
      sunset: (json['sunset'] as num?)?.toInt(),
      pop: (json['pop'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OpenWeatherDailyToJson(OpenWeatherDaily instance) =>
    <String, dynamic>{
      'dt': instance.dt,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'temp': instance.temp.toJson(),
      'weather': instance.weather.map((e) => e.toJson()).toList(),
      'pop': instance.pop,
    };

OpenWeatherDailyTemp _$OpenWeatherDailyTempFromJson(
  Map<String, dynamic> json,
) => OpenWeatherDailyTemp(
  min: (json['min'] as num?)?.toDouble() ?? 0,
  max: (json['max'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$OpenWeatherDailyTempToJson(
  OpenWeatherDailyTemp instance,
) => <String, dynamic>{'min': instance.min, 'max': instance.max};

OpenWeatherCondition _$OpenWeatherConditionFromJson(
  Map<String, dynamic> json,
) => OpenWeatherCondition(
  id: (json['id'] as num?)?.toInt() ?? 0,
  main: json['main'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
);

Map<String, dynamic> _$OpenWeatherConditionToJson(
  OpenWeatherCondition instance,
) => <String, dynamic>{
  'id': instance.id,
  'main': instance.main,
  'description': instance.description,
  'icon': instance.icon,
};

OpenWeatherGeocodingResult _$OpenWeatherGeocodingResultFromJson(
  Map<String, dynamic> json,
) => OpenWeatherGeocodingResult(
  name: json['name'] as String,
  lat: (json['lat'] as num?)?.toDouble() ?? 0,
  lon: (json['lon'] as num?)?.toDouble() ?? 0,
  country: json['country'] as String,
  state: json['state'] as String?,
);

Map<String, dynamic> _$OpenWeatherGeocodingResultToJson(
  OpenWeatherGeocodingResult instance,
) => <String, dynamic>{
  'name': instance.name,
  'lat': instance.lat,
  'lon': instance.lon,
  'country': instance.country,
  'state': instance.state,
};
