import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/repositories/mock/mock_data.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Discover — browse discoverable public Isles and join them.
///
/// Reads [MockData.instance.discover] (raw rows: name, emoji, color, members,
/// sub). Each row shows a skewed tinted emoji tile, the name, a sub-description,
/// the member count, and a Join button. Joining adds the Isle to
/// [islesProvider] plus a membership for the current user; the button toggles
/// to "Joined" (tap again to leave). A search field filters rows by name or
/// sub.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Whether the current user has already joined the discover row. We match
  /// on name + emoji since discover rows have no stable id.
  bool _isJoined(String name, String emoji) {
    final isles = ref.read(islesProvider);
    final meId = ref.read(currentUserProvider).id;
    final memberships = ref.read(membershipsProvider);
    for (final isle in isles) {
      if (isle.name == name && isle.emoji == emoji) {
        final members = memberships[isle.id] ?? const <Membership>[];
        if (members.any((m) => m.userId == meId)) return true;
      }
    }
    return false;
  }

  void _join(Map<String, dynamic> row) {
    // The isle already exists in Supabase (it's a public listing).
    // We just need to add a membership for the current user.
    final me = ref.read(currentUserProvider);
    final now = DateTime.now();
    final isleId = row['id'] as String;
    ref.read(membershipsProvider.notifier).addMember(
          isleId,
          Membership(
            isleId: isleId,
            userId: Supabase.instance.client.auth.currentUser?.id ?? me.id,
            userName: me.name,
            userAvatar: me.avatar,
            role: 'member',
            joinedAt: now,
          ),
        );
    setState(() {});
  }

  void _leave(String name, String emoji) {
    final isles = ref.read(islesProvider);
    final meId = ref.read(currentUserProvider).id;
    for (final isle in isles) {
      if (isle.name == name && isle.emoji == emoji) {
        final members =
            ref.read(membershipsProvider)[isle.id] ?? const <Membership>[];
        if (members.any((m) => m.userId == meId)) {
          ref.read(membershipsProvider.notifier).removeMember(isle.id, meId);
        }
      }
    }
    setState(() {}); // refresh Joined → Join
  }

  @override
  Widget build(BuildContext context) {
    final discover = MockData.instance.discover;
    final q = _query.toLowerCase().trim();
    final rows = discover.where((row) {
      if (q.isEmpty) return true;
      final name = (row['name'] as String).toLowerCase();
      final sub = (row['sub'] as String).toLowerCase();
      return name.contains(q) || sub.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/isles'),
        ),
        title: const Text('Discover'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          // Search field.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFECEFF2)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search,
                      size: 20, color: Color(0xFF94A3B8)),
                  hintText: 'Search Isles',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text('No Isles match your search',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            )
          else
            for (int i = 0; i < rows.length; i++) ...[
              _DiscoverRow(
                row: rows[i],
                joined: _isJoined(rows[i]['name'] as String,
                    rows[i]['emoji'] as String),
                onJoin: () => _join(rows[i]),
                onLeave: () => _leave(rows[i]['name'] as String,
                    rows[i]['emoji'] as String),
              ),
              if (i < rows.length - 1) const SizedBox(height: 10),
            ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// A single discoverable Isle row — skewed tinted emoji tile, name,
/// sub-description, member count, and a Join/Joined button.
class _DiscoverRow extends StatelessWidget {
  const _DiscoverRow({
    required this.row,
    required this.joined,
    required this.onJoin,
    required this.onLeave,
  });

  final Map<String, dynamic> row;
  final bool joined;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final emoji = row['emoji'] as String;
    final name = row['name'] as String;
    final sub = row['sub'] as String;
    final members = row['members'] as int;
    final color = _isleColor(row['color'] as String);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECEFF2)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        child: Row(children: [
          _SkewedEmojiTile(emoji: emoji, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('$members members',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _JoinButton(joined: joined, color: color, onTap: onJoin, onLeave: onLeave),
        ]),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.joined,
    required this.color,
    required this.onTap,
    required this.onLeave,
  });

  final bool joined;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: joined ? onLeave : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: joined ? const Color(0xFFEFF3F8) : color,
          borderRadius: BorderRadius.circular(10),
          border: joined
              ? Border.all(color: const Color(0xFFECEFF2))
              : null,
        ),
        child: Text(
          joined ? 'Joined' : 'Join',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: joined ? const Color(0xFF64748B) : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A skewed parallelogram tile tinted with [color], holding [emoji]
/// (counter-skewed upright). Matches the Spark skew idiom.
class _SkewedEmojiTile extends StatelessWidget {
  const _SkewedEmojiTile({required this.emoji, required this.color});
  final String emoji;
  final Color color;
  static const _skew = -0.244;
  static const _counter = 0.244;

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(_skew),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child:
                Text(emoji, style: const TextStyle(fontSize: 23, height: 1)),
          ),
        ),
      ),
    );
  }
}

Color _isleColor(String name) => switch (name) {
      'blue' => const Color(0xFF3B82F6),
      'green' => const Color(0xFF10B981),
      'amber' => const Color(0xFFF59E0B),
      'violet' => const Color(0xFF8B5CF6),
      'rose' => const Color(0xFFF472B6),
      'teal' => const Color(0xFF14B8A6),
      'orange' => const Color(0xFFF97316),
      'indigo' => const Color(0xFF6366F1),
      _ => const Color(0xFF3B82F6),
    };
