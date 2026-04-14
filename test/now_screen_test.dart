import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/domain/repositories/weather_repository.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/data/open_weather/open_weather_exceptions.dart';
import 'package:pixel_weather_app/presentation/screens/now_screen.dart';
import 'package:pixel_weather_app/presentation/state/app_providers.dart';
import 'package:pixel_weather_app/presentation/state/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockWidgetService extends Mock implements WidgetService {}

class MockPosition extends Mock implements Position {}

class FakeWeatherReport extends Fake implements WeatherReport {}

const _testLocation = WeatherLocation(
  latitude: 51.5,
  longitude: -0.12,
  name: 'London',
  country: 'GB',
  source: LocationSource.gps,
);

void main() {
  late MockWeatherRepository mockWeatherRepository;
  late MockLocationService mockLocationService;
  late MockSharedPreferences mockSharedPreferences;
  late MockWidgetService mockWidgetService;
  late MockPosition mockPosition;

  setUpAll(() {
    registerFallbackValue(
      const WeatherLocation(
        latitude: 0,
        longitude: 0,
        name: '',
        country: '',
        source: LocationSource.search,
      ),
    );
    registerFallbackValue(Units.metric);
    registerFallbackValue(MockPosition());
    registerFallbackValue(FakeWeatherReport());
  });

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    mockLocationService = MockLocationService();
    mockSharedPreferences = MockSharedPreferences();
    mockWidgetService = MockWidgetService();
    mockPosition = MockPosition();

    when(() => mockPosition.latitude).thenReturn(51.5);
    when(() => mockPosition.longitude).thenReturn(-0.12);

    when(() => mockSharedPreferences.getStringList(any())).thenReturn(null);
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
    when(
      () => mockSharedPreferences.setStringList(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSharedPreferences.setString(any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockWidgetService.updateWidget(any())).thenAnswer((_) async {});
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockWeatherRepository),
        locationServiceProvider.overrideWithValue(mockLocationService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        widgetServiceProvider.overrideWithValue(mockWidgetService),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  /// Sets up mocks so that getCurrentPosition throws a LocationServiceException.
  void stubLocationError(LocationServiceError error) {
    when(
      () => mockLocationService.canAccessLocation(),
    ).thenAnswer((_) async => true);
    when(
      () => mockLocationService.getCurrentPosition(),
    ).thenThrow(LocationServiceException(error));
  }

  /// Sets up mocks so that getWeather throws the given exception.
  void stubWeatherError(Exception error) {
    when(
      () => mockLocationService.canAccessLocation(),
    ).thenAnswer((_) async => true);
    when(
      () => mockLocationService.getCurrentPosition(),
    ).thenAnswer((_) async => mockPosition);
    when(
      () => mockWeatherRepository.resolveLocation(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => _testLocation);
    when(
      () => mockWeatherRepository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(error);
  }

  /// Pumps enough frames for the full async chain to resolve.
  Future<void> pumpUntilSettled(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
  }

  // ── Data states ──────────────────────────────────────────────────────

  testWidgets('shows empty state when no location access', (tester) async {
    when(
      () => mockLocationService.canAccessLocation(),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(wrap(const NowScreen()));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.emptyNowTitle), findsOneWidget);
    expect(find.text(s.useMyLocation), findsOneWidget);
  });

  testWidgets('shows weather summary when report exists', (tester) async {
    final report = WeatherReport(
      location: _testLocation,
      current: CurrentWeather(
        observedAt: DateTime(2024, 1, 1, 10),
        temperature: 21,
        feelsLike: 20,
        condition: const WeatherCondition(
          type: WeatherConditionType.clear,
          description: 'clear sky',
        ),
        humidity: 50,
        windSpeed: 4,
      ),
      hourly: const [],
      daily: const [],
      updatedAt: DateTime(2024, 1, 1, 10),
      dataSource: WeatherDataSource.network,
    );

    when(
      () => mockLocationService.canAccessLocation(),
    ).thenAnswer((_) async => true);
    when(
      () => mockLocationService.getCurrentPosition(),
    ).thenAnswer((_) async => mockPosition);
    when(
      () => mockWeatherRepository.resolveLocation(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => _testLocation);
    when(
      () => mockWeatherRepository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => report);

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    expect(find.text('London, GB'), findsOneWidget);
    expect(find.textContaining('21'), findsOneWidget);
  });

  // ── Error states ─────────────────────────────────────────────────────

  testWidgets('shows missing API key error', (tester) async {
    stubWeatherError(const OpenWeatherApiKeyMissingException());

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.missingApiKeyTitle), findsOneWidget);
    expect(find.textContaining('OPENWEATHER_KEY'), findsOneWidget);
  });

  testWidgets('shows location services disabled error', (tester) async {
    stubLocationError(LocationServiceError.servicesDisabled);

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.locationServicesDisabledTitle), findsOneWidget);
    expect(find.text(s.retry), findsOneWidget);
  });

  testWidgets('shows permission denied error', (tester) async {
    stubLocationError(LocationServiceError.permissionDenied);

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.locationPermissionDeniedTitle), findsOneWidget);
    expect(find.text(s.retry), findsOneWidget);
  });

  testWidgets('shows permission denied forever error', (tester) async {
    stubLocationError(LocationServiceError.permissionDeniedForever);

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.locationPermissionDeniedTitle), findsOneWidget);
    // No retry button for permanent denial
    expect(find.text(s.retry), findsNothing);
  });

  testWidgets('shows location timeout error', (tester) async {
    stubLocationError(LocationServiceError.timeout);

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.locationTimeoutTitle), findsOneWidget);
    expect(find.text(s.retry), findsOneWidget);
  });

  testWidgets('shows generic error for unknown exceptions', (tester) async {
    stubWeatherError(Exception('network down'));

    await tester.pumpWidget(wrap(const NowScreen()));
    await pumpUntilSettled(tester);

    final ctx = tester.element(find.byType(NowScreen));
    final s = AppLocalizations.of(ctx)!;

    expect(find.text(s.errorGeneric), findsOneWidget);
    expect(find.text(s.retry), findsOneWidget);
  });
}
