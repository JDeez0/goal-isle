/// Riverpod providers — hybrid Supabase + optimistic local state.
///
/// On init, loads from Supabase (if configured) or falls back to MockData.
/// All mutations update local state instantly (optimistic) AND fire-and-forget
/// to Supabase for persistence.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Returns the real (Supabase-UUID) Isle. If no Supabase user, returns
  /// the local isle unchanged. Callers can await this and then add the
  /// creator's membership to the local memberships provider using the real id.
  Future<Isle> addIsle(Isle isle) async {
    state = [...state, isle];
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid == null) return isle;
    try {
      final realIsle = await SupabaseRepository.createIsle(isle, uid);
      debugPrint('addIsle: SUCCESS, real id=${realIsle.id}');
      state = [
        for (final i in state)
          if (i.id == isle.id) realIsle else i,
      ];
      return realIsle;
    } catch (e) {
      debugPrint('Supabase error: $e');
      return isle;
    }
  }

  void updateIsle(Isle isle) {
    state = [for (final i in state) if (i.id == isle.id) isle else i];
    SupabaseRepository.updateIsle(isle).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void removeIsle(String isleId) {
    state = [for (final i in state) if (i.id != isleId) i];
    SupabaseRepository.deleteIsle(isleId).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void addSpark(String isleId, Spark spark) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(sparks: [...i.sparks, spark]) else i,
    ];
    SupabaseRepository.createSpark(spark).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void updateSpark(String isleId, Spark spark) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(sparks: [for (final s in i.sparks) if (s.id == spark.id) spark else s])
        else
          i,
    ];
    SupabaseRepository.updateSpark(spark).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void removeSpark(String isleId, String sparkId) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(sparks: [for (final s in i.sparks) if (s.id != sparkId) s])
        else
          i,
    ];
    SupabaseRepository.deleteSpark(sparkId).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void addPost(String isleId, Post post) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(posts: [...i.posts, post]) else i,
    ];
    SupabaseRepository.createPost(post).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void addMessage(String isleId, Message message) {
    state = [
      for (final i in state)
        if (i.id == isleId) i.copyWith(msgs: [...i.msgs, message]) else i,
    ];
    SupabaseRepository.sendMessage(message).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void updateMessage(String isleId, Message message) {
    state = [
      for (final i in state)
        if (i.id == isleId)
          i.copyWith(msgs: [for (final m in i.msgs) if (m.id == message.id) message else m])
        else
          i,
    ];
    SupabaseRepository.updateMessage(message).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }
}

// =============================================================================
// Memberships
// =============================================================================

final membershipsProvider = StateNotifierProvider<MemberhipsNotifier, Map<String, List<Membership>>>(
  (ref) => MemberhipsNotifier(),
);

class MemberhipsNotifier extends StateNotifier<Map<String, List<Membership>>> {
  MemberhipsNotifier() : super(Map<String, List<Membership>>.of(MockData.instance.memberships)) {
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final map = await SupabaseRepository.fetchMembershipsByUser(uid);
      if (mounted && map.isNotEmpty) {
        // Merge: Supabase rows are authoritative for the signed-in user.
        // Keep mock entries for any isle the user isn't (yet) a real member of.
        final merged = Map<String, List<Membership>>.of(state);
        for (final entry in map.entries) {
          merged[entry.key] = entry.value;
        }
        state = merged;
      }
    } catch (_) {}
  }

  void refresh() => _loadFromSupabase();

  /// Local-state-only membership add. Use this when the membership has
  /// *already* been inserted into Supabase by another code path (e.g.
  /// `createIsle` inserts the creator's membership as part of the
  /// Isle-creation flow). Calling the full `addMember` in that case would
  /// fire a duplicate Supabase insert and collide on `memberships_pkey`.
  void addMemberLocal(String isleId, Membership m) {
    final list = [...(state[isleId] ?? <Membership>[]), m];
    final newState = Map<String, List<Membership>>.from(state);
    newState[isleId] = list;
    state = newState;
  }

  /// Full membership add: updates local state AND fires a Supabase insert.
  /// Use this for flows where the membership is NOT already inserted by
  /// another path — e.g. Discover Join (the user joins an existing public
  /// Isle, no `createIsle` involved).
  void addMember(String isleId, Membership m) {
    addMemberLocal(isleId, m);
    SupabaseRepository.addMember(m).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void removeMember(String isleId, String userId) {
    final list = [...(state[isleId] ?? <Membership>[])];
    list.removeWhere((m) => m.userId == userId);
    final newState = Map<String, List<Membership>>.from(state);
    newState[isleId] = list;
    state = newState;
    SupabaseRepository.removeMember(isleId, userId).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }
}

// =============================================================================
// Friends
// =============================================================================

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>(
  (ref) => FriendsNotifier(),
);

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super(List<Friend>.of(MockData.instance.friends)) {
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final list = await SupabaseRepository.fetchFriends(uid);
      if (mounted && list.isNotEmpty) state = list;
    } catch (_) {}
  }

  void refresh() => _loadFromSupabase();

  void acceptFriend(String friendId) {
    final target = state.where((f) => f.friendId == friendId).firstOrNull;
    if (target == null) return;

    state = state.map((f) {
      if (f.friendId == friendId) return f.copyWith(status: 'accepted');
      return f;
    }).toList();

    SupabaseRepository.acceptFriend(
      friendId,
      target.friendName,
      target.friendAvatar,
    ).then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void declineFriend(String friendId) {
    final target = state.where((f) => f.friendId == friendId).firstOrNull;
    state = [for (final f in state) if (f.friendId != friendId) f];
    if (target != null) {
      SupabaseRepository.deleteFriend(friendId)
          .then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
    }
  }

  void unfriend(String friendId) {
    state = [for (final f in state) if (f.friendId != friendId) f];
    SupabaseRepository.deleteFriend(friendId)
        .then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }

  void sendRequest(Friend f) {
    state = [...state, f];
    SupabaseRepository.createFriend(f)
        .then((_) {}).catchError((e, s) { debugPrint("Supabase error: $e"); });
  }
}

// =============================================================================
// Navigation state (UI-only, not persisted)
// =============================================================================

final activeIsleIdProvider = StateProvider<String?>((ref) => null);
final activeSparkIdProvider = StateProvider<String?>((ref) => null);
