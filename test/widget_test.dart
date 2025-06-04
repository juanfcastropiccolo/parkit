// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parkit_app/main.dart';
import 'package:parkit_app/screens/splash_screen.dart';

void main() {
  testWidgets('App builds and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkitApp());

    // Verify that the splash screen widgets are present right after launch.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('parkit'), findsOneWidget);
    expect(find.text('Inicializando...'), findsOneWidget);

    // Advance time to allow initialization logic to run.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Configuration is missing in tests, so an AlertDialog is shown.
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
