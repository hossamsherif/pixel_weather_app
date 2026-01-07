import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/location.dart';
import '../../domain/models/weather.dart';
import 'favorites_controller.dart';
import 'weather_controller.dart';

final AsyncNotifierProvider<WeatherController, WeatherReport?>
weatherControllerProvider =
    AsyncNotifierProvider<WeatherController, WeatherReport?>(
      WeatherController.new,
    );

final NotifierProvider<FavoritesController, List<WeatherLocation>>
favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<WeatherLocation>>(
      FavoritesController.new,
    );
