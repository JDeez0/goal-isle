import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/user.dart';
import 'supabase_client.dart';

/// Real auth provider backed by Supabase.
/// Replaces the mock authStateProvider when wired in.
class SupabaseAuthNotifier extends StateNotifier<User?> {
  SupabaseAuthNotifier() : super(null) {
    _init();
  }

  late StreamSubscription<AuthState> _sub;

  void _init() {
    // Check current session
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      _loadProfile();
    }

    // Listen for auth changes
    _sub = SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
  }

  Future<void> _loadProfile() async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final row = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (row != null) {
        state = User(
          id: row['id'],
          name: row['name'] ?? '',
          handle: row['handle'] ?? '',
          avatar: row['avatar'] ?? '🧑',
          bio: row['bio'],
        );
      }
    } catch (_) {
      // Profile not yet created — trigger handles it
    }
  }

  Future<void> signUp(String email, String password, String handle) async {
    await SupabaseConfig.client.auth.signUp(
      email: email,
      password: password,
      data: {'handle': handle},
    );
  }

  Future<void> signIn(String email, String password) async {
    await SupabaseConfig.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await SupabaseConfig.client.auth.signOut();
    state = null;
  }

  void updateProfile(User user) async {
    await SupabaseConfig.client.from('profiles').upsert({
      'id': user.id,
      'name': user.name,
      'handle': user.handle,
      'avatar': user.avatar,
      'bio': user.bio,
      'updated_at': DateTime.now().toIso8601String(),
    });
    state = user;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Provides the current authenticated user (or null if signed out).
final supabaseAuthProvider =
    StateNotifierProvider<SupabaseAuthNotifier, User?>(
  (ref) => SupabaseAuthNotifier(),
);

/// Simple bool: is the user signed in?
final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(supabaseAuthProvider) != null,
);
