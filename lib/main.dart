import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: GoalIsleApp()));
}

class GoalIsleApp extends StatelessWidget {
  const GoalIsleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Isle',
      debugShowCheckedModeBanner: false,
      theme: createAppTheme(),
      home: const Scaffold(
        body: Center(child: Text('Goal Isle v2 — building...')),
      ),
    );
  }
}
