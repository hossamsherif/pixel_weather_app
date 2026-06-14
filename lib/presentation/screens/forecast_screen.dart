import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/core/theme/temperature_text_style.dart';
import 'package:pixel_weather_app/domain/models/location.dart';

import '../../app_routes.dart';
import '../../data/open_weather/open_weather_exceptions.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/location_service.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';
import '../widgets/condition_asset.dart';
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
                    variant: AppStateCardVariant.location,
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
                        variant: AppStateCardVariant.empty,
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
                        height: 132,
                        child: ListView.separated(
                          padding: const EdgeInsetsDirectional.only(end: 4),
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
                variant: AppStateCardVariant.loading,
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
    if (error is OpenWeatherApiKeyMissingException) {
      return AppStateCard(
        title: strings.missingApiKeyTitle,
        message: strings.missingApiKeyBody,
        variant: AppStateCardVariant.apiKey,
        icon: Icons.key_off_outlined,
      );
    }

    if (error is LocationServiceException) {
      final LocationServiceException exception =
          error as LocationServiceException;
      switch (exception.error) {
        case LocationServiceError.permissionDenied:
        case LocationServiceError.permissionDeniedForever:
          return AppStateCard(
            title: strings.locationPermissionDeniedTitle,
            message: strings.locationPermissionDeniedBody,
            variant: AppStateCardVariant.location,
            icon: Icons.location_off_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
        case LocationServiceError.servicesDisabled:
          return AppStateCard(
            title: strings.locationServicesDisabledTitle,
            message: strings.locationServicesDisabledBody,
            variant: AppStateCardVariant.location,
            icon: Icons.location_disabled_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
        case LocationServiceError.timeout:
          return AppStateCard(
            title: strings.locationTimeoutTitle,
            message: strings.locationTimeoutBody,
            variant: AppStateCardVariant.location,
            icon: Icons.gps_off_outlined,
            actionLabel: strings.retry,
            onAction: onRetry,
          );
      }
    }

    return AppStateCard(
      title: strings.errorGeneric,
      message: error.toString(),
      variant: AppStateCardVariant.error,
      icon: Icons.error_outline,
      actionLabel: strings.retry,
      onAction: onRetry,
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.forecast, required this.units});

  static const Key spriteKey = Key('forecast-hourly-sprite');
  static const double width = 92;
  static const double height = 132;

  final HourlyForecast forecast;
  final Units units;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String time = DateFormat.Hm(locale).format(forecast.time);
    final ThemeData theme = Theme.of(context);
    final PixelWeatherTokens tokens = PixelWeatherTokens.of(context);
    final TextTheme textTheme = theme.textTheme;
    final String temperature = _temperatureLabel(forecast.temperature, units);
    final String? precipitation = _precipitationLabel(
      forecast.precipitationChance,
    );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.forecastCardFill,
          border: Border.all(color: tokens.forecastCardBorder, width: 1.5),
          borderRadius: BorderRadius.circular(6),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: tokens.spriteShadow,
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  softWrap: false,
                  style: textTheme.labelMedium,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.center,
                child: _PixelForecastSprite(
                  key: spriteKey,
                  condition: forecast.condition,
                  isDay: _isDayForForecastCondition(
                    forecast.condition,
                    at: forecast.time,
                  ),
                  size: 42,
                ),
              ),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  temperature,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  softWrap: false,
                  style: temperaturePixelTextStyle(
                    context,
                    textTheme.titleMedium?.copyWith(
                      color: tokens.temperatureAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 18,
                child: precipitation == null
                    ? const SizedBox.shrink()
                    : Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Text(
                          precipitation,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                          softWrap: false,
                          style: textTheme.labelSmall?.copyWith(
                            color: tokens.statAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  const _DailyForecastTile({required this.forecast, required this.units});

  static const Key spriteKey = Key('forecast-daily-sprite');

  final DailyForecast forecast;
  final Units units;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String dayLabel = DateFormat.E(locale).format(forecast.date);
    final ThemeData theme = Theme.of(context);
    final PixelWeatherTokens tokens = PixelWeatherTokens.of(context);
    final TextTheme textTheme = theme.textTheme;
    final String highLow =
        '${forecast.maxTemp.round()}° / '
        '${forecast.minTemp.round()}°${_temperatureUnit(units)}';
    final String? precipitation = _precipitationLabel(
      forecast.precipitationChance,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 82),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.forecastCardFill,
          border: Border.all(color: tokens.forecastCardBorder, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
          child: Row(
            textDirection: Directionality.of(context),
            children: <Widget>[
              _PixelForecastSprite(
                key: spriteKey,
                condition: forecast.condition,
                isDay: _isDayForForecastCondition(
                  forecast.condition,
                  at: forecast.date,
                  sunrise: forecast.sunrise,
                  sunset: forecast.sunset,
                ),
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      dayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      forecast.condition.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 86,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Text(
                        highLow,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        textAlign: TextAlign.end,
                        style: temperaturePixelTextStyle(
                          context,
                          textTheme.titleSmall?.copyWith(
                            color: tokens.temperatureAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                      child: precipitation == null
                          ? const SizedBox.shrink()
                          : Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Text(
                                precipitation,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                textAlign: TextAlign.end,
                                style: textTheme.labelSmall?.copyWith(
                                  color: tokens.statAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PixelForecastSprite extends StatelessWidget {
  const _PixelForecastSprite({
    super.key,
    required this.condition,
    required this.isDay,
    required this.size,
  });

  final WeatherCondition condition;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final PixelWeatherTokens tokens = PixelWeatherTokens.of(context);
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.spriteBackdrop,
          border: Border.all(color: tokens.spriteFrame, width: 1.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image(
            image: conditionImageFor(condition, isDay: isDay),
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
            isAntiAlias: false,
          ),
        ),
      ),
    );
  }
}

bool _isDayForForecastCondition(
  WeatherCondition condition, {
  required DateTime at,
  DateTime? sunrise,
  DateTime? sunset,
}) {
  if (condition.hasDayIcon) {
    return true;
  }
  if (condition.hasNightIcon) {
    return false;
  }

  if (sunrise != null && sunset != null) {
    return !at.isBefore(sunrise) && at.isBefore(sunset);
  }

  // Daily forecasts use their representative condition icon when available.
  // Without one, keep the fallback deterministic and daylight-biased because
  // the forecast date itself has no reliable hour from OpenWeather's daily row.
  if (at.hour == 0 && at.minute == 0) {
    return true;
  }

  return at.hour >= 6 && at.hour < 18;
}

String _temperatureLabel(double value, Units units) {
  return '${value.round()}°${_temperatureUnit(units)}';
}

String _temperatureUnit(Units units) {
  switch (units) {
    case Units.metric:
      return 'C';
    case Units.imperial:
      return 'F';
  }
}

String? _precipitationLabel(double? chance) {
  if (chance == null) {
    return null;
  }
  return '${(chance * 100).round()}%';
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
