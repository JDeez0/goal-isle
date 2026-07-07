import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/post.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Notes — a single chronological feed aggregating every post across all of
/// the user's Isles.
///
/// This is a bottom-nav tab (no back button). Each feed item shows the author
/// avatar, a "posted" line, the text, a big emoji (if any), an image (a colored
/// gradient placeholder if `imageUrl` is set), the time, and the Isle name so
/// you know which community it's from. Tapping a post opens that Isle.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isles = ref.watch(islesProvider);

    // Aggregate (post, isle) pairs across all Isles.
    final feed = <MapEntry<Post, Isle>>[
      for (final isle in isles)
        for (final post in isle.posts) MapEntry(post, isle),
    ];
    // Most recent first.
    feed.sort((a, b) => b.key.createdAt.compareTo(a.key.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: feed.isEmpty
          ? const Center(
              child: Text(
                'no posts yet',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: feed.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final entry = feed[i];
                return _FeedCard(
                  post: entry.key,
                  isle: entry.value,
                  onTap: () {
                    ref.read(activeIsleIdProvider.notifier).state =
                        entry.value.id;
                    context.go('/isle');
                  },
                );
              },
            ),
    );
  }
}

/// A single feed card — author avatar + "posted" line, optional big emoji,
/// optional image (gradient placeholder), the post text, time, and an Isle
/// name label so you know which community it's from.
class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.post, required this.isle, required this.onTap});

  final Post post;
  final Isle isle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasEmoji = post.emoji != null && post.emoji!.isNotEmpty;
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasText = post.text != null && post.text!.isNotEmpty;
    final isleColor = _isleColor(isle.color);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEFF2)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header — avatar + "posted" + Isle label + big emoji.
              Row(children: [
                Text(post.authorAvatar, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${post.authorName} posted',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 2),
                      // Isle label — tinted with the Isle's color.
                      Row(children: [
                        Text(isle.emoji,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(isle.name,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isleColor)),
                      ]),
                    ],
                  ),
                ),
                if (hasEmoji)
                  Text(post.emoji!,
                      style: const TextStyle(fontSize: 30, height: 1)),
              ]),
              // Text body.
              if (hasText) ...[
                const SizedBox(height: 10),
                Text(post.text!,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1F2937), height: 1.4)),
              ],
              // Image — colored gradient placeholder.
              if (hasImage) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isleColor,
                          isleColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(_timeAgo(post.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
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
