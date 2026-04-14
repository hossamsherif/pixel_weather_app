import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_weather_app/core/config/app_config.dart' show AppConfig;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'presentation/state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  debugPrint('OpenWeather Key: ${AppConfig.openWeatherKey}');
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const PixelWeatherApp(),
    ),
  );
}
