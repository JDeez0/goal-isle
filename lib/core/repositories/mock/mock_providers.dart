/// Riverpod providers — hybrid Supabase + optimistic local state.
///
/// On init, loads from Supabase (if configured) or falls back to MockData.
/// All mutations update local state instantly (optimistic) AND fire-and-forget
/// to Supabase for persistence.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../models/friend.dart';
import '../../models/isle.dart';
import '../../models/membership.dart';
import '../../models/message.dart';
import '../../models/post.dart';
import '../../models/spark.dart';
import '../../models/user.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_repository.dart';
import 'mock_data.dart';

// =============================================================================
// Current user
// =============================================================================

final currentUserProvider =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(MockData.instance.currentUser);

  void updateUser(User user) {
    state = user;
    // Persist to Supabase
    if (SupabaseConfig.client.auth.currentUser != null) {
      SupabaseConfig.client.from('profiles').upsert({
        'id': SupabaseConfig.client.auth.currentUser!.id,
        'name': user.name,
        'handle': user.handle,
        'avatar': user.avatar,
        'bio': user.bio,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Load profile from Supabase after auth.
  Future<void> loadFromSupabase() async {
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final row = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (row != null && mounted) {
        state = User(
          id: uid,
          name: row['name'] ?? '',
          handle: row['handle'] ?? '',
          avatar: row['avatar'] ?? '🧑',
          bio: row['bio'],
        );
      }
    } catch (_) {}
  }
}

// =============================================================================
// Auth state
// =============================================================================

/// Simple bool — true when Supabase has a session.
final authStateProvider = StateProvider<bool>((ref) {
  return SupabaseConfig.client.auth.currentSession != null;
});

// =============================================================================
// Isles
// =============================================================================

final islesProvider =
    StateNotifierProvider<IslesNotifier, List<Isle>>((ref) => IslesNotifier());

class IslesNotifier extends StateNotifier<List<Isle>> {
  IslesNotifier() : super(List<Isle>.of(MockData.instance.isles)) {
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    if (SupabaseConfig.client.auth.currentUser == null) return;
    try {
      final isles = await SupabaseRepository.fetchIsles();
      if (mounted) state = isles;
    } catch (_) {}
  }

  void refresh() => _loadFromSupabase();

  void addIsle(Isle isle) {
    state = [...state, isle];
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid != null) {
      SupabaseRepository.createIsle(isle, uid).then((_) {}).catchError((_) {});
    }
  }

  void updateIsle(Isle isle) {
    state = [for (final i in state) if (i.id == isle.id) isle else i];
    SupabaseRepository.updateIsle(isle).then((_) {}).catchError((_) {});
  }

  void removeIsle(String isleId) {
    state = [for (final i in state) if (i.id != isleId) i];
    SupabaseRepository.deleteIsle(isleId).then((_) {}).catchError((_) {});
  }

  void addSpark(String isleId, Spark spark) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(sparks: [...i.sparks, spark]) else i,
    ];
    SupabaseRepository.createSpark(spark).then((_) {}).catchError((_) {});
  }

  void updateSpark(String isleId, Spark spark) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(sparks: [for (final s in i.sparks) if (s.id == spark.id) spark else s])
        else
          i,
    ];
    SupabaseRepository.updateSpark(spark).then((_) {}).catchError((_) {});
  }

  void removeSpark(String isleId, String sparkId) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(sparks: [for (final s in i.sparks) if (s.id != sparkId) s])
        else
          i,
    ];
    SupabaseRepository.deleteSpark(sparkId).then((_) {}).catchError((_) {});
  }

  void addPost(String isleId, Post post) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(posts: [...i.posts, post]) else i,
    ];
    SupabaseRepository.createPost(post).then((_) {}).catchError((_) {});
  }

  void addMessage(String isleId, Message message) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(msgs: [...i.msgs, message]) else i,
    ];
    SupabaseRepository.sendMessage(message).then((_) {}).catchError((_) {});
  }

  void updateMessage(String isleId, Message message) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(msgs: [for (final m in i.msgs) if (m.id == message.id) message else m])
        else
          i,
    ];
    SupabaseRepository.updateMessage(message).then((_) {}).catchError((_) {});
  }
}

// =============================================================================
// Memberships
// =============================================================================

final membershipsProvider = StateNotifierProvider<MemberhipsNotifier, Map<String, List<Membership>>>(
  (ref) => MemberhipsNotifier(),
);

class MemberhipsNotifier extends StateNotifier<Map<String, List<Membership>>> {
  MemberhipsNotifier() : super(Map<String, List<Membership>>.of(MockData.instance.memberships));

  void addMember(String isleId, Membership m) {
    final list = [...(state[isleId] ?? <Membership>[]), m];
    final newState = Map<String, List<Membership>>.from(state);
    newState[isleId] = list;
    state = newState;
    SupabaseRepository.addMember(m).then((_) {}).catchError((_) {});
  }

  void removeMember(String isleId, String userId) {
    final list = [...(state[isleId] ?? <Membership>[])];
    list.removeWhere((m) => m.userId == userId);
    final newState = Map<String, List<Membership>>.from(state);
    newState[isleId] = list;
    state = newState;
    SupabaseRepository.removeMember(isleId, userId).then((_) {}).catchError((_) {});
  }
}

// =============================================================================
// Friends
// =============================================================================

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>(
  (ref) => FriendsNotifier(),
);

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super(List<Friend>.of(MockData.instance.friends));

  void acceptFriend(String name) {
    state = [for (final f in state) if (f.friendName == name) f.copyWith(status: 'accepted') else f];
  }

  void declineFriend(String name) {
    state = [for (final f in state) if (f.friendName != name) f];
  }

  void unfriend(String name) {
    state = [for (final f in state) if (f.friendName != name) f];
  }

  void sendRequest(Friend f) {
    state = [...state, f];
  }
}

// =============================================================================
// Navigation state (UI-only, not persisted)
// =============================================================================

final activeIsleIdProvider = StateProvider<String?>((ref) => null);
final activeSparkIdProvider = StateProvider<String?>((ref) => null);
