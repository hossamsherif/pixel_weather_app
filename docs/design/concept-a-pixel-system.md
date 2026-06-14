# Concept A Pixel Weather System

Concept A is the app-wide weather visual language for the stacked redesign. It uses restrained Material structure with pixel-art weather sprites, hard-edged frames, zero-blur shadows, and isolated pixel numerals for temperatures.

## Sprite Usage

- Runtime sprites are loaded only through `conditionAssetFor` and `conditionImageFor` in `lib/presentation/widgets/condition_asset.dart`.
- App widgets consume the exported PNGs from `assets/weather/pixel/exported/day/` and `assets/weather/pixel/exported/night/`.
- `WeatherSummaryCard`, forecast cards, Now, and Favorites use `FilterQuality.none` so sprites stay crisp.
- `assets/weather/pixel/contact_sheet.png` is the visual review sheet for the complete exported family.

## Asset Provenance

- Exported weather sprites are project-owned generated raster artwork.
- No third-party sprite files, traced references, trademarks, or scraped assets are bundled.
- Source, generation, license, and redistribution notes live in `assets/weather/README.md` and `assets/weather/LICENSES.md`.
- New third-party or reference-derived material must be documented in `assets/weather/LICENSES.md` before it is registered in `pubspec.yaml`.

## Theme Tokens

Pixel surfaces read color from `PixelWeatherTokens` in `lib/core/theme/app_theme.dart`.

- `hudFill` and `border`: summary HUD shell.
- `forecastCardFill` and `forecastCardBorder`: hourly and daily forecast cards.
- `stateCardFill` and `stateCardAccent`: empty, loading, error, offline, location, and API-key states.
- `spriteBackdrop`, `spriteFrame`, and `spriteShadow`: sprite panes and hard pixel shadows.
- `temperatureAccent`: temperature numerals and selected hourly emphasis.
- `statAccent`: precipitation, humidity, wind, and secondary weather stats.

Keep token additions theme-owned. Avoid one-off color literals in widgets unless the value is a fixed brand asset or documented generated-art color.

## Day And Night Policy

- Prefer OpenWeather icon-code suffixes when present: `d` maps to day sprites and `n` maps to night sprites.
- Current weather falls back to sunrise/sunset when icon-code suffixes are unavailable.
- Daily forecasts use their representative icon when available. If a daily row has no reliable hour or icon suffix, the fallback is deterministic and daylight-biased.
- Unknown or unsupported condition buckets must map to `unknown.png`; never leave a condition without a bundled visual.

## RTL And Numerals

- App layout follows Flutter `Directionality`, including Arabic screens and mirrored row order.
- Temperature and precipitation labels remain in LTR `Directionality` islands so mixed numerals, degree signs, percent signs, and unit suffixes stay stable in Arabic.
- Pixel temperature numerals are scoped through `temperaturePixelTextStyle`; do not apply the pixel font to full prose.
- Long Arabic labels must wrap inside card bounds and action labels may use two lines.

## Visual Coverage

The golden harnesses cover the final visual matrix:

- `test/pixel_hud_visual_test.dart`: main summary HUD in light/dark and English/Arabic.
- `test/pixel_forecast_cards_visual_test.dart`: forecast screen with summary, hourly cards, daily cards, selected hour, sprites, and light/dark English/Arabic.
- `test/pixel_state_cards_visual_test.dart`: empty, loading, offline, generic error, missing API key, location-services, location-timeout, and forecast-unavailable cards in light/dark English/Arabic.
- `test/pixel_now_favorites_visual_test.dart`: Now and Favorites surfaces in light/dark English/Arabic.

Manual screenshot refresh should run with `flutter test --update-goldens` for the affected harnesses after visual changes.

## Adding A Weather Visual

1. Add or regenerate the day and night PNGs as 64x64 transparent pixel art.
2. Store source-stage files under `generated/` or `edited/`, then export the app-consumed file under `exported/day/` and `exported/night/`.
3. Update `assets/weather/LICENSES.md` with source, license, attribution, edit status, and redistribution constraints.
4. Register only exported directories in `pubspec.yaml`; avoid registering reference or intermediate folders.
5. Extend `WeatherConditionType` mapping or fallback logic in `condition_asset.dart`.
6. Add or update tests that prove day/night mapping, RTL mixed labels, and visual goldens still render sprites.
