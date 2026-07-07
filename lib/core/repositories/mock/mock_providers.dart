/// Riverpod providers backed by the in-memory [MockData] singleton.
///
/// All notifiers use the manual `StateNotifierProvider` + `StateNotifier`
/// pattern (NOT riverpod codegen) so they're importable from any feature's
/// presentation layer without a generated file. State is mutable in memory
/// only — nothing is persisted.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/friend.dart';
import '../../models/isle.dart';
import '../../models/membership.dart';
import '../../models/message.dart';
import '../../models/post.dart';
import '../../models/spark.dart';
import '../../models/user.dart';
import 'mock_data.dart';

// =============================================================================
// Current user
// =============================================================================

/// Holds the signed-in user account. Mutate via [UserNotifier.updateUser].
final currentUserProvider =
    StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(MockData.instance.currentUser);

  /// Replace any subset of fields. `null` arguments keep the existing value.
  void updateUser(User user) => state = user;
}

// =============================================================================
// Isles
// =============================================================================

/// All Isles (active + inactive). Drives Home faces, the Isles index, etc.
final islesProvider =
    StateNotifierProvider<IslesNotifier, List<Isle>>((ref) => IslesNotifier());

class IslesNotifier extends StateNotifier<List<Isle>> {
  IslesNotifier() : super(List<Isle>.of(MockData.instance.isles));

  void addIsle(Isle isle) => state = [...state, isle];

  void updateIsle(Isle isle) => state = [
        for (final i in state)
          if (i.id == isle.id) isle else i,
      ];

  void removeIsle(String isleId) =>
      state = [for (final i in state) if (i.id != isleId) i];

  /// Add a spark to an Isle.
  void addSpark(String isleId, Spark spark) => state = [
        for (final i in state)
          if (i.id == isleId) i.copyWith(sparks: [...i.sparks, spark]) else i,
      ];

  /// Replace a spark (matched by id) within its Isle.
  void updateSpark(String isleId, Spark spark) => state = [
        for (final i in state)
          if (i.id == isleId)
            i.copyWith(
              sparks: [
                for (final s in i.sparks)
                  if (s.id == spark.id) spark else s,
              ],
            )
          else
            i,
      ];

  /// Remove a spark by id from its Isle.
  void removeSpark(String isleId, String sparkId) => state = [
        for (final i in state)
          if (i.id == isleId)
            i.copyWith(
              sparks: [for (final s in i.sparks) if (s.id != sparkId) s],
            )
          else
            i,
      ];

  /// Append a post to an Isle's feed.
  void addPost(String isleId, Post post) => state = [
        for (final i in state)
          if (i.id == isleId) i.copyWith(posts: [...i.posts, post]) else i,
      ];

  /// Append a message to an Isle's chat room.
  void addMessage(String isleId, Message message) => state = [
        for (final i in state)
          if (i.id == isleId) i.copyWith(msgs: [...i.msgs, message]) else i,
      ];

  /// Replace a message (matched by id) within an Isle's chat room.
  void updateMessage(String isleId, Message message) => state = [
        for (final i in state)
          if (i.id == isleId)
            i.copyWith(
              msgs: [
                for (final m in i.msgs)
                  if (m.id == message.id) message else m,
              ],
            )
          else
            i,
      ];
}

// =============================================================================
// Memberships
// =============================================================================

/// Members of each Isle, keyed by isleId.
final membershipsProvider = StateNotifierProvider<MemberhipsNotifier,
    Map<String, List<Membership>>>(
  (ref) => MemberhipsNotifier(),
);

class MemberhipsNotifier
    extends StateNotifier<Map<String, List<Membership>>> {
  MemberhipsNotifier()
      : super(Map<String, List<Membership>>.of(MockData.instance.memberships));

  /// Add a member to an Isle (creates the key if absent).
  void addMember(String isleId, Membership member) {
    final next = Map<String, List<Membership>>.of(state);
    next[isleId] = [...(next[isleId] ?? const []), member];
    state = next;
  }

  /// Remove a member (matched by userId) from an Isle.
  void removeMember(String isleId, String userId) {
    final next = Map<String, List<Membership>>.of(state);
    final list = next[isleId];
    if (list == null) return;
    next[isleId] = [for (final m in list) if (m.userId != userId) m];
    state = next;
  }
}

// =============================================================================
// Friends
// =============================================================================

/// Friend relationships from the current user's point of view.
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<Friend>>(
  (ref) => FriendsNotifier(),
);

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super(List<Friend>.of(MockData.instance.friends));

  /// Accept an incoming request: flip status to 'accepted'.
  void acceptFriend(String friendId) => state = [
        for (final f in state)
          if (f.friendId == friendId)
            f.copyWith(status: 'accepted')
          else
            f,
      ];

  /// Decline an incoming (or cancel an outgoing) request: drop the row.
  void declineFriend(String friendId) =>
      state = [for (final f in state) if (f.friendId != friendId) f];

  /// Remove an established friendship.
  void unfriend(String friendId) =>
      state = [for (final f in state) if (f.friendId != friendId) f];

  /// Send a new outgoing request. The supplied [friend] should already carry
  /// status `'pending_out'`.
  void sendRequest(Friend friend) => state = [...state, friend];
}

// =============================================================================
// Auth
// =============================================================================

/// Simple signed-in flag. `true` once the user has joined.
final authStateProvider =
    StateNotifierProvider<AuthNotifier, bool>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(true);

  void signIn() => state = true;

  void signOut() => state = false;
}

// =============================================================================
// Navigation / selection
// =============================================================================

/// Which Isle is currently drilled into (Isle Home screen). `null` = none.
final activeIsleIdProvider = StateProvider<String?>((ref) => null);

/// Which Spark is currently viewed (Spark Details screen). `null` = none.
final activeSparkIdProvider = StateProvider<String?>((ref) => null);
