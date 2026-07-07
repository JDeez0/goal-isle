// Basic Flutter widget test for the Goal Isle app shell.
//
// Verifies the app boots into the GoRouter shell and lands on the Home tab.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goal_isle/app/app.dart';

void main() {
  testWidgets('App loads onto the Home tab', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: GoalIsleApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // The Home tab placeholder renders its title text.
    expect(find.text('Home'), findsWidgets);
  });
}
