import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/units.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import 'condition_icon.dart';

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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CurrentWeather current = report.current;
    final String updated = DateFormat.yMMMd().add_Hm().format(report.updatedAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(iconForCondition(current.condition.type), size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '${current.temperature.round()}°${_temperatureUnit(units)}',
                    style: textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(current.condition.description, style: textTheme.bodyLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: <Widget>[
                  _StatItem(
                    label: strings.feelsLike,
                    value:
                        '${current.feelsLike.round()}°${_temperatureUnit(units)}',
                  ),
                  _StatItem(
                    label: strings.humidity,
                    value: '${current.humidity}%',
                  ),
                  _StatItem(
                    label: strings.wind,
                    value: '${current.windSpeed.round()} ${_windUnit(units)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(strings.lastUpdated(updated), style: textTheme.bodySmall),
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: textTheme.bodySmall),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }
}
