// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PixelWeather';

  @override
  String get tabNow => 'Now';

  @override
  String get tabForecast => 'Forecast';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get search => 'Search';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search city';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locationPermissionDeniedTitle => 'Location permission denied';

  @override
  String get locationPermissionDeniedBody =>
      'Enable location access in settings or search for a city.';

  @override
  String get locationServicesDisabledTitle => 'Location services are off';

  @override
  String get locationServicesDisabledBody =>
      'Turn on location services to use GPS weather.';

  @override
  String get locationTimeoutTitle => 'Location timeout';

  @override
  String get locationTimeoutBody =>
      'We couldn\'t get a GPS fix. Try again or search for a city.';

  @override
  String get noSearchResultsTitle => 'No results';

  @override
  String get noSearchResultsBody => 'Try a different city name.';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get retry => 'Retry';

  @override
  String get addFavorite => 'Add favorite';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get unitsMetric => 'Units: Celsius';

  @override
  String get unitsImperial => 'Units: Fahrenheit';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get hourlyForecast => 'Hourly';

  @override
  String get dailyForecast => '5-day';

  @override
  String get forecastUnavailableTitle => 'No forecast data';

  @override
  String get forecastUnavailableBody =>
      'Forecast data is unavailable for this location.';

  @override
  String get emptyNowTitle => 'No weather yet';

  @override
  String get emptyNowBody =>
      'Search for a city or enable location to see current conditions.';

  @override
  String get emptyForecastTitle => 'No forecast yet';

  @override
  String get emptyForecastBody =>
      'Select a location to view hourly and daily forecasts.';

  @override
  String get emptyFavoritesTitle => 'No favorites yet';

  @override
  String get emptyFavoritesBody => 'Save locations to access them quickly.';

  @override
  String get offlineBadge => 'Offline';

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }
}
