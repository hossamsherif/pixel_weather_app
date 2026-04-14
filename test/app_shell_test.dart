import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_weather_app/app_routes.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/shell/app_shell.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';

class _UnitsController extends UnitsController {
  _UnitsController(this.initial);
  final Units initial;

  @override
  Units build() => initial;

  void setUnits(Units units) => state = units;
}

class _LocaleController extends LocaleController {
  @override
  Locale? build() => const Locale('en');

  @override
  void toggleLocale() => state = const Locale('ar');
}

class _WeatherController extends WeatherController {
  var refreshCalled = false;

  @override
  Future<WeatherReport?> build() async => null;

  @override
  Future<void> refresh() async {
    refreshCalled = true;
  }
}

void main() {
  testWidgets('AppShell switches units and locale and navigates',
      (tester) async {
    late _WeatherController weatherController;

    final router = GoRouter(
      initialLocation: '/forecast',
      routes: <RouteBase>[
        GoRoute(
          path: '/search',
          name: AppRoutes.search,
          builder: (context, state) => const Text('Search'),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(
            navigationShell: navigationShell,
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/forecast',
                  name: 'forecast',
                  builder: (context, state) => const Text('Forecast'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/favorites',
                  name: 'favorites',
                  builder: (context, state) => const Text('Favorites'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unitsProvider.overrideWith(() => _UnitsController(Units.metric)),
          localeProvider.overrideWith(_LocaleController.new),
          weatherControllerProvider.overrideWith(() {
            weatherController = _WeatherController();
            return weatherController;
          }),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Forecast'), findsWidgets);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsOneWidget);

    router.go('/forecast');
    await tester.pumpAndSettle();

    await tester.tap(find.text('°C'));
    await tester.pump();
    expect(weatherController.refreshCalled, isTrue);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsWidgets);
  });
}
