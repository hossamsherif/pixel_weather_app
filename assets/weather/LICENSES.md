# Pixel Weather Asset Licenses

## Exported sprite family

- Location: `assets/weather/pixel/exported/`
- Status: custom project-generated raster sprites for this prototype.
- License: project-owned generated artwork; no third-party sprite files are redistributed.
- Attribution required: none for bundled files.
- Redistribution: safe to ship with the app under the app's project license.
- Canvas: 64x64 transparent PNG, nearest-neighbor pixel geometry.
- Variants: day and night for clear, clouds, rain/drizzle, snow/sleet, thunder, fog/atmosphere, and unknown fallback.

Bundled exported files:

- `assets/weather/pixel/exported/day/clear.png`
- `assets/weather/pixel/exported/day/clouds.png`
- `assets/weather/pixel/exported/day/fog.png`
- `assets/weather/pixel/exported/day/rain.png`
- `assets/weather/pixel/exported/day/snow.png`
- `assets/weather/pixel/exported/day/thunder.png`
- `assets/weather/pixel/exported/day/unknown.png`
- `assets/weather/pixel/exported/night/clear.png`
- `assets/weather/pixel/exported/night/clouds.png`
- `assets/weather/pixel/exported/night/fog.png`
- `assets/weather/pixel/exported/night/rain.png`
- `assets/weather/pixel/exported/night/snow.png`
- `assets/weather/pixel/exported/night/thunder.png`
- `assets/weather/pixel/exported/night/unknown.png`

## Handjet temperature font

- Location: `assets/fonts/handjet/Handjet-Regular.ttf`
- Source: Google Fonts, `google/fonts/ofl/handjet/Handjet[ELGR,ELSH,wght].ttf`
- App family name: `TemperaturePixel`
- Usage: temperature value tokens only.
- License: SIL Open Font License 1.1, bundled at `assets/fonts/handjet/OFL.txt`.
- Attribution required: retain copyright and license text with redistribution.
- Redistribution: safe to bundle with the app under OFL 1.1; do not sell the font by itself.
- Glyph coverage gate: accepted after task research confirmed Western digits, Arabic-Indic digits, degree sign, C, and F render without `.notdef`.

## Reference material

No reference assets are bundled in this repository. The sprite family was generated as original pixel shapes using the Concept A prompt:

> Create a cohesive tasteful pixel-art weather sprite family for a modern weather app HUD. Use a consistent 64x64 transparent canvas, chunky pixel geometry, one shared palette, matching stroke weight, and readable day/night variants for clear, clouds, rain, snow, thunder, fog, and unknown. Avoid CRT/GameBoy treatment, trademarks, text, and third-party character styles.

## Pipeline folders

- `assets/weather/pixel/reference/`: reserved for non-bundled references.
- `assets/weather/pixel/generated/`: first-pass generated sprites.
- `assets/weather/pixel/edited/`: normalized palette and bounding-box versions.
- `assets/weather/pixel/exported/`: app-consumed final PNGs registered in `pubspec.yaml`.
- `assets/weather/pixel/contact_sheet.png`: visual review sheet for the full family.

## Licensing gate

No CC BY-SA, GPL, trademarked, scraped, or third-party sprite dependency is included. Future additions must document source URL or generator, license, attribution text, edit status, and redistribution constraints before being registered in `pubspec.yaml`.
