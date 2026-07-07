import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/friend.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Friends — the account-level friends manager. Shows incoming requests,
/// established friends, and outgoing (pending) requests. The + button opens an
/// add-friend bottom sheet with a search field and mock results.
///
/// Per Language Principle: no "ritual"/"spark" words in UI copy.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);

    final requests = friends.where((f) => f.status == 'pending_in').toList();
    final accepted = friends.where((f) => f.status == 'accepted').toList();
    final sent = friends.where((f) => f.status == 'pending_out').toList();
    final isEmpty =
        requests.isEmpty && accepted.isEmpty && sent.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: isEmpty
          ? const _EmptyState(text: 'no friends yet')
          : ListView(
              children: [
                const SizedBox(height: 12),
                if (requests.isNotEmpty) ...[
                  const _SectionLabel('Requests'),
                  _Panel(children: [
                    for (int i = 0; i < requests.length; i++) ...[
                      _RequestRow(friend: requests[i]),
                      if (i < requests.length - 1)
                        const _Divider(),
                    ],
                  ]),
                  const SizedBox(height: 22),
                ],
                if (accepted.isNotEmpty) ...[
                  const _SectionLabel('Friends'),
                  _Panel(children: [
                    for (int i = 0; i < accepted.length; i++) ...[
                      _FriendRow(friend: accepted[i]),
                      if (i < accepted.length - 1)
                        const _Divider(),
                    ],
                  ]),
                  const SizedBox(height: 22),
                ],
                if (sent.isNotEmpty) ...[
                  const _SectionLabel('Sent'),
                  _Panel(children: [
                    for (int i = 0; i < sent.length; i++) ...[
                      _SentRow(friend: sent[i]),
                      if (i < sent.length - 1)
                        const _Divider(),
                    ],
                  ]),
                  const SizedBox(height: 32),
                ],
              ],
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddFriendSheet(),
    );
  }
}

/// A request row: avatar, name, "wants to be friends", Accept + Decline.
class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Avatar(emoji: friend.friendAvatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.friendName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'wants to be friends',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () =>
                ref.read(friendsProvider.notifier).declineFriend(friend.friendId),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Decline', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                ref.read(friendsProvider.notifier).acceptFriend(friend.friendId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Accept', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// An established-friend row: avatar, name, "friend", Remove.
class _FriendRow extends ConsumerWidget {
  const _FriendRow({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Avatar(emoji: friend.friendAvatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.friendName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'friend',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(friendsProvider.notifier).unfriend(friend.friendId),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// A sent-request row: avatar, name, "pending".
class _SentRow extends StatelessWidget {
  const _SentRow({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Avatar(emoji: friend.friendAvatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.friendName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'pending',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              'pending',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add-friend bottom sheet: a search field + a list of mock results.
/// Each result has an "Add" button that sends a request (status → pending_out).
class _AddFriendSheet extends ConsumerStatefulWidget {
  const _AddFriendSheet();

  @override
  ConsumerState<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<_AddFriendSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final results = _searchResults(friends, _query);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grabber.
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          // Search field.
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search people',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search,
                  size: 20, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF4F6F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: results.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'no results',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFECEFF2)),
                    itemBuilder: (context, i) {
                      final r = results[i];
                      final alreadyPending =
                          friends.any((f) => f.friendId == r.id);
                      return _SearchRow(
                        name: r.name,
                        avatar: r.avatar,
                        added: alreadyPending,
                        onAdd: () {
                          ref.read(friendsProvider.notifier).sendRequest(
                                Friend(
                                  id: 'fr-${r.id}',
                                  userId: ref.read(currentUserProvider).id,
                                  friendId: r.id,
                                  friendName: r.name,
                                  friendAvatar: r.avatar,
                                  status: 'pending_out',
                                  createdAt: DateTime.now(),
                                ),
                              );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build a deterministic pool of mock people from the membership + friend
  /// data, then filter by the current query. People who are already friends
  /// (any status) still appear so the Add button can show a pending state.
  List<_Person> _searchResults(List<Friend> friends, String query) {
    final pool = <String, _Person>{};

    void add(String id, String name, String avatar) {
      pool.putIfAbsent(id, () => _Person(id, name, avatar));
    }

    // Pull known people from memberships across all Isles.
    final memberships = ref.read(membershipsProvider);
    for (final list in memberships.values) {
      for (final m in list) {
        if (m.userId == ref.read(currentUserProvider).id) continue;
        add(m.userId, m.userName, m.userAvatar);
      }
    }
    // Add a few extra mock people so the sheet feels populated.
    add('u-maya', 'Maya', '👩');
    add('u-noah', 'Noah', '🧑');
    add('u-emma', 'Emma', '👩‍🦰');

    final people = pool.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    if (query.isEmpty) return people;
    return people.where((p) => p.name.toLowerCase().contains(query)).toList();
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.name,
    required this.avatar,
    required this.added,
    required this.onAdd,
  });

  final String name;
  final String avatar;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          _Avatar(emoji: avatar, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          added
              ? const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text(
                    'pending',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 13)),
                ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.emoji, this.size = 40});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(emoji,
            style: TextStyle(fontSize: size * 0.5, height: 1)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECEFF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFECEFF2)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

/// A mock-searchable person.
class _Person {
  const _Person(this.id, this.name, this.avatar);

  final String id;
  final String name;
  final String avatar;
}
