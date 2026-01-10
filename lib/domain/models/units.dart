enum Units { metric, imperial }

extension UnitsQuery on Units {
  String get queryValue {
    switch (this) {
      case Units.metric:
        return 'metric';
      case Units.imperial:
        return 'imperial';
    }
  }

  String get displayValue {
    switch (this) {
      case Units.metric:
        return '°C';
      case Units.imperial:
        return '°F';
    }
  }
}
