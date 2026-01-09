import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/location.dart';
import '../../domain/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';

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
          Card(
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
                context.go('/forecast');
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  ref
                      .read(favoritesControllerProvider.notifier)
                      .remove(favorite);
                },
              ),
            ),
          ),
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
