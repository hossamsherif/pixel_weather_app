enum LocationSource { gps, search, favorite }

class WeatherLocation {
  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
    required this.source,
    this.state,
  });

  final double latitude;
  final double longitude;
  final String name;
  final String country;
  final String? state;
  final LocationSource source;

  String get displayName {
    final List<String> parts = <String>[
      name,
      if (state != null && state!.isNotEmpty) state!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  String get cacheKey {
    final String lat = latitude.toStringAsFixed(4);
    final String lon = longitude.toStringAsFixed(4);
    return '$lat,$lon';
  }

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      state: json['state'] as String?,
      source: LocationSource.values.firstWhere(
        (LocationSource item) => item.name == json['source'],
        orElse: () => LocationSource.search,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'country': country,
      'state': state,
      'source': source.name,
    };
  }
}
