import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';

void main() {
  setUpAll(_loadScreenshotFonts);

  final List<_Scenario> scenarios = <_Scenario>[
    const _Scenario(
      name: 'state_cards_light_en',
      locale: Locale('en'),
      themeMode: ThemeMode.light,
    ),
    const _Scenario(
      name: 'state_cards_dark_en',
      locale: Locale('en'),
      themeMode: ThemeMode.dark,
    ),
    const _Scenario(
      name: 'state_cards_light_ar',
      locale: Locale('ar'),
      themeMode: ThemeMode.light,
    ),
  ];

  for (final _Scenario scenario in scenarios) {
    testWidgets('captures ${scenario.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 780));
      await tester.pumpWidget(_VisualApp(scenario: scenario));
      await tester.pump();

      await expectLater(
        find.byType(_VisualApp),
        matchesGoldenFile('goldens/${scenario.name}.png'),
      );
    }, skip: true);
  }
}

Future<void> _loadScreenshotFonts() async {
  final FontLoader loader = FontLoader('ScreenshotSans');
  final List<File> candidates = <File>[
    File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf'),
    File('/Library/Fonts/Arial Unicode.ttf'),
  ];
  final File font = candidates.firstWhere(
    (candidate) => candidate.existsSync(),
    orElse: () => candidates.first,
  );
  if (font.existsSync()) {
    loader.addFont(
      font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
  }
  await loader.load();
}

class _Scenario {
  const _Scenario({
    required this.name,
    required this.locale,
    required this.themeMode,
  });

  final String name;
  final Locale locale;
  final ThemeMode themeMode;
}

class _VisualApp extends StatelessWidget {
  const _VisualApp({required this.scenario});

  final _Scenario scenario;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _withScreenshotFont(AppTheme.lightTheme()),
      darkTheme: _withScreenshotFont(AppTheme.darkTheme()),
      themeMode: scenario.themeMode,
      locale: scenario.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Directionality(
        textDirection: scenario.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AppStateCard(
                title: scenario.locale.languageCode == 'ar'
                    ? 'لا توجد مفضلات حتى الآن'
                    : 'No favorites yet',
                message: scenario.locale.languageCode == 'ar'
                    ? 'احفظ المواقع للوصول إليها بسرعة عند الحاجة.'
                    : 'Save locations to access them quickly.',
                variant: AppStateCardVariant.empty,
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 16),
              AppStateCard(
                title: scenario.locale.languageCode == 'ar'
                    ? 'جار التحميل'
                    : 'Loading',
                message: scenario.locale.languageCode == 'ar'
                    ? 'جار التحميل'
                    : 'Loading',
                variant: AppStateCardVariant.loading,
                icon: Icons.hourglass_top,
              ),
              const SizedBox(height: 16),
              AppStateCard(
                title: scenario.locale.languageCode == 'ar'
                    ? 'تعذر تحميل الطقس'
                    : 'Could not load weather',
                message: scenario.locale.languageCode == 'ar'
                    ? 'تحقق من الاتصال ثم حاول مرة أخرى.'
                    : 'Check the connection, then try again.',
                variant: AppStateCardVariant.error,
                icon: Icons.error_outline,
                actionLabel: scenario.locale.languageCode == 'ar'
                    ? 'إعادة المحاولة'
                    : 'Retry',
                onAction: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ThemeData _withScreenshotFont(ThemeData theme) {
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'ScreenshotSans'),
  );
}
