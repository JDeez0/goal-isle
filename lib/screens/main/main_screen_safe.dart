import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_isle/providers/isle_provider.dart';

class SafeMainScreen extends ConsumerWidget {
  const SafeMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try accessing isle provider
    final isles = ref.watch(isleProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Goal Isle - Testing Provider Access',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Isles count: ${isles.length}',
              style: const TextStyle(
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