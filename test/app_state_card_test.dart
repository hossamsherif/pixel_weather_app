import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_weather_app/presentation/widgets/app_state_card.dart';

void main() {
  testWidgets('AppStateCard renders icon and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
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

  testWidgets('AppStateCard renders without icon and action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateCard(
            title: 'Empty',
            message: 'No actions',
          ),
        ),
      ),
    );

    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('No actions'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
