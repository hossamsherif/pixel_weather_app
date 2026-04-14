import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pixel_weather_app/data/open_weather/open_weather_exceptions.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/domain/models/units.dart';
import 'package:pixel_weather_app/domain/models/weather.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/state/favorites_controller.dart';
import 'package:pixel_weather_app/presentation/state/location_service.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';
import 'package:pixel_weather_app/presentation/state/weather_controller.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';
import 'package:pixel_weather_app/presentation/widgets/weather_summary_card.dart';

class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WeatherReport?> weatherState = ref.watch(
      weatherControllerProvider,
    );
    final Units units = ref.watch(unitsProvider);
    final strings = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(weatherControllerProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          weatherState.map(
            data: (AsyncData<WeatherReport?> data) {
              final WeatherReport? report = data.value;
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

              return WeatherSummaryCard(
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
            },
            error: (AsyncError<WeatherReport?> error) =>
                _ErrorCard(error: error.error, strings: strings),
            loading: (AsyncLoading<WeatherReport?> loading) {
              if (loading.hasError) {
                return _ErrorCard(error: loading.error!, strings: strings);
              }
              return AppStateCard(title: strings.loading, message: '');
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard({required this.error, required this.strings});

  final Object error;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error is OpenWeatherApiKeyMissingException) {
      return AppStateCard(
        title: strings.missingApiKeyTitle,
        message: strings.missingApiKeyBody,
        icon: Icons.key_off,
      );
    }

    if (error is LocationServiceException) {
      final LocationServiceException locationError =
          error as LocationServiceException;
      switch (locationError.error) {
        case LocationServiceError.servicesDisabled:
          return AppStateCard(
            title: strings.locationServicesDisabledTitle,
            message: strings.locationServicesDisabledBody,
            icon: Icons.location_off,
            actionLabel: strings.retry,
            onAction: () {
              ref
                  .read(weatherControllerProvider.notifier)
                  .loadForCurrentLocation();
            },
          );
        case LocationServiceError.permissionDenied:
          return AppStateCard(
            title: strings.locationPermissionDeniedTitle,
            message: strings.locationPermissionDeniedBody,
            icon: Icons.location_disabled,
            actionLabel: strings.retry,
            onAction: () {
              ref
                  .read(weatherControllerProvider.notifier)
                  .loadForCurrentLocation();
            },
          );
        case LocationServiceError.permissionDeniedForever:
          return AppStateCard(
            title: strings.locationPermissionDeniedTitle,
            message: strings.locationPermissionDeniedBody,
            icon: Icons.location_disabled,
          );
        case LocationServiceError.timeout:
          return AppStateCard(
            title: strings.locationTimeoutTitle,
            message: strings.locationTimeoutBody,
            icon: Icons.timer_off,
            actionLabel: strings.retry,
            onAction: () {
              ref
                  .read(weatherControllerProvider.notifier)
                  .loadForCurrentLocation();
            },
          );
      }
    }

    return AppStateCard(
      title: strings.errorGeneric,
      message: error.toString(),
      icon: Icons.error_outline,
      actionLabel: strings.retry,
      onAction: () {
        ref.read(weatherControllerProvider.notifier).loadForCurrentLocation();
      },
    );
  }
}
