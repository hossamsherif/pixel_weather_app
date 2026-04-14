import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/open_weather/open_weather_exceptions.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/location_service.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';
import '../widgets/weather_summary_card.dart';

class NowScreen extends ConsumerWidget {
  const NowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<WeatherReport?> weatherState = ref.watch(
      weatherControllerProvider,
    );
    final Units units = ref.watch(unitsProvider);

    return RefreshIndicator(
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
            loading: () => AppStateCard(
              title: strings.loading,
              message: strings.loading,
              icon: Icons.hourglass_top,
            ),
            error: (Object error, StackTrace stackTrace) {
              return _ErrorCard(
                error: error,
                strings: strings,
                onRetry: () {
                  ref
                      .read(weatherControllerProvider.notifier)
                      .loadForCurrentLocation();
                },
              );
            },
          ),
        ],
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
