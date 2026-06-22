import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // DISABLED FOR MOCKUP
import 'package:goal_isle/models/friend.dart';

class FriendNotifier extends StateNotifier<List<Friend>> {
  FriendNotifier() : super([]);
  
  void initialize() {
    if (state.isEmpty) {
      _loadMockData();
    }
  }

  void _loadMockData() {
    state = [
      Friend(
        id: '1',
        userId: 'mock-user',
        friendId: 'friend-alice',
        status: 'accepted',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Friend(
        id: '2',
        userId: 'mock-user',
        friendId: 'friend-bob',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // DISABLED FOR MOCKUP - Supabase fetch
  Future<void> fetchFriends() async {
    // No-op - using mock data
  }

  // DISABLED FOR MOCKUP - Supabase add friend
  Future<void> addFriend(String phoneNumber) async {
    // No-op - using mock data
  }
}

final friendProvider = StateNotifierProvider<FriendNotifier, List<Friend>>((ref) {
  return FriendNotifier();
});
