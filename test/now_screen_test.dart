import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/screens/now_screen.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/location_service.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';

class _UnitsController extends UnitsController {
  @override
  Units build() => Units.metric;
}

class _FavoritesController extends FavoritesController {
  _FavoritesController(this.initial);
  final List<WeatherLocation> initial;

  @override
  List<WeatherLocation> build() => initial;
}

class _WeatherController extends WeatherController {
  _WeatherController(this.stateValue);
  final AsyncValue<WeatherReport?> stateValue;

  @override
  Future<WeatherReport?> build() async => stateValue.value;

  @override
  AsyncValue<WeatherReport?> get state => stateValue;
}

void main() {
  testWidgets('NowScreen shows error state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const NowScreen(),
        overrides: [
          weatherControllerProvider.overrideWith(
            () => _WeatherController(
              AsyncValue.error(
                LocationServiceException(LocationServiceError.servicesDisabled),
                StackTrace.current,
              ),
            ),
          ),
          favoritesControllerProvider.overrideWith(
            () => _FavoritesController(const []),
          ),
          unitsProvider.overrideWith(_UnitsController.new),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppStateCard), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}

Widget _wrap(Widget child, {required List overrides}) {
  return ProviderScope(
    overrides: List.castFrom(overrides),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
