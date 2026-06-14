# Pixel Weather Assets

## Exported sprite family

- Location: `assets/weather/pixel/exported/`
- Status: custom project-generated raster sprites for this prototype.
- License: owned by this project; no third-party sprite files are redistributed.
- Canvas: 64x64 transparent PNG, nearest-neighbor pixel geometry.
- Variants: day and night for clear, clouds, rain/drizzle, snow/sleet, thunder, fog/atmosphere, and unknown fallback.

## Reference material

No reference assets are bundled in this repository. The sprite family was generated as original pixel shapes using the Concept A prompt:

> Create a cohesive tasteful pixel-art weather sprite family for a modern weather app HUD. Use a consistent 64x64 transparent canvas, chunky pixel geometry, one shared palette, matching stroke weight, and readable day/night variants for clear, clouds, rain, snow, thunder, fog, and unknown. Avoid CRT/GameBoy treatment, trademarks, text, and third-party character styles.

## Pipeline folders

- `assets/weather/pixel/reference/`: reserved for non-bundled references.
- `assets/weather/pixel/generated/`: first-pass generated sprites.
- `assets/weather/pixel/edited/`: normalized palette and bounding-box versions.
- `assets/weather/pixel/exported/`: app-consumed final PNGs registered in `pubspec.yaml`.
- `assets/weather/pixel/contact_sheet.png`: visual review sheet for the full family.
