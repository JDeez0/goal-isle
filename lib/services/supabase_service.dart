// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP

class SupabaseService {
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    // DISABLED FOR MOCKUP - Return null
    return null;
    
    // try {
    //   final response = await Supabase.instance.client
    //       .from('users')
    //       .select()
    //       .eq('id', userId)
    //       .single();

    //   return response as Map<String, dynamic>?;
    // } catch (e) {
    //   return null;
    // }
  }

  static Future<void> createUser({
    required String id,
    required String email,
    required String username,
  }) async {
    // DISABLED FOR MOCKUP - No-op
    
    // await Supabase.instance.client.from('users').insert({
    //   'id': id,
    //   'email': email,
    //   'username': username,
    //   'settings': {
    //     'notifications': true,
    //     'theme': 'dark',
    //   },
    // });
  }
}