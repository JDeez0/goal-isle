import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/repositories/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (only if configured — falls back to mock if not)
  if (SupabaseConfig.supabaseUrl != 'YOUR_SUPABASE_URL') {
    await SupabaseConfig.initialize();
  }

  runApp(const ProviderScope(child: GoalIsleApp()));
}
