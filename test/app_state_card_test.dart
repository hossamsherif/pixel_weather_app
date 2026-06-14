import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/core/theme/app_theme.dart';
import 'package:pixel_weather_app/l10n/app_localizations.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';

void main() {
  testWidgets('AppStateCard renders icon and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: AppStateCard(
            title: 'Title',
            message: 'Message',
            icon: Icons.cloud,
            actionLabel: 'Retry',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.byIcon(Icons.cloud), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(tapped, isTrue);
  });

  testWidgets('AppStateCard renders fixed HUD glyph without action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: const AppStateCard(title: 'Empty', message: 'No actions'),
        ),
      ),
    );

    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('No actions'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('loading variant exposes stable progress HUD', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AppStateCard(
          title: 'Loading',
          message: 'Loading',
          variant: AppStateCardVariant.loading,
          icon: Icons.hourglass_top,
        ),
      ),
    );

    expect(find.text('Loading'), findsNWidgets(2));
    expect(find.byKey(AppStateCard.loadingGlyphKey), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top), findsNothing);
  });

  testWidgets('dark theme error variant preserves action semantics', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      _wrap(
        AppStateCard(
          title: 'Something went wrong',
          message: 'Exception: network down',
          variant: AppStateCardVariant.error,
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onAction: () => retried = true,
        ),
        brightness: Brightness.dark,
      ),
    );

    final OutlinedButton button = tester.widget(find.byType(OutlinedButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('Arabic RTL empty card wraps long copy without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(
        const AppStateCard(
          title: 'لا توجد مفضلات حتى الآن',
          message:
              'احفظ المواقع للوصول إليها بسرعة عند الحاجة حتى لو كان اسم المدينة طويلا جدا ويحتاج إلى الالتفاف داخل البطاقة.',
          variant: AppStateCardVariant.empty,
          icon: Icons.favorite_border,
          actionLabel: 'إعادة المحاولة الآن',
          onAction: _noop,
        ),
        locale: Locale('ar'),
      ),
    );

    expect(find.text('لا توجد مفضلات حتى الآن'), findsOneWidget);
    expect(find.text('إعادة المحاولة الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(
  Widget child, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void _noop() {}
