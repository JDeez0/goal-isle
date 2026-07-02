// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP

class SupabaseConfig {
  // DISABLED FOR MOCKUP - Real URL+key rotated on 2026-07-01 (see docs/AUDIT_2026_07_01.md § 5)
  static const String supabaseUrl = 'https://FAKE_PROJECT_ID.supabase.co';
  static const String publishableKey = 'sb_publishable_FAKE_KEY_ROTATED';

  static Future<void> initialize() async {
    // DISABLED FOR MOCKUP - No Supabase needed
    // await Supabase.initialize(
    //   url: supabaseUrl,
    //   anonKey: publishableKey,
    // );
  }
}
