import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/open_weather/open_weather_exceptions.dart';
import '../../domain/models/location.dart';
import '../../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../widgets/app_state_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    ref.read(searchQueryProvider.notifier).setQuery(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<WeatherLocation>> results = ref.watch(
      searchResultsProvider,
    );
    final List<WeatherLocation> favorites = ref.watch(
      favoritesControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.searchTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: strings.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _submit,
          ),
          const SizedBox(height: 16),
          results.when(
            data: (List<WeatherLocation> items) {
              if (_controller.text.trim().isNotEmpty && items.isEmpty) {
                return AppStateCard(
                  title: strings.noSearchResultsTitle,
                  message: strings.noSearchResultsBody,
                  icon: Icons.search_off_outlined,
                );
              }
              if (items.isEmpty) {
                return AppStateCard(
                  title: strings.searchTitle,
                  message: strings.emptyNowBody,
                  icon: Icons.search,
                );
              }
              return Column(
                children: items.map((WeatherLocation location) {
                  final bool isFavorite = favorites.any(
                    (WeatherLocation item) =>
                        item.cacheKey == location.cacheKey,
                  );
                  return Card(
                    child: ListTile(
                      title: Text(location.displayName),
                      subtitle: Text(location.cacheKey),
                      onTap: () async {
                        await ref
                            .read(weatherControllerProvider.notifier)
                            .loadForLocation(location);
                        if (!context.mounted) {
                          return;
                        }
                        context.pop();
                      },
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border_outlined,
                        ),
                        onPressed: () {
                          final favoritesController = ref.read(
                            favoritesControllerProvider.notifier,
                          );
                          if (isFavorite) {
                            favoritesController.remove(location);
                          } else {
                            favoritesController.add(location);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => AppStateCard(
              title: strings.loading,
              message: strings.loading,
              icon: Icons.hourglass_top,
            ),
            error: (Object error, StackTrace stackTrace) {
              if (error is OpenWeatherApiKeyMissingException) {
                return AppStateCard(
                  title: strings.missingApiKeyTitle,
                  message: strings.missingApiKeyBody,
                  icon: Icons.key_off_outlined,
                );
              }

              return AppStateCard(
                title: strings.errorGeneric,
                message: error.toString(),
                icon: Icons.error_outline,
              );
            },
          ),
        ],
      ),
    );
  }
}
