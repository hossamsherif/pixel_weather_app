import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum AppStateCardVariant { empty, loading, error, offline, location, apiKey }

class AppStateCard extends StatelessWidget {
  const AppStateCard({
    required this.title,
    required this.message,
    this.icon,
    this.variant = AppStateCardVariant.empty,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  static const Key loadingGlyphKey = Key('app-state-loading-glyph');

  final String title;
  final String message;
  final IconData? icon;
  final AppStateCardVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);
    final ColorScheme colors = theme.colorScheme;
    final _StateCardPalette palette = _paletteFor(colors, pixel, variant);
    final bool hasAction = actionLabel != null && onAction != null;
    final bool isLoading = variant == AppStateCardVariant.loading;

    return Semantics(
      container: true,
      liveRegion: isLoading,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 156),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.fill,
            border: Border.all(color: palette.border, width: 2),
            borderRadius: BorderRadius.circular(6),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: pixel.spriteShadow,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.surface.withValues(alpha: 0.64),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _StateGlyph(
                    icon: icon,
                    isLoading: isLoading,
                    palette: palette,
                    semanticsLabel: title,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            color: palette.onFill,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        if (message.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: textTheme.bodyMedium?.copyWith(
                              color: palette.onFill.withValues(alpha: 0.86),
                              height: 1.28,
                            ),
                          ),
                        ] else
                          const SizedBox(height: 24),
                        if (hasAction) ...<Widget>[
                          const SizedBox(height: 14),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _PixelActionButton(
                              label: actionLabel!,
                              onPressed: onAction!,
                              palette: palette,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateGlyph extends StatelessWidget {
  const _StateGlyph({
    required this.icon,
    required this.isLoading,
    required this.palette,
    required this.semanticsLabel,
  });

  final IconData? icon;
  final bool isLoading;
  final _StateCardPalette palette;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.accent.withValues(alpha: 0.16),
          border: Border.all(color: palette.accent, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: isLoading
              ? Semantics(
                  label: semanticsLabel,
                  child: SizedBox(
                    key: AppStateCard.loadingGlyphKey,
                    width: 28,
                    height: 22,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        _LoadingBar(color: palette.accent, height: 10),
                        _LoadingBar(color: palette.accent, height: 18),
                        _LoadingBar(color: palette.accent, height: 14),
                      ],
                    ),
                  ),
                )
              : Icon(
                  icon ?? Icons.info_outline,
                  size: 28,
                  color: palette.accent,
                ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 6,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class _PixelActionButton extends StatelessWidget {
  const _PixelActionButton({
    required this.label,
    required this.onPressed,
    required this.palette,
  });

  final String label;
  final VoidCallback onPressed;
  final _StateCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.accent,
        side: BorderSide(color: palette.accent, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        minimumSize: const Size(48, 42),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

@immutable
class _StateCardPalette {
  const _StateCardPalette({
    required this.fill,
    required this.border,
    required this.accent,
    required this.onFill,
  });

  final Color fill;
  final Color border;
  final Color accent;
  final Color onFill;
}

_StateCardPalette _paletteFor(
  ColorScheme colors,
  PixelWeatherTokens pixel,
  AppStateCardVariant variant,
) {
  final Color accent = switch (variant) {
    AppStateCardVariant.empty => pixel.stateCardAccent,
    AppStateCardVariant.loading => colors.tertiary,
    AppStateCardVariant.error => colors.error,
    AppStateCardVariant.offline => colors.secondary,
    AppStateCardVariant.location => pixel.stateCardAccent,
    AppStateCardVariant.apiKey => colors.error,
  };

  return _StateCardPalette(
    fill: Color.alphaBlend(accent.withValues(alpha: 0.08), pixel.stateCardFill),
    border: pixel.forecastCardBorder,
    accent: accent,
    onFill: colors.onSurface,
  );
}
