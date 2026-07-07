import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase client. Initialized in main.dart before runApp.
/// Configure with your project URL + anon key.
class SupabaseConfig {
  static const String supabaseUrl = 'https://mjnitlwhpqylivplkkxu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qbml0bHdocHF5bGl2cGxra3h1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NDA2MjUsImV4cCI6MjA5NzIxNjYyNX0.SpwFpLftDpFVOcPxv9PX5AERUtSOtjLS00TUij-YoUk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
