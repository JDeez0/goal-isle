import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../app/widgets/spark_widget.dart';

/// League / Streaks — the bottom-nav tab that ranks each Isle's members by
/// streak. A horizontal row of isle chips (mini spark + first word of the name)
/// is the single way to switch Isle; below it, the selected Isle's members are
/// ranked by their share of the Isle's best lit spark streak.
///
/// Per Language Principle: no "ritual"/"spark" words in UI copy.
class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  /// The currently selected Isle id. Defaults to the first Isle.
  String? _currentIsleId;

  @override
  Widget build(BuildContext context) {
    final isles = ref.watch(islesProvider);
    final memberships = ref.watch(membershipsProvider);
    final meId = ref.watch(currentUserProvider).id;

    // Resolve the selected Isle, falling back to the first id once.
    if (_currentIsleId == null && isles.isNotEmpty) {
      _currentIsleId = isles.first.id;
    }
    final selectedId = _currentIsleId;
    final selected = isles.where((i) => i.id == selectedId).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: isles.isEmpty || selected == null
            ? const _EmptyState(text: 'no streaks yet')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Isle chips — the single way to switch Isle.
                  _IsleChipRow(
                    isles: isles,
                    selectedId: selected.id,
                    onTap: (id) => setState(() => _currentIsleId = id),
                  ),
                  const SizedBox(height: 18),
                  // Selected Isle's name as a bold title.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      selected.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Ranked members.
                  Expanded(
                    child: _RankedList(
                      isle: selected,
                      members: memberships[selected.id] ?? const <Membership>[],
                      meId: meId,
                      accent: _isleColor(selected.color),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The horizontal, scrollable row of Isle chips. Each chip is a mini spark plus
/// the first word of the Isle's name; the selected chip is highlighted.
class _IsleChipRow extends StatelessWidget {
  const _IsleChipRow({
    required this.isles,
    required this.selectedId,
    required this.onTap,
  });

  final List<Isle> isles;
  final String selectedId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: isles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isle = isles[i];
          final selected = isle.id == selectedId;
          return _IsleChip(
            isle: isle,
            selected: selected,
            onTap: () => onTap(isle.id),
          );
        },
      ),
    );
  }
}

class _IsleChip extends StatelessWidget {
  const _IsleChip({
    required this.isle,
    required this.selected,
    required this.onTap,
  });

  final Isle isle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _isleColor(isle.color);
    // First word of the Isle's name only — no full words, no menu button.
    final label = isle.name.split(RegExp(r'\s+')).first;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : const Color(0xFFECEFF2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SparkWidget(
              emoji: isle.emoji,
              state: _faceState(isle),
              size: 36,
              showSparkles: false,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? accent : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SparkState _faceState(Isle isle) {
    final main = isle.sparks.where((s) => s.isMain).firstOrNull;
    return main?.state ?? SparkState.dull;
  }
}

/// The ranked list of members for the selected Isle.
class _RankedList extends StatelessWidget {
  const _RankedList({
    required this.isle,
    required this.members,
    required this.meId,
    required this.accent,
  });

  final Isle isle;
  final List<Membership> members;
  final String meId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const _EmptyState(text: 'no streaks yet');
    }

    final ranked = _ranking(isle, members, meId);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: ranked.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final rank = i + 1;
        final entry = ranked[i];
        return _RankRow(
          rank: rank,
          name: entry.name,
          avatar: entry.avatar,
          streak: entry.streak,
          isMe: entry.userId == meId,
          isTop: rank == 1,
          accent: accent,
        );
      },
    );
  }

  /// Derive a per-member streak share, then sort descending.
  ///
  /// Base = the Isle's best lit spark streak. The creator (index 0 in the
  /// members list) keeps the full base; every other member at [index] gets a
  /// deterministic fraction `1 - index*0.18 - 0.05` (floored at 0).
  List<_Rank> _ranking(Isle isle, List<Membership> members, String meId) {
    final base = _bestLitStreak(isle);
    final out = <_Rank>[];
    for (var i = 0; i < members.length; i++) {
      final m = members[i];
      final isCreator = m.role == 'creator' || i == 0;
      final fraction = isCreator ? 1.0 : (1 - i * 0.18 - 0.05).clamp(0.0, 1.0);
      final streak = (base * fraction).round();
      out.add(_Rank(
        userId: m.userId,
        name: m.userId == meId ? 'You' : m.userName,
        avatar: m.userAvatar,
        streak: streak,
      ));
    }
    out.sort((a, b) => b.streak.compareTo(a.streak));
    return out;
  }

  /// The highest streak among the Isle's lit sparks (lit or streaked).
  int _bestLitStreak(Isle isle) {
    int best = 0;
    for (final s in isle.sparks) {
      final lit = s.state == SparkState.lit || s.state == SparkState.streaked;
      if (lit && s.streak > best) best = s.streak;
    }
    return best;
  }
}

/// A single ranked row: rank number, avatar, name, flame + streak number.
class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.streak,
    required this.isMe,
    required this.isTop,
    required this.accent,
  });

  final int rank;
  final String name;
  final String avatar;
  final int streak;
  final bool isMe;
  final bool isTop;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? accent.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? accent.withValues(alpha: 0.5)
              : isTop
                  ? accent.withValues(alpha: 0.35)
                  : const Color(0xFFECEFF2),
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number (gold-ish crown styling for #1).
          SizedBox(
            width: 30,
            child: isTop
                ? const Center(
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 20, height: 1),
                    ),
                  )
                : Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Avatar.
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              shape: BoxShape.circle,
              border: isTop
                  ? Border.all(color: accent.withValues(alpha: 0.6), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          // Name.
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isMe || isTop ? FontWeight.w700 : FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Flame + streak number.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 3),
              Text(
                '$streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isTop ? accent : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
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

/// One ranked member entry.
class _Rank {
  const _Rank({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.streak,
  });

  final String userId;
  final String name;
  final String avatar;
  final int streak;
}

/// Isle color swatches (mirrors home_screen.dart's _isleColor).
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
