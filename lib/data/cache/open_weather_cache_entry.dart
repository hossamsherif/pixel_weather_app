import 'package:json_annotation/json_annotation.dart';

import '../open_weather/open_weather_models.dart';

part 'open_weather_cache_entry.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenWeatherCacheEntry {
  const OpenWeatherCacheEntry({
    required this.locationId,
    required this.storedAt,
    required this.payload,
  });

  final String locationId;
  final DateTime storedAt;
  final OpenWeatherOneCallResponse payload;

  factory OpenWeatherCacheEntry.fromJson(Map<String, dynamic> json) {
    return _$OpenWeatherCacheEntryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenWeatherCacheEntryToJson(this);
}
