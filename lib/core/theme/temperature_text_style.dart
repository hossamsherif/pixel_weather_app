import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const String temperaturePixelFontFamily = 'TemperaturePixel';

TextStyle? temperaturePixelTextStyle(
  BuildContext context,
  TextStyle? baseStyle,
) {
  final String? appFontFamily = Theme.of(
    context,
  ).textTheme.bodyMedium?.fontFamily;

  return baseStyle?.copyWith(
    fontFamily: temperaturePixelFontFamily,
    fontFamilyFallback: <String>[if (appFontFamily != null) appFontFamily],
    fontFeatures: const <ui.FontFeature>[ui.FontFeature.tabularFigures()],
  );
}
