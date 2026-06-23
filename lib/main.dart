import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_isle/screens/main/main_screen.dart';
import 'package:goal_isle/theme/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      const ProviderScope(
        child: GoalIsleApp(),
      ),
    );
  } catch (e) {
    // Crucial: Fallback for bootstrap errors
    print("FATAL APP ERROR: $e");
    // Optionally create a native error overlay here if flutter is not yet active
  }
}

class GoalIsleApp extends StatelessWidget {
  const GoalIsleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Isle',
      debugShowCheckedModeBanner: false,
      theme: createAppTheme(),
      home: const MainScreen(),
    );
  }
}