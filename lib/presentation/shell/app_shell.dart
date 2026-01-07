import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../domain/models/units.dart';
import '../../l10n/app_localizations.dart';
import '../state/providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final Units units = ref.watch(unitsProvider);
    final List<String> titles = <String>[
      strings.tabForecast,
      strings.tabFavorites,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[navigationShell.currentIndex]),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final Units next = units == Units.metric
                  ? Units.imperial
                  : Units.metric;
              ref.read(unitsProvider.notifier).setUnits(next);
              ref.read(weatherControllerProvider.notifier).refresh();
            },
            tooltip: units == Units.metric
                ? strings.unitsMetric
                : strings.unitsImperial,
            icon: Text(
              units == Units.metric ? '°C' : '°F',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            onPressed: () => context.pushNamed(AppRoutes.search),
            tooltip: strings.search,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.view_day_outlined),
            label: strings.tabForecast,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            label: strings.tabFavorites,
          ),
        ],
      ),
    );
  }
}
