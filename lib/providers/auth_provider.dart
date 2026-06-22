import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/user.dart';
// import 'package:goal_isle/services/supabase_service.dart'; // DISABLED FOR MOCKUP

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    // DISABLED FOR MOCKUP - Don't auto-init
    // _init();
  }

  // DISABLED FOR MOCKUP - Supabase initialization
  // Future<void> _init() async {
  //   // Check if user is already signed in
  //   final currentUser = supabase.Supabase.instance.client.auth.currentUser;
  //   if (currentUser != null) {
  //     // Fetch user data from database
  //     final userData = await SupabaseService.getUser(currentUser.id);
  //     if (userData != null) {
  //       state = User.fromJson(userData);
  //     }
  //   }
  // }

  Future<void> signInWithEmail(String email, String password) async {
    // DISABLED FOR MOCKUP - Mock sign in
    state = User(
      id: 'mock-user-id',
      email: email,
      username: email.split('@')[0],
      settings: const {
        'notifications': true,
        'theme': 'dark',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // try {
    //   final response = await supabase.Supabase.instance.client.auth.signInWithPassword(
    //     email: email,
    //     password: password,
    //   );

    //   if (response.user != null) {
    //     // Check if user exists in database
    //     final userData = await SupabaseService.getUser(response.user!.id);

    //     if (userData != null) {
    //       state = User.fromJson(userData);
    //     }
    //   }
    // } catch (e) {
    //   // Handle auth errors
    //   rethrow;
    // }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    // DISABLED FOR MOCKUP - Mock sign up
    state = User(
      id: 'mock-user-id',
      email: email,
      username: email.split('@')[0],
      settings: const {
        'notifications': true,
        'theme': 'dark',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // try {
    //   final response = await supabase.Supabase.instance.client.auth.signUp(
    //     email: email,
    //     password: password,
    //   );

    //   if (response.user != null) {
    //     // Create user record
    //     await SupabaseService.createUser(
    //       id: response.user!.id,
    //       email: email,
    //       username: email.split('@')[0],
    //     );

    //     state = User(
    //       id: response.user!.id,
    //       email: email,
    //       username: email.split('@')[0],
    //       settings: const {
    //         'notifications': true,
    //         'theme': 'dark',
    //       },
    //       createdAt: DateTime.now(),
    //       updatedAt: DateTime.now(),
    //     );
    //   }
    // } catch (e) {
    //   rethrow;
    // }
  }

  Future<void> signOut() async {
    state = null;
    // await supabase.Supabase.instance.client.auth.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});