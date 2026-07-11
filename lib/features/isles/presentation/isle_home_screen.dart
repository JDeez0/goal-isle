import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/widgets/spark_widget.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/models/message.dart';
import '../../../core/models/post.dart';
import '../../../core/models/spark.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/utils/debug_label.dart';

/// Isle Home — drill-in for a single Isle. Header (emoji, name, purpose,
/// member count), the list of Keys sorted lit-first/greyed-last, a chat
/// preview row, and the activity feed.
class IsleHomeScreen extends ConsumerWidget {
  const IsleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activeIsleIdProvider);
    final isles = ref.watch(islesProvider);
    final isle = isles.where((i) => i.id == activeId).firstOrNull;

    if (isle == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/'),
          ).labeled('IH-00'),
        ),
        body: const Center(
          child: Text('Isle not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ).labeled('IH-00-err'),
      );
    }

    final memberships = ref.watch(membershipsProvider);
    final members = memberships[isle.id] ?? const <Membership>[];
    final meId = ref.watch(currentUserProvider).id;
    final isCreator =
        members.any((m) => m.userId == meId && m.role == 'creator');

    // Keys: lit/streaked first, then dull, then greyed last.
    final sortedSparks = [...isle.sparks]..sort((a, b) =>
        _stateRank(a.state).compareTo(_stateRank(b.state)));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/'),
        ).labeled('IH-01'),
        title: Text(isle.name).labeled('IH-02'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
            onPressed: () {
              ref.read(activeIsleIdProvider.notifier).state = isle.id;
              context.go('/create');
            },
          ).labeled('IH-03'),
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF3B82F6)),
              onPressed: () => context.go('/isle-settings'),
            ).labeled('IH-04'),
        ],
      ),
      body: ListView(
        children: [
          _IsleHeader(
            isle: isle,
            memberCount: members.length,
            onMembersTap: () => _showMembersModal(context, members, isle),
          ).labeled('IH-05'),
          const SizedBox(height: 8),
          // Keys list.
          _SectionLabel('Keys (${sortedSparks.length})').labeled('IH-06'),
          const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IH-07'),
          _Panel(
            children: sortedSparks.isEmpty
                ? [const _EmptyRow('No keys yet.').labeled('IH-09')]
                : [
                    for (int i = 0; i < sortedSparks.length; i++) ...[
                      _KeyRow(spark: sortedSparks[i]).labeled('IH-09-${i + 1}'),
                      if (i < sortedSparks.length - 1)
                        const Divider(height: 1, color: Color(0xFFECEFF2)),
                    ],
                  ],
          ).labeled('IH-08'),
          // Chat preview (only if there are messages).
          if (isle.msgs.isNotEmpty) ...[
            const SizedBox(height: 24),
            _Panel(children: [
              _ChatPreviewRow(
                last: isle.msgs.last,
                onTap: () => context.go('/chat'),
              ).labeled('IH-10'),
            ]).labeled('IH-11'),
          ],
          // Activity feed.
          if (isle.posts.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionLabel('Activity').labeled('IH-12'),
            const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IH-13'),
            _Panel(
              children: [
                for (int i = 0; i < isle.posts.length; i++) ...[
                  _PostRow(post: isle.posts[i]).labeled('IH-14-${i + 1}'),
                  if (i < isle.posts.length - 1)
                    const Divider(height: 1, color: Color(0xFFECEFF2)),
                ],
              ],
            ).labeled('IH-15'),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showMembersModal(
      BuildContext context, List<Membership> members, Isle isle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${isle.name} · ${members.length} members',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ).labeled('IH-modal-title'),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFECEFF2)).labeled('IH-modal-divider'),
              for (int i = 0; i < members.length; i++)
                DebugLabel(
                  label: 'IH-modal-${i + 1}',
                  child: ListTile(
                    leading: Text(members[i].userAvatar,
                        style: const TextStyle(fontSize: 22)),
                    title: Text(members[i].userName,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      members[i].role == 'creator' ? 'Creator' : 'Member',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lit/streaked rank first (0), dull next (1), greyed last (2).
  int _stateRank(SparkState s) => switch (s) {
        SparkState.lit => 0,
        SparkState.streaked => 0,
        SparkState.dull => 1,
        SparkState.greyed => 2,
      };
}

/// Isle header — skewed emoji tile, name, purpose, member count.
class _IsleHeader extends StatelessWidget {
  const _IsleHeader({
    required this.isle,
    required this.memberCount,
    required this.onMembersTap,
  });
  final Isle isle;
  final int memberCount;
  final VoidCallback onMembersTap;

  @override
  Widget build(BuildContext context) {
    final color = _isleColor(isle.color);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Row(children: [
        _SkewedEmojiTile(emoji: isle.emoji, color: color).labeled('IH-05-1'),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isle.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)).labeled('IH-05-2'),
              if (isle.purpose != null && isle.purpose!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(isle.purpose!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF94A3B8))).labeled('IH-05-3'),
              ],
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onMembersTap,
                child: Text(
                  '$memberCount members',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ).labeled('IH-05-4'),
            ],
          ),
        ),
      ]),
    );
  }
}

