// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_weather_cache_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenWeatherCacheEntry _$OpenWeatherCacheEntryFromJson(
  Map<String, dynamic> json,
) => OpenWeatherCacheEntry(
  locationId: json['locationId'] as String,
  storedAt: DateTime.parse(json['storedAt'] as String),
  payload: OpenWeatherOneCallResponse.fromJson(
    json['payload'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OpenWeatherCacheEntryToJson(
  OpenWeatherCacheEntry instance,
) => <String, dynamic>{
  'locationId': instance.locationId,
  'storedAt': instance.storedAt.toIso8601String(),
  'payload': instance.payload.toJson(),
};
