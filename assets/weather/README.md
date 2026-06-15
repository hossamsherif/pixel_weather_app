# Pixel Weather Asset Provenance

This directory contains the weather sprite pipeline used by the app-wide typed sprite API in `lib/presentation/widgets/condition_asset.dart`.

## Source and generation

- Source type: original project-generated raster artwork.
- Generator prompt: documented in `assets/weather/LICENSES.md`.
- Third-party input assets: none bundled, traced, copied, or redistributed.
- Reference directory: `assets/weather/pixel/reference/` contains documentation only.
- Generated directory: `assets/weather/pixel/generated/` stores first-pass project-generated PNGs.
- Edited directory: `assets/weather/pixel/edited/` stores normalized palette and bounding-box PNGs.
- Exported directory: `assets/weather/pixel/exported/` stores the final app-consumed sprites.

## Registration

`pubspec.yaml` registers the exported directories:

- `assets/weather/pixel/exported/day/`
- `assets/weather/pixel/exported/night/`

The exported set covers every `WeatherConditionType` bucket with day and night variants: clear, clouds, rain/drizzle, snow/sleet, thunder, fog/atmosphere, and unknown.

## Redistribution

The exported sprites are project-owned generated artwork with no third-party attribution requirement. They are safe to redistribute with the app under the app's project license. Future third-party or reference-derived assets must be documented in `LICENSES.md` before app registration.
