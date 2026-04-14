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
import 'package:pixel_weather_app/presentation/state/controller_providers.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';
import 'package:pixel_weather_app/core/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockWidgetService extends Mock implements WidgetService {}

class MockPosition extends Mock implements Position {}

class FakeWeatherReport extends Fake implements WeatherReport {}

void main() {
  late MockWeatherRepository mockWeatherRepository;
  late MockLocationService mockLocationService;
  late MockSharedPreferences mockSharedPreferences;
  late MockWidgetService mockWidgetService;

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

  testWidgets('NowScreen shows no weather state', (tester) async {
    when(
      () => mockLocationService.canAccessLocation(),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(wrap(const NowScreen()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NowScreen));
    final strings = AppLocalizations.of(context)!;

    expect(find.text(strings.emptyNowTitle), findsOneWidget);
  });

  testWidgets('NowScreen shows missing API key message', (tester) async {
    final mockPosition = MockPosition();
    when(() => mockPosition.latitude).thenReturn(51.5);
    when(() => mockPosition.longitude).thenReturn(-0.12);

    final location = const WeatherLocation(
      latitude: 51.5,
      longitude: -0.12,
      name: 'London',
      country: 'GB',
      source: LocationSource.gps,
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
    ).thenAnswer((_) async => location);

    when(
      () => mockWeatherRepository.getWeather(
        location: any(named: 'location'),
        units: any(named: 'units'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(const OpenWeatherApiKeyMissingException());

    await tester.pumpWidget(wrap(const NowScreen()));

    await tester.pump(); // build() starts
    await tester.pump(); // canAccessLocation completes
    await tester.pump(); // getCurrentPosition completes
    await tester.pump(); // resolveLocation completes
    await tester.pump(); // getWeather completion/exception
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NowScreen));
    final strings = AppLocalizations.of(context)!;

    expect(find.text(strings.missingApiKeyTitle), findsOneWidget);
    expect(find.textContaining('OPENWEATHER_KEY'), findsOneWidget);
  });
}
