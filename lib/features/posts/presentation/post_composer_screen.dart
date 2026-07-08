import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/models/post.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Post Composer — write a one-off broadcast to one or more of your Isles.
///
/// AppBar: Cancel (→ /) + Post (disabled until there's content AND an audience).
/// Body: a multiline text area, a dashed photo slot (toggles a mock gradient
/// placeholder — no real camera yet), and a "To" audience picker listing
/// "All your Isles" plus each Isle with its member count. Posting creates a
/// [Post] and appends it to every selected Isle's feed, then routes to /notes.
class PostComposerScreen extends ConsumerStatefulWidget {
  const PostComposerScreen({super.key});

  @override
  ConsumerState<PostComposerScreen> createState() =>
      _PostComposerScreenState();
}

class _PostComposerScreenState extends ConsumerState<PostComposerScreen> {
  final _textCtrl = TextEditingController();
  bool _hasImage = false;
  bool _allIsles = true; // "All your Isles" selected by default
  final Set<String> _selectedIsleIds = {};

  /// Sentinel used as the audience when broadcasting to every Isle.
  static const _kAllAudience = 'all';

  /// The current user's Isles (only Isles they're a member of).
  List<Isle> _myIsles(WidgetRef ref) {
    final isles = ref.watch(islesProvider);
    final memberships = ref.watch(membershipsProvider);
    final meId = ref.watch(currentUserProvider).id;
    return isles.where((isle) {
      final members = memberships[isle.id] ?? const <Membership>[];
      return members.any((m) => m.userId == meId);
    }).toList();
  }

  bool get _hasContent =>
      _textCtrl.text.trim().isNotEmpty || _hasImage;

  bool get _hasAudience => _allIsles || _selectedIsleIds.isNotEmpty;

  bool get _canPost => _hasContent && _hasAudience;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _textCtrl.clear();
      _hasImage = false;
      _allIsles = true;
      _selectedIsleIds.clear();
    });
  }

  void _post() {
    if (!_canPost) return;
    final me = ref.read(currentUserProvider);
    final now = DateTime.now();
    final post = Post(
      id: 'p-${now.millisecondsSinceEpoch}',
      authorId: currentAuthId() ?? me.id,
      authorName: me.name,
      authorAvatar: me.avatar,
      text: _textCtrl.text.trim().isEmpty ? null : _textCtrl.text.trim(),
      emoji: null,
      imageUrl: _hasImage
          ? 'https://picsum.photos/seed/post-${now.millisecondsSinceEpoch}/280/120'
          : null,
      audience: _allIsles ? const [_kAllAudience] : _selectedIsleIds.toList(),
      createdAt: now,
    );
    final targets = _allIsles ? _myIsles(ref) : ref
        .read(islesProvider)
        .where((i) => _selectedIsleIds.contains(i.id))
        .toList();
    final notifier = ref.read(islesProvider.notifier);
    for (final isle in targets) {
      notifier.addPost(isle.id, post);
    }
    _reset();
    context.go('/notes');
  }

  void _toggleIsle(String isleId) {
    setState(() {
      // Selecting an individual Isle turns off "all".
      _allIsles = false;
      if (_selectedIsleIds.contains(isleId)) {
        _selectedIsleIds.remove(isleId);
      } else {
        _selectedIsleIds.add(isleId);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      _allIsles = !_allIsles;
      // Clear individual picks when switching to all (and vice-versa is
      // handled by _toggleIsle turning all off).
      _selectedIsleIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myIsles = _myIsles(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.go('/'),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
          ),
        ),
        title: const Text('Post'),
        actions: [
          TextButton(
            onPressed: _canPost ? _post : null,
            child: Text(
              'Post',
              style: TextStyle(
                color: _canPost
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFCBD5E1),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Compose area — text + photo slot.
          _Panel(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: TextField(
                controller: _textCtrl,
                onChanged: (_) => setState(() {}),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, height: 1.4),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '...',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_hasImage) ...[
              const Divider(height: 1, color: Color(0xFFECEFF2)),
              _PhotoSlot(
                hasImage: true,
                onTap: () => setState(() => _hasImage = !_hasImage),
              ),
            ] else ...[
              const Divider(height: 1, color: Color(0xFFECEFF2)),
              _PhotoSlot(
                hasImage: false,
                onTap: () => setState(() => _hasImage = !_hasImage),
              ),
            ],
          ]),

          const SizedBox(height: 24),

          // Audience picker.
          const _SectionLabel('To'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(
            children: [
              _AudienceRow(
                emoji: '📢',
                title: 'All your Isles',
                subtitle: 'Broadcast everywhere',
                selected: _allIsles,
                onTap: _toggleAll,
              ),
              for (int i = 0; i < myIsles.length; i++) ...[
                const Divider(height: 1, color: Color(0xFFECEFF2)),
                _AudienceRow(
                  emoji: myIsles[i].emoji,
                  title: myIsles[i].name,
                  subtitle:
                      '${_memberCount(ref, myIsles[i].id)} members',
                  selected: !_allIsles &&
                      _selectedIsleIds.contains(myIsles[i].id),
                  onTap: () => _toggleIsle(myIsles[i].id),
                  color: _isleColor(myIsles[i].color),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  int _memberCount(WidgetRef ref, String isleId) {
    final memberships = ref.watch(membershipsProvider);
    return (memberships[isleId] ?? const <Membership>[]).length;
  }
}

/// A single audience picker row — emoji + title + subtitle, with a check mark
/// when selected. [color] tints the emoji tile (defaults to neutral slate).
class _AudienceRow extends StatelessWidget {
  const _AudienceRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? const Color(0xFF64748B);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Row(children: [
            _EmojiTile(emoji: emoji, color: tileColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: Color(0xFF3B82F6)),
          ]),
        ),
      ),
    );
  }
}

/// Small skewed parallelogram tile tinted with [color], holding [emoji]
/// (counter-skewed upright). Matches the Spark skew idiom.
class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.emoji, required this.color});
  final String emoji;
  final Color color;
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
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child:
                Text(emoji, style: const TextStyle(fontSize: 21, height: 1)),
          ),
        ),
      ),
    );
  }
}

/// Photo slot — a dashed-border placeholder when empty; a mock gradient
/// "image" (tap to remove) when toggled on. No real camera yet.
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.hasImage, required this.onTap});
  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Remove',
                            style:
                                TextStyle(fontSize: 11, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              )
            : DottedBorder(
                color: const Color(0xFFCBD5E1),
                child: Container(
                  height: 84,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 20, color: Color(0xFF94A3B8)),
                      SizedBox(width: 8),
                      Text('Add a photo',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// A simple dashed border wrapper (no extra deps).
class DottedBorder extends StatelessWidget {
  const DottedBorder({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color;
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
