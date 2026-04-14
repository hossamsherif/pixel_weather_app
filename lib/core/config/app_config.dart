class AppConfig {
  const AppConfig._();

  static const String openWeatherKey = String.fromEnvironment(
    'OPENWEATHER_KEY',
    defaultValue: '',
  );
}
