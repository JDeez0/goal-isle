// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goal_isle/main.dart';

void main() {
  testWidgets('App loads and shows mock isles', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: GoalIsleApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // If an error fallback is shown, print the error message to help debugging.
    final errorFinder = find.text('Something went wrong');
    if (errorFinder.evaluate().isNotEmpty) {
      final errorTextWidget = tester.widget<Text>(find.textContaining('Error:'));
      debugPrint('RUNTIME ERROR: ${errorTextWidget.data}');
    }

    // Verify that mock isles are rendered.
    expect(find.text('Fitness Journey'), findsOneWidget);
  });
}
