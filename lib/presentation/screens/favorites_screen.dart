import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/location.dart';
import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';
import '../widgets/condition_asset.dart';

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

    final Widget? offlineBadge =
        currentReport != null &&
            currentReport.dataSource == WeatherDataSource.cache
        ? Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: AppStateCard(
              title: strings.offlineBadge,
              message: strings.lastUpdated(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).toString(),
                ).add_Hm().format(currentReport.updatedAt),
              ),
              variant: AppStateCardVariant.offline,
              icon: Icons.cloud_off_outlined,
            ),
          )
        : null;

    final Widget body = favorites.isEmpty
        ? ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: <Widget>[
              if (offlineBadge != null) offlineBadge,
              AppStateCard(
                title: strings.emptyFavoritesTitle,
                message: strings.emptyFavoritesBody,
                variant: AppStateCardVariant.empty,
                icon: Icons.favorite_border,
              ),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsetsDirectional.all(16),
            itemCount: favorites.length + (offlineBadge == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (offlineBadge != null && index == 0) {
                return offlineBadge;
              }

              final int offset = offlineBadge == null ? 0 : 1;
              final int favoriteIndex = index - offset;
              final WeatherLocation favorite = favorites[favoriteIndex];
              final bool isLast = favoriteIndex == favorites.length - 1;

              return Padding(
                padding: EdgeInsetsDirectional.only(bottom: isLast ? 0 : 8),
                child: _FavoriteRow(
                  favorite: favorite,
                  currentReport: currentReport,
                ),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tabFavorites),
        actions: [
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
      body: body,
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
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    final AsyncValue<WeatherReport?> cachedWeather = ref.watch(
      favoriteWeatherProvider(favorite),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              await ref
                  .read(weatherControllerProvider.notifier)
                  .loadForLocation(favorite);
              if (!context.mounted) {
                return;
              }
              context.pushNamed(AppRoutes.forecast);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pixel.forecastCardFill,
                border: Border.all(color: pixel.favoriteRowAccent, width: 1.5),
                borderRadius: BorderRadius.circular(6),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: pixel.spriteShadow,
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 10),
                child: Row(
                  children: <Widget>[
                    _FavoriteMarker(pixel: pixel),
                    const SizedBox(width: 12),
                    Expanded(child: _FavoriteLocationText(favorite: favorite)),
                    const SizedBox(width: 12),
                    trailing,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteMarker extends StatelessWidget {
  const _FavoriteMarker({required this.pixel});

  final PixelWeatherTokens pixel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pixel.hudFill,
          border: Border.all(color: pixel.border, width: 1.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.star, color: pixel.favoriteRowAccent, size: 18),
      ),
    );
  }
}

class _FavoriteLocationText extends StatelessWidget {
  const _FavoriteLocationText({required this.favorite});

  final WeatherLocation favorite;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          favorite.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              favorite.cacheKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontFeatures: const <ui.FontFeature>[
                  ui.FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
        ),
      ],
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
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String temperature =
        '${current.temperature.round()}°${_temperatureUnit(units)}';

    return SizedBox(
      width: 104,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _FavoriteWeatherSprite(current: current, pixel: pixel),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                temperature,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                textAlign: TextAlign.end,
                style: textTheme.titleSmall?.copyWith(
                  color: pixel.temperatureAccent,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const <ui.FontFeature>[
                    ui.FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteWeatherSprite extends StatelessWidget {
  const _FavoriteWeatherSprite({required this.current, required this.pixel});

  final CurrentWeather current;
  final PixelWeatherTokens pixel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: const ValueKey<String>('favorite-weather-sprite'),
      dimension: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pixel.spriteBackdrop,
          border: Border.all(color: pixel.spriteFrame, width: 1.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image(
            image: conditionImageFor(
              current.condition,
              isDay: isDayForCurrentWeather(current),
            ),
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
            isAntiAlias: false,
            semanticLabel: current.condition.description,
          ),
        ),
      ),
    );
  }
}

class _LoadingWeatherTrailing extends StatelessWidget {
  const _LoadingWeatherTrailing();

  @override
  Widget build(BuildContext context) {
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);

    return SizedBox(
      width: 104,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: SizedBox.square(
          dimension: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: pixel.hudFill,
              border: Border.all(color: pixel.spriteFrame, width: 1.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: pixel.statAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWeatherTrailing extends StatelessWidget {
  const _EmptyWeatherTrailing();

  @override
  Widget build(BuildContext context) {
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    return SizedBox(
      width: 104,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: SizedBox(
          width: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: pixel.hudFill,
              border: Border.all(color: pixel.forecastCardBorder, width: 1.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              child: Text(
                '--',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: pixel.statAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    return Container(
      key: const ValueKey<String>('favorite-delete-background'),
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SizedBox.square(
        dimension: 38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.onError.withValues(alpha: 0.14),
            border: Border.all(color: pixel.forecastCardBorder, width: 1.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.delete_outline, color: colors.onError),
        ),
      ),
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
  return Material(type: MaterialType.transparency, child: heroChild);
}

String _temperatureUnit(Units units) {
  switch (units) {
    case Units.metric:
      return 'C';
    case Units.imperial:
      return 'F';
  }
}
