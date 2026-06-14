import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppStateCard extends StatelessWidget {
  const AppStateCard({
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final PixelWeatherTokens pixel = PixelWeatherTokens.of(context);

    return Card(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pixel.stateCardFill,
          border: Border(
            left: BorderSide(color: pixel.stateCardAccent, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Icon(icon, size: 28, color: pixel.stateCardAccent),
                ),
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message, style: textTheme.bodyMedium),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 12),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
