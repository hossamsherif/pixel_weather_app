import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_weather_app/data/favorites/favorites_store.dart';
import 'package:pixel_weather_app/domain/models/location.dart';
import 'package:pixel_weather_app/presentation/state/providers.dart';

class MockFavoritesStore extends Mock implements FavoritesStore {}

void main() {
  late MockFavoritesStore store;

  WeatherLocation makeLocation({
    double latitude = 1,
    double longitude = 2,
    String name = 'Test',
    String country = 'TS',
    String? state,
    LocationSource source = LocationSource.search,
  }) {
    return WeatherLocation(
      latitude: latitude,
      longitude: longitude,
      name: name,
      country: country,
      state: state,
      source: source,
    );
  }

  setUp(() {
    store = MockFavoritesStore();
    when(() => store.write(any())).thenAnswer((_) async {});
  });

  ProviderContainer createContainer(List<WeatherLocation> initial) {
    when(() => store.read()).thenReturn(initial);
    final container = ProviderContainer(
      overrides: [
        favoritesStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('add inserts favorite with favorite source and persists', () async {
    final container = createContainer([]);
    final controller = container.read(favoritesControllerProvider.notifier);

    final location = makeLocation(source: LocationSource.search);

    await controller.add(location);

    expect(container.read(favoritesControllerProvider).length, 1);
    expect(
      container.read(favoritesControllerProvider).first.source,
      LocationSource.favorite,
    );

    verify(() => store.write(any())).called(1);
  });

  test('add does not duplicate existing favorite', () async {
    final location = makeLocation(source: LocationSource.favorite);
    final container = createContainer([location]);
    final controller = container.read(favoritesControllerProvider.notifier);

    await controller.add(location);

    expect(container.read(favoritesControllerProvider).length, 1);
    verifyNever(() => store.write(any()));
  });

  test('remove deletes favorite and persists', () async {
    final location = makeLocation(source: LocationSource.favorite);
    final container = createContainer([location]);
    final controller = container.read(favoritesControllerProvider.notifier);

    await controller.remove(location);

    expect(container.read(favoritesControllerProvider), isEmpty);
    verify(() => store.write(any())).called(1);
  });

  test('isFavorite matches by cacheKey', () {
    final location = makeLocation(source: LocationSource.favorite);
    final container = createContainer([location]);
    final controller = container.read(favoritesControllerProvider.notifier);

    expect(controller.isFavorite(location), isTrue);
    expect(
      controller.isFavorite(makeLocation(latitude: 9, longitude: 9)),
      isFalse,
    );
  });
}
