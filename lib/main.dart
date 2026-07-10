import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/repositories/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (only if configured — falls back to mock if not).
  // Wrap in try/catch so a failed init never causes a black screen.
  try {
    if (SupabaseConfig.supabaseUrl != 'YOUR_SUPABASE_URL') {
      await SupabaseConfig.initialize();
    }
  } catch (e) {
    debugPrint('Supabase init failed: $e — running in offline/mock mode');
  }

  runApp(const ProviderScope(child: GoalIsleApp()));
}
