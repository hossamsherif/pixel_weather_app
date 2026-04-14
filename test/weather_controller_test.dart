import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/domain/repositories/weather_repository.dart';
import 'package:pixel_weather_app/presentation/state/location_service.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLocationService extends Mock implements LocationService {}

class MockWidgetService extends Mock implements WidgetService {}

class TestLocaleController extends LocaleController {
  final Locale? initialLocale;
  TestLocaleController({this.initialLocale});
  @override
  Locale? build() => initialLocale;
}

void main() {
  late MockWeatherRepository repository;
  late MockSharedPreferences sharedPrefs;
  late MockLocationService locationService;
  late MockWidgetService widgetService;

  setUpAll(() {
    registerFallbackValue(
      const WeatherLocation(
        latitude: 0,
        longitude: 0,
        name: '',
        country: '',
        source: LocationSource.gps,
      ),
    );
    registerFallbackValue(Units.metric);
    registerFallbackValue(
      _fakeReport(
        const WeatherLocation(
          latitude: 0,
          longitude: 0,
          name: '',
          country: '',
          source: LocationSource.gps,
        ),
      ),
    );
  });

  setUp(() {
    repository = MockWeatherRepository();
    sharedPrefs = MockSharedPreferences();
    locationService = MockLocationService();
    widgetService = MockWidgetService();

    when(() => sharedPrefs.getString(any())).thenReturn(null);
    when(
      () => sharedPrefs.setString(any(), any()),
    ).thenAnswer((_) async => true);

    when(() => widgetService.updateWidget(any())).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({Locale? initialLocale}) {
    final container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        locationServiceProvider.overrideWithValue(locationService),
        widgetServiceProvider.overrideWithValue(widgetService),
        if (initialLocale != null)
          localeProvider.overrideWith(
            () => TestLocaleController(initialLocale: initialLocale),
          ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'WeatherController build passes languageCode from localeProvider',
    () async {
      final location = const WeatherLocation(
        latitude: 1.0,
        longitude: 2.0,
        name: 'Test',
        country: 'TS',
        source: LocationSource.gps,
      );

      when(() => sharedPrefs.getString('last_location')).thenReturn(null);
      when(
        () => locationService.canAccessLocation(),
      ).thenAnswer((_) async => true);
      when(
        () => locationService.getCurrentPosition(),
      ).thenAnswer((_) async => FakePosition());
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

      final container = createContainer(initialLocale: const Locale('ar'));

      // Trigger build
      await container.read(weatherControllerProvider.future);

      verify(
        () => repository.getWeather(
          location: location,
          units: Units.metric,
          languageCode: 'ar',
        ),
      ).called(1);

      verify(() => widgetService.updateWidget(any())).called(1);
    },
  );

  test('WeatherController refresh uses current locale', () async {
    final location = const WeatherLocation(
      latitude: 1.0,
      longitude: 2.0,
      name: 'Test',
      country: 'TS',
      source: LocationSource.gps,
    );

    when(
      () => repository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => _fakeReport(location));

    final container = createContainer(initialLocale: const Locale('en'));

    final controller = container.read(weatherControllerProvider.notifier);

    // Set an initial state with a location
    await controller.loadForLocation(location);

    // Refresh with Arabic
    container.read(localeProvider.notifier).setLocale(const Locale('ar'));
    await controller.refresh();

    verify(
      () => repository.getWeather(
        location: location,
        units: Units.metric,
        languageCode: 'ar',
      ),
    ).called(1);

    verify(
      () => widgetService.updateWidget(any()),
    ).called(greaterThanOrEqualTo(2));
  });
}

class FakePosition extends Fake implements Position {
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
