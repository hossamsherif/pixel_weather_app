import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';
import '../widgets/condition_icon.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<WeatherLocation> favorites = ref.watch(
      favoritesControllerProvider,
    );
    final AsyncValue<WeatherReport?> weatherState = ref.watch(
      weatherControllerProvider,
    );
    final WeatherReport? currentReport = weatherState.value;
    final List<Widget> children = <Widget>[];

    if (currentReport != null &&
        currentReport.dataSource == WeatherDataSource.cache) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppStateCard(
            title: strings.offlineBadge,
            message: strings.lastUpdated(
              currentReport.updatedAt.toLocal().toString(),
            ),
            icon: Icons.cloud_off_outlined,
          ),
        ),
      );
    }

    if (favorites.isEmpty) {
      children.add(
        AppStateCard(
          title: strings.emptyFavoritesTitle,
          message: strings.emptyFavoritesBody,
          icon: Icons.favorite_border,
        ),
      );
    } else {
      for (final WeatherLocation favorite in favorites) {
        children.add(
          _FavoriteRow(favorite: favorite, currentReport: currentReport),
        );
        children.add(const SizedBox(height: 8));
      }

      if (children.isNotEmpty) {
        children.removeLast();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabFavorites)),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}

class _FavoriteRow extends ConsumerWidget {
  const _FavoriteRow({required this.favorite, required this.currentReport});

  final WeatherLocation favorite;
  final WeatherReport? currentReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Units units = ref.watch(unitsProvider);
    final AsyncValue<WeatherReport?> cachedWeather = ref.watch(
      cachedWeatherProvider(favorite),
    );
    final WeatherReport? selectedReport =
        currentReport?.location.cacheKey == favorite.cacheKey
        ? currentReport
        : null;

    final Widget trailing = selectedReport != null
        ? _WeatherTrailing(report: selectedReport, units: units)
        : cachedWeather.when(
            data: (WeatherReport? report) => report == null
                ? const _EmptyWeatherTrailing()
                : _WeatherTrailing(report: report, units: units),
            loading: () => const _LoadingWeatherTrailing(),
            error: (Object error, StackTrace stackTrace) =>
                const _EmptyWeatherTrailing(),
          );

    final Widget deleteBackground = const _DeleteBackground();

    return Dismissible(
      key: ValueKey<String>(favorite.cacheKey),
      direction: DismissDirection.endToStart,
      background: deleteBackground,
      secondaryBackground: deleteBackground,
      onDismissed: (direction) {
        ref.read(favoritesControllerProvider.notifier).remove(favorite);
      },
      child: Hero(
        tag: _favoriteHeroTag(favorite),
        flightShuttleBuilder: _favoriteHeroFlightShuttle,
        child: Card(
          child: ListTile(
            title: Text(favorite.displayName),
            subtitle: Text(favorite.cacheKey),
            onTap: () async {
              await ref
                  .read(weatherControllerProvider.notifier)
                  .loadForLocation(favorite);
              if (!context.mounted) {
                return;
              }
              context.pushNamed(AppRoutes.forecast);
            },
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

class _WeatherTrailing extends StatelessWidget {
  const _WeatherTrailing({required this.report, required this.units});

  final WeatherReport report;
  final Units units;

  @override
  Widget build(BuildContext context) {
    final CurrentWeather current = report.current;
    final Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          iconForCondition(current.condition.type),
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Text(
          '${current.temperature.round()}°${_temperatureUnit(units)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _LoadingWeatherTrailing extends StatelessWidget {
  const _LoadingWeatherTrailing();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _EmptyWeatherTrailing extends StatelessWidget {
  const _EmptyWeatherTrailing();

  @override
  Widget build(BuildContext context) {
    return Text('--', style: Theme.of(context).textTheme.bodySmall);
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: colors.error,
      child: Icon(Icons.delete_outline, color: colors.onError),
    );
  }
}

String _favoriteHeroTag(WeatherLocation location) {
  return 'favorite-${location.cacheKey}';
}

Widget _favoriteHeroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero fromHero = fromHeroContext.widget as Hero;
  final Widget heroChild = fromHero.child;
  return Material(
    type: MaterialType.transparency,
    child: ClipRect(child: heroChild),
  );
}

String _temperatureUnit(Units units) {
  switch (units) {
    case Units.metric:
      return 'C';
    case Units.imperial:
      return 'F';
  }
}
