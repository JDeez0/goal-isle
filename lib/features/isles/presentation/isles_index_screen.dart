import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/utils/debug_label.dart';

/// Your Isles — the index of every Isle the current user belongs to.
/// Lists each Isle in a settings-style panel (mini skewed hero + name +
/// chevron), then a "Find more" section with a Discover row.
class IslesIndexScreen extends ConsumerWidget {
  const IslesIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isles = ref.watch(islesProvider);
    final memberships = ref.watch(membershipsProvider);
    final meId = ref.watch(currentUserProvider).id;

    // Isles the current user actually belongs to.
    final myIsles = isles.where((isle) {
      final members = memberships[isle.id] ?? const <Membership>[];
      return members.any((m) => m.userId == meId);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/'),
        ).labeled('II-01'),
        title: const Text('Your Isles').labeled('II-02'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/create-isle'),
          ).labeled('II-03'),
        ],
      ),
body: ListView(
        children: [
          const SizedBox(height: 12),
          _SectionLabel('Isles (${myIsles.length})').labeled('II-04'),
          const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('II-05'),
          DebugLabel(
            label: 'II-06',
            child: _SettingsPanel(
              children: myIsles.isEmpty
                  ? [const _EmptyRow('You haven\'t joined any Isles yet.').labeled('II-07')]
                  : [
                      for (int i = 0; i < myIsles.length; i++) ...[
                        _IsleRow(isle: myIsles[i]).labeled('II-${7 + i}'),
                        if (i < myIsles.length - 1)
                          const Divider(height: 1, color: Color(0xFFECEFF2)),
                      ],
                    ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Find more').labeled('II-08'),
          const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('II-09'),
          _SettingsPanel(children: [
            _DiscoverRow(onTap: () => context.go('/discover')).labeled('II-10'),
          ]).labeled('II-11'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A single Isle row — skewed mini-hero (emoji on a tinted, skewed tile) +
/// name + chevron. Tapping selects the Isle and drills in.
class _IsleRow extends StatelessWidget {
  const _IsleRow({required this.isle});
  final Isle isle;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(activeIsleIdProvider.notifier).state = isle.id;
            context.go('/isle');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(children: [
              _MiniIsleHero(emoji: isle.emoji, color: isle.color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isle.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isle.visibility == IsleVisibility.public)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.public,
                      size: 15, color: Color(0xFF94A3B8)),
                ),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFF94A3B8)),
            ]),
          ),
        ),
      );
    });
  }
}

/// Discover row → /discover.
class _DiscoverRow extends StatelessWidget {
  const _DiscoverRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            Icon(Icons.explore_outlined, size: 20, color: Color(0xFF64748B)),
            SizedBox(width: 14),
            Text('Discover Isles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Spacer(),
            Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }
}

/// A small skewed parallelogram tile tinted with the Isle's color, holding
/// the Isle emoji (counter-skewed upright). Matches the Spark skew idiom.
class _MiniIsleHero extends StatelessWidget {
  const _MiniIsleHero({required this.emoji, required this.color});
  final String emoji;
  final String color;

  static const _skew = -0.244;
  static const _counter = 0.244;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(_skew),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: _isleColor(color).withValues(alpha: 0.16),
          border: Border.all(color: _isleColor(color).withValues(alpha: 0.5)),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child: Text(emoji,
                style: const TextStyle(fontSize: 21, height: 1)),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.children});
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
          children: [for (final c in children) c],
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        textAlign: TextAlign.center,
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
