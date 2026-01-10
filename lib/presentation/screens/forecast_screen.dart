import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pixel_weather_app/domain/models/location.dart';

import '../../app_routes.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/location_service.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';
import '../widgets/condition_icon.dart';
import '../widgets/weather_summary_card.dart';

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<WeatherReport?> weatherState = ref.watch(
      weatherControllerProvider,
    );
    final Units units = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goNamed(AppRoutes.favorites);
          },
          tooltip: strings.tabFavorites,
          icon: const Icon(Icons.menu),
        ),
        title: Text(strings.tabForecast),
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
              units.displayValue,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
              ref.read(weatherControllerProvider.notifier).refresh();
            },
            tooltip: 'Toggle Language',
            icon: Text(
              Localizations.localeOf(context).languageCode.toUpperCase(),
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(weatherControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            weatherState.when(
              data: (WeatherReport? report) {
                if (report == null) {
                  return AppStateCard(
                    title: strings.emptyNowTitle,
                    message: strings.emptyNowBody,
                    icon: Icons.location_searching,
                    actionLabel: strings.useMyLocation,
                    onAction: () {
                      ref
                          .read(weatherControllerProvider.notifier)
                          .loadForCurrentLocation();
                    },
                  );
                }

                final bool isFavorite = ref
                    .watch(favoritesControllerProvider)
                    .any((item) => item.cacheKey == report.location.cacheKey);

                final Widget summaryCard = WeatherSummaryCard(
                  report: report,
                  units: units,
                  strings: strings,
                  isFavorite: isFavorite,
                  onToggleFavorite: () {
                    final favoritesController = ref.read(
                      favoritesControllerProvider.notifier,
                    );
                    if (isFavorite) {
                      favoritesController.remove(report.location);
                    } else {
                      favoritesController.add(report.location);
                    }
                  },
                );
                final Widget summaryCardWithHero = isFavorite
                    ? Hero(
                        tag: _favoriteHeroTag(report.location),
                        flightShuttleBuilder: _favoriteHeroFlightShuttle,
                        child: summaryCard,
                      )
                    : summaryCard;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    summaryCardWithHero,
                    const SizedBox(height: 16),
                    if (report.hourly.isEmpty && report.daily.isEmpty)
                      AppStateCard(
                        title: strings.forecastUnavailableTitle,
                        message: strings.forecastUnavailableBody,
                        icon: Icons.cloud_off_outlined,
                        actionLabel: strings.retry,
                        onAction: () {
                          ref
                              .read(weatherControllerProvider.notifier)
                              .refresh();
                        },
                      )
                    else ...<Widget>[
                      Text(
                        strings.hourlyForecast,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: report.hourly.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final HourlyForecast hour = report.hourly[index];
                            return _HourlyForecastCard(
                              forecast: hour,
                              units: units,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        strings.dailyForecast,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: report.daily.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final DailyForecast day = report.daily[index];
                          return _DailyForecastTile(
                            forecast: day,
                            units: units,
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
              loading: () => AppStateCard(
                title: strings.loading,
                message: strings.loading,
                icon: Icons.hourglass_top,
              ),
              error: (Object error, StackTrace stackTrace) => _ErrorCard(
                error: error,
                strings: strings,
                onRetry: () {
                  if (error is LocationServiceException) {
                    ref
                        .read(weatherControllerProvider.notifier)
                        .loadForCurrentLocation();
                  } else {
                    ref.read(weatherControllerProvider.notifier).refresh();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.error,
    required this.strings,
    required this.onRetry,
  });

  final Object error;
  final AppLocalizations strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error is LocationServiceException) {
      final LocationServiceException exception =
          error as LocationServiceException;
      switch (exception.error) {
        case LocationServiceError.permissionDenied:
        case LocationServiceError.permissionDeniedForever:
          return AppStateCard(
            title: strings.locationPermissionDeniedTitle,
            message: strings.locationPermissionDeniedBody,
            icon: Icons.location_off_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
        case LocationServiceError.servicesDisabled:
          return AppStateCard(
            title: strings.locationServicesDisabledTitle,
            message: strings.locationServicesDisabledBody,
            icon: Icons.location_disabled_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
        case LocationServiceError.timeout:
          return AppStateCard(
            title: strings.locationTimeoutTitle,
            message: strings.locationTimeoutBody,
            icon: Icons.gps_off_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
      }
    }

    return AppStateCard(
      title: strings.errorGeneric,
      message: error.toString(),
      icon: Icons.error_outline,
      actionLabel: strings.retry,
      onAction: onRetry,
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.forecast, required this.units});

  final HourlyForecast forecast;
  final Units units;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String time = DateFormat.Hm(locale).format(forecast.time);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(time),
            const SizedBox(height: 6),
            Icon(iconForCondition(forecast.condition.type), size: 20),
            const SizedBox(height: 6),
            Text('${forecast.temperature.round()}°${_temperatureUnit(units)}'),
          ],
        ),
      ),
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
}

class _DailyForecastTile extends StatelessWidget {
  const _DailyForecastTile({required this.forecast, required this.units});

  final DailyForecast forecast;
  final Units units;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String dayLabel = DateFormat.E(locale).format(forecast.date);
    return Card(
      child: ListTile(
        leading: Icon(iconForCondition(forecast.condition.type)),
        title: Text(dayLabel),
        subtitle: Text(forecast.condition.description),
        trailing: Text(
          '${forecast.maxTemp.round()}° / '
          '${forecast.minTemp.round()}°${_temperatureUnit(units)}',
        ),
      ),
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
