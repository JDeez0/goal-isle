import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:goal_isle/config/supabase_config.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/screens/main/main_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF60A5FA),
          secondary: Color(0xFF34D399),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class SimpleTestScreen extends StatelessWidget {
  const SimpleTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Goal Isle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'App is working! Next step: add back MainScreen',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}