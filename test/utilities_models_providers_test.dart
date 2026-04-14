import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/app_routes.dart';
import 'package:pixel_weather_app/core/config/app_config.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_models.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/l10n/app_localizations_ar.dart';
import 'package:pixel_weather_app/l10n/app_localizations_en.dart';
import 'package:pixel_weather_app/presentation/state/app_providers.dart';

void main() {
  group('Constants and utilities', () {
    test('AppRoutes constants are stable', () {
      expect(AppRoutes.forecast, 'forecast');
      expect(AppRoutes.favorites, 'favorites');
      expect(AppRoutes.search, 'search');
    });

    test('AppConfig exposes non-empty weather key', () {
      expect(AppConfig.openWeatherKey, isNotEmpty);
    });

    test('Units extension values map correctly', () {
      expect(Units.metric.queryValue, 'metric');
      expect(Units.metric.displayValue, '°C');
      expect(Units.imperial.queryValue, 'imperial');
      expect(Units.imperial.displayValue, '°F');
    });
  });

  group('Localizations', () {
    test('lookupAppLocalizations supports en and ar', () {
      expect(lookupAppLocalizations(const Locale('en')), isA<AppLocalizationsEn>());
      expect(lookupAppLocalizations(const Locale('ar')), isA<AppLocalizationsAr>());
    });

    test('delegate support and reload behavior', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
      expect(delegate.shouldReload(delegate), isFalse);
    });

    test('english and arabic getters return expected core strings', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();

      expect(en.appTitle, 'PixelWeather');
      expect(en.tabForecast, 'Forecast');
      expect(en.loading, 'Loading...');
      expect(en.lastUpdated('10:00'), 'Last updated 10:00');

      expect(ar.appTitle, 'بكسل ويزر');
      expect(ar.tabForecast, 'التوقعات');
      expect(ar.loading, 'جارٍ التحميل...');
      expect(ar.lastUpdated('10:00'), 'آخر تحديث 10:00');
    });

    test('unsupported locale throws flutter error', () {
      expect(
        () => lookupAppLocalizations(const Locale('fr')),
        throwsA(isA<FlutterError>()),
      );
    });
  });

  group('Provider controllers', () {
    test('UnitsController setUnits updates state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(unitsProvider), Units.metric);
      container.read(unitsProvider.notifier).setUnits(Units.imperial);
      expect(container.read(unitsProvider), Units.imperial);
    });

    test('LocaleController toggles between ar and en', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeProvider), isNull);
      container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('ar'));
      container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('en'));
      container.read(localeProvider.notifier).setLocale(const Locale('ar'));
      expect(container.read(localeProvider), const Locale('ar'));
    });

    test('SearchQueryController setQuery updates state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
      container.read(searchQueryProvider.notifier).setQuery('Cairo');
      expect(container.read(searchQueryProvider), 'Cairo');
    });
  });

  group('OpenWeather models serialization', () {
    test('OpenWeatherCoord defaults and toJson', () {
      final coord = OpenWeatherCoord.fromJson(const {});
      expect(coord.lat, 0);
      expect(coord.lon, 0);
      expect(coord.toJson(), containsPair('lat', 0));
      expect(coord.toJson(), containsPair('lon', 0));
    });

    test('OpenWeatherMain defaults and optional fields', () {
      final main = OpenWeatherMain.fromJson(const {});
      expect(main.temp, 0);
      expect(main.feelsLike, 0);
      expect(main.tempMin, 0);
      expect(main.tempMax, 0);
      expect(main.pressure, 0);
      expect(main.humidity, 0);
      expect(main.seaLevel, isNull);
      expect(main.groundLevel, isNull);
      expect(main.toJson()['feels_like'], 0);
    });

    test('OpenWeatherCondition roundtrip', () {
      final condition = OpenWeatherCondition.fromJson(const {
        'id': 800,
        'main': 'Clear',
        'description': 'clear sky',
        'icon': '01d',
      });
      expect(condition.id, 800);
      expect(condition.main, 'Clear');
      expect(condition.toJson()['description'], 'clear sky');
    });

    test('OpenWeatherCurrentResponse parses cod as string and defaults', () {
      final current = OpenWeatherCurrentResponse.fromJson({
        'coord': {'lat': 1, 'lon': 2},
        'weather': [
          {'id': 800, 'main': 'Clear', 'description': 'clear', 'icon': '01d'},
        ],
        'main': {
          'temp': 22,
          'feels_like': 21,
          'temp_min': 20,
          'temp_max': 24,
          'pressure': 1000,
          'humidity': 50,
        },
        'wind': {'speed': 3, 'deg': 100},
        'clouds': {'all': 0},
        'sys': {'country': 'EG'},
        'cod': '200',
      });

      expect(current.cod, 200);
      expect(current.timezone, 0);
      expect(current.name, '');
      expect(current.base, '');
      expect(current.toJson()['cod'], 200);
    });

    test('OpenWeatherForecastResponse parses cod and list defaults', () {
      final forecast = OpenWeatherForecastResponse.fromJson({
        'city': {
          'name': 'Cairo',
          'country': 'EG',
          'timezone': 7200,
          'coord': {'lat': 30.0, 'lon': 31.0},
        },
        'cod': 200,
      });
      expect(forecast.cod, 200);
      expect(forecast.list, isEmpty);
      expect(forecast.city.name, 'Cairo');
      expect(forecast.toJson()['cod'], 200);
    });

    test('OneCall model parses full graph and serializes', () {
      final oneCall = OpenWeatherOneCallResponse.fromJson({
        'lat': 30.0,
        'lon': 31.0,
        'timezone': 'Africa/Cairo',
        'timezone_offset': 7200,
        'current': {
          'dt': 1,
          'temp': 20,
          'feels_like': 19,
          'humidity': 60,
          'wind_speed': 4,
          'weather': [
            {'id': 801, 'main': 'Clouds', 'description': 'few clouds', 'icon': '02d'},
          ],
        },
        'hourly': [
          {
            'dt': 2,
            'temp': 21,
            'weather': [
              {'id': 500, 'main': 'Rain', 'description': 'light rain', 'icon': '10d'},
            ],
            'pop': 0.2,
          },
        ],
        'daily': [
          {
            'dt': 3,
            'temp': {'min': 10, 'max': 25},
            'weather': [
              {'id': 600, 'main': 'Snow', 'description': 'snow', 'icon': '13d'},
            ],
            'pop': 0.1,
          },
        ],
      });

      expect(oneCall.timezone, 'Africa/Cairo');
      expect(oneCall.current.weather.first.main, 'Clouds');
      expect(oneCall.hourly.first.weather.first.main, 'Rain');
      expect(oneCall.daily.first.temp.max, 25);
      expect(oneCall.toJson()['timezone'], 'Africa/Cairo');
    });

    test('Geocoding result roundtrip', () {
      final g = OpenWeatherGeocodingResult.fromJson(const {
        'name': 'Alexandria',
        'lat': 31.2,
        'lon': 29.9,
        'country': 'EG',
        'state': 'Alex',
      });
      expect(g.name, 'Alexandria');
      expect(g.state, 'Alex');
      expect(g.toJson()['country'], 'EG');
    });
  });
}
