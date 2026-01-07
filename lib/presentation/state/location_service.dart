import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationServiceError {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.error);

  final LocationServiceError error;

  @override
  String toString() {
    return 'LocationServiceException: ${error.name}';
  }
}

abstract class LocationService {
  Future<Position> getCurrentPosition();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        LocationServiceError.servicesDisabled,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        LocationServiceError.permissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        LocationServiceError.permissionDeniedForever,
      );
    }

    final Position? lastKnown = await Geolocator.getLastKnownPosition();
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      if (lastKnown != null) {
        return lastKnown;
      }
      throw const LocationServiceException(LocationServiceError.timeout);
    }
  }
}
