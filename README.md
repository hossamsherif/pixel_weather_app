# pixel_weather_app

[![Flutter PR Checks](https://github.com/hossamsherif/pixel_weather_app/actions/workflows/flutter-pr-checks.yml/badge.svg)](https://github.com/hossamsherif/pixel_weather_app/actions/workflows/flutter-pr-checks.yml)

POC weather app with Codex

## CI / Pull Request Checks

This repository uses **GitHub Actions** to validate pull requests automatically.

The PR workflow runs the following checks:

- `flutter pub get`
- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test --coverage`

### Coverage requirement

Pull requests must maintain a minimum of **80% Flutter line coverage**.
The workflow parses `coverage/lcov.info` and fails if total coverage drops below this threshold.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
