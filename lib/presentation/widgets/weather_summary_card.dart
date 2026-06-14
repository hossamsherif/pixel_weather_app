import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'condition_asset.dart';

class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({
    required this.report,
    required this.units,
    required this.strings,
    this.isFavorite,
    this.onToggleFavorite,
    super.key,
  });

  final WeatherReport report;
  final Units units;
  final AppLocalizations strings;
  final bool? isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    final CurrentWeather current = report.current;
    final String updated = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(report.updatedAt);
    final bool isDay = isDayForCurrentWeather(current);
    final String temperature =
        '${current.temperature.round()}°${_temperatureUnit(units)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      report.location.displayName,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  if (report.dataSource == WeatherDataSource.cache)
                    Chip(
                      label: Text(strings.offlineBadge),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onToggleFavorite != null && isFavorite != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onToggleFavorite,
                      tooltip: isFavorite!
                          ? strings.removeFavorite
                          : strings.addFavorite,
                      icon: Icon(
                        isFavorite! ? Icons.star : Icons.star_border_outlined,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: pixel.hudFill,
                  border: Border.all(color: pixel.border, width: 2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: pixel.spriteShadow,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _SpritePane(
                        condition: current.condition,
                        isDay: isDay,
                        pixel: pixel,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                temperature,
                                maxLines: 1,
                                style: textTheme.displayMedium?.copyWith(
                                  color: pixel.temperatureAccent,
                                  fontWeight: FontWeight.w800,
                                  height: 0.92,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              current.condition.description,
                              style: textTheme.titleMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool compact = constraints.maxWidth < 420;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _StatItem(
                        label: strings.feelsLike,
                        value:
                            '${current.feelsLike.round()}°${_temperatureUnit(units)}',
                        pixel: pixel,
                        compact: compact,
                      ),
                      _StatItem(
                        label: strings.humidity,
                        value: '${current.humidity}%',
                        pixel: pixel,
                        compact: compact,
                      ),
                      _StatItem(
                        label: strings.wind,
                        value:
                            '${current.windSpeed.round()} ${_windUnit(units)}',
                        pixel: pixel,
                        compact: compact,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  strings.lastUpdated(updated),
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
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

  String _windUnit(Units units) {
    switch (units) {
      case Units.metric:
        return 'm/s';
      case Units.imperial:
        return 'mph';
    }
  }
}

class _SpritePane extends StatelessWidget {
  const _SpritePane({
    required this.condition,
    required this.isDay,
    required this.pixel,
  });

  final WeatherCondition condition;
  final bool isDay;
  final PixelWeatherTokens pixel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pixel.spriteBackdrop,
          border: Border.all(color: pixel.spriteFrame, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image(
            image: conditionImageFor(condition, isDay: isDay),
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
            semanticLabel: condition.description,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.pixel,
    required this.compact,
  });

  final String label;
  final String value;
  final PixelWeatherTokens pixel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: compact ? 128 : 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pixel.hudFill,
          border: Border.all(color: pixel.border, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textDirection: ui.TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: pixel.statAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