/// A single Key row — small SparkWidget, title + timer pill, sub-status,
/// and the streak flame + number.
class _KeyRow extends ConsumerWidget {
  const _KeyRow({required this.spark});
  final Spark spark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(activeSparkIdProvider.notifier).state = spark.id;
          context.go('/spark');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            SparkWidget(
              emoji: spark.emoji,
              state: spark.state,
              size: 48,
              streak: spark.state == SparkState.lit ||
                      spark.state == SparkState.streaked
                  ? spark.streak
                  : null,
            ).labeled('IH-09-k-1'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(
                        spark.title ?? 'Untitled key',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).labeled('IH-09-k-2'),
                    const SizedBox(width: 8),
                    _TimerPill(mode: spark.timerMode).labeled('IH-09-k-3'),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    _subStatus(spark.state),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ).labeled('IH-09-k-4'),
                ],
              ),
            ),
            if (spark.streak > 0) ...[
              const SizedBox(width: 6),
              _StreakFlame(streak: spark.streak).labeled('IH-09-k-5'),
            ],
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFF94A3B8)).labeled('IH-09-k-6'),
          ]),
        ),
      ),
    );
  }

  String _subStatus(SparkState state) => switch (state) {
        SparkState.lit => 'done',
        SparkState.streaked => 'done',
        SparkState.greyed => 'missed',
        SparkState.dull => 'not yet',
      };
}

class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.streak});
  final int streak;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 13)).labeled('IH-flame'),
        const SizedBox(width: 2),
        Text('$streak',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF97316))).labeled('IH-streak'),
      ],
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.mode});
  final TimerMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mode.name,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B)),
      ).labeled('IH-timer'),
    );
  }
}

class _ChatPreviewRow extends StatelessWidget {
  const _ChatPreviewRow({required this.last, required this.onTap});
  final Message last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = last.big ?? last.content ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(children: [
            const Icon(Icons.chat_bubble_outline,
                size: 20, color: Color(0xFF64748B)).labeled('IH-chat-icon'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${last.senderName}:',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)).labeled('IH-chat-sender'),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748B))).labeled('IH-chat-preview'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFF94A3B8)).labeled('IH-chat-chevron'),
          ]),
        ),
      ),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final hasEmoji = post.emoji != null && post.emoji!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
        Text(post.authorAvatar, style: const TextStyle(fontSize: 22)).labeled('IH-post-avatar'),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${post.authorName} posted',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)).labeled('IH-post-name'),
              if (post.text != null && post.text!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(post.text!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1F2937)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis).labeled('IH-post-text'),
              ],
              const SizedBox(height: 2),
              Text(_timeAgo(post.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8))).labeled('IH-post-time'),
            ],
          ),
        ),
        if (hasEmoji)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(post.emoji!,
                style: const TextStyle(fontSize: 28, height: 1)).labeled('IH-post-emoji'),
          ),
      ]),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'just now';
  }
}

class _SkewedEmojiTile extends StatelessWidget {
  const _SkewedEmojiTile({required this.emoji, required this.color});
  final String emoji;
  final Color color;
  static const _skew = -0.244;
  static const _counter = 0.244;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(_skew),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child:
                Text(emoji, style: const TextStyle(fontSize: 29, height: 1)).labeled('IH-tile-emoji'),
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF94A3B8)),
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
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          textAlign: TextAlign.center),
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
