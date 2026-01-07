class OpenWeatherException implements Exception {
  const OpenWeatherException(this.message);

  final String message;

  @override
  String toString() => 'OpenWeatherException: $message';
}

class OpenWeatherApiKeyMissingException extends OpenWeatherException {
  const OpenWeatherApiKeyMissingException()
    : super('OPENWEATHER_KEY is missing.');
}

class OpenWeatherRequestException extends OpenWeatherException {
  const OpenWeatherRequestException({
    required this.statusCode,
    required String message,
  }) : super(message);

  final int statusCode;
}
