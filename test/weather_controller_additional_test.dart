import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/core/services/widget_service.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/domain/repositories/weather_repository.dart';
import 'package:pixel_weather_app/presentation/state/location_service.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLocationService extends Mock implements LocationService {}

class MockWidgetService extends Mock implements WidgetService {}

void main() {
  late MockWeatherRepository repository;
  late MockSharedPreferences sharedPrefs;
  late MockLocationService locationService;
  late MockWidgetService widgetService;

  final location = const WeatherLocation(
    latitude: 1.0,
    longitude: 2.0,
    name: 'Test',
    country: 'TS',
    source: LocationSource.gps,
  );

  setUpAll(() {
    registerFallbackValue(location);
    registerFallbackValue(Units.metric);
    registerFallbackValue(_fakeReport(location));
  });

  setUp(() {
    repository = MockWeatherRepository();
    sharedPrefs = MockSharedPreferences();
    locationService = MockLocationService();
    widgetService = MockWidgetService();

    when(() => sharedPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => widgetService.updateWidget(any())).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({Locale? locale}) {
    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        locationServiceProvider.overrideWithValue(locationService),
        widgetServiceProvider.overrideWithValue(widgetService),
        if (locale != null)
          localeProvider.overrideWith(() => _TestLocaleController(locale)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build returns null when no location access', () async {
    when(() => sharedPrefs.getString(any())).thenReturn(null);
    when(() => locationService.canAccessLocation()).thenAnswer((_) async => false);

    final container = createContainer();

    final report = await container.read(weatherControllerProvider.future);

    expect(report, isNull);
    verify(() => locationService.canAccessLocation()).called(1);
    verifyNever(() => locationService.getCurrentPosition());
  });

  test('build uses last location from shared preferences', () async {
    final storedLocation = WeatherLocation(
      latitude: 5,
      longitude: 6,
      name: 'Stored',
      country: 'TS',
      source: LocationSource.search,
    );
    when(() => sharedPrefs.getString(any())).thenReturn(
      jsonEncode(storedLocation.toJson()),
    );

    when(
      () => repository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => _fakeReport(storedLocation));

    final container = createContainer();

    final report = await container.read(weatherControllerProvider.future);

    expect(report?.location.name, 'Stored');
    verifyNever(() => locationService.getCurrentPosition());
    verify(() => widgetService.updateWidget(any())).called(1);
  });

  test('loadForCurrentLocation resolves location and saves', () async {
    when(() => sharedPrefs.getString(any())).thenReturn(null);
    when(() => locationService.getCurrentPosition()).thenAnswer((_) async => _FakePosition());
    when(
      () => repository.resolveLocation(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => location);

    when(
      () => repository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => _fakeReport(location));

    final container = createContainer();
    final controller = container.read(weatherControllerProvider.notifier);

    await controller.loadForCurrentLocation();

    verify(() => sharedPrefs.setString(any(), any())).called(1);
    verify(() => widgetService.updateWidget(any())).called(1);
  });

  test('refresh does nothing when no location', () async {
    final container = createContainer();
    final controller = container.read(weatherControllerProvider.notifier);

    await controller.refresh();

    verifyNever(
      () => repository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    );
  });
}

class _TestLocaleController extends LocaleController {
  _TestLocaleController(this.locale);
  final Locale locale;

  @override
  Locale? build() => locale;
}

class _FakePosition extends Fake implements Position {
  @override
  double get latitude => 1.0;
  @override
  double get longitude => 2.0;
  @override
  DateTime get timestamp => DateTime.now();
  @override
  double get accuracy => 0.0;
  @override
  double get altitude => 0.0;
  @override
  double get heading => 0.0;
  @override
  double get speed => 0.0;
  @override
  double get speedAccuracy => 0.0;
  @override
  double get altitudeAccuracy => 0.0;
  @override
  double get headingAccuracy => 0.0;
}

WeatherReport _fakeReport(WeatherLocation location) {
  return WeatherReport(
    location: location,
    current: CurrentWeather(
      observedAt: DateTime.now(),
      temperature: 20,
      feelsLike: 19,
      condition: const WeatherCondition(
        type: WeatherConditionType.clear,
        description: 'clear',
      ),
      humidity: 50,
      windSpeed: 2,
    ),
    hourly: const [],
    daily: const [],
    updatedAt: DateTime.now(),
    dataSource: WeatherDataSource.network,
  );
}
