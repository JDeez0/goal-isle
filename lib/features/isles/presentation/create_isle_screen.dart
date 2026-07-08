import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Create Isle — pick an emoji, name, purpose, color, and visibility,
/// then create the Isle, become its creator, and drill into it.
class CreateIsleScreen extends ConsumerStatefulWidget {
  const CreateIsleScreen({super.key});

  @override
  ConsumerState<CreateIsleScreen> createState() => _CreateIsleScreenState();
}

class _CreateIsleScreenState extends ConsumerState<CreateIsleScreen> {
  static const _emojiPool = <String>[
    '📈', '🏃', '🎓', '📖', '🧘', '🎨', '🎸', '🎯', '⚖️', '📝', '🌱', '🔥',
  ];
  static const _colors = <String>[
    'blue', 'green', 'amber', 'violet', 'rose', 'teal', 'orange', 'indigo',
  ];

  int _emojiIdx = 0;
  final _nameCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  String _color = 'blue';
  IsleVisibility _visibility = IsleVisibility.private;

  bool get _canCreate =>
      _nameCtrl.text.trim().isNotEmpty && _emojiPool[_emojiIdx].isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _emojiIdx = 0;
      _nameCtrl.clear();
      _purposeCtrl.clear();
      _color = 'blue';
      _visibility = IsleVisibility.private;
    });
  }

  void _create() {
    if (!_canCreate) return;
    final me = ref.read(currentUserProvider);
    // Use the real Supabase auth UUID (not the mock ID)
    final authId = Supabase.instance.client.auth.currentUser?.id ?? me.id;
    final now = DateTime.now();
    final id = 'is-${now.millisecondsSinceEpoch}';
    final isle = Isle(
      id: id,
      name: _nameCtrl.text.trim(),
      emoji: _emojiPool[_emojiIdx],
      purpose:
          _purposeCtrl.text.trim().isEmpty ? null : _purposeCtrl.text.trim(),
      color: _color,
      visibility: _visibility,
      createdBy: authId,
      createdAt: now,
    );
    // addIsle/createIsle inserts the isle AND the creator's membership
    // (with the real Supabase UUID). No separate addMember call needed.
    ref.read(islesProvider.notifier).addIsle(isle);
    ref.read(activeIsleIdProvider.notifier).state = id;
    _reset();
    context.go('/isle');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.go('/isles'),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
          ),
        ),
        title: const Text('New Isle'),
        actions: [
          TextButton(
            onPressed: _canCreate ? _create : null,
            child: Text(
              'Create',
              style: TextStyle(
                color: _canCreate
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
          // Isle section — skewed mini-spark slot + name + purpose.
          const _SectionLabel('Isle'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: () => setState(
                      () => _emojiIdx = (_emojiIdx + 1) % _emojiPool.length),
                  child: _SkewedEmojiSlot(emoji: _emojiPool[_emojiIdx]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap to cycle emoji',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Isle name',
                          hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: TextField(
                controller: _purposeCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Purpose (optional)',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Color row.
          const _SectionLabel('Color'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in _colors)
                    _ColorSwatch(
                      name: c,
                      selected: _color == c,
                      onTap: () => setState(() => _color = c),
                    ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Visibility.
          const _SectionLabel('Visibility'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _Panel(children: [
            _VisibilityRow(
              icon: Icons.lock_outline,
              title: 'Private',
              subtitle: 'Invite only',
              selected: _visibility == IsleVisibility.private,
              onTap: () => setState(
                  () => _visibility = IsleVisibility.private),
            ),
            const Divider(height: 1, color: Color(0xFFECEFF2)),
            _VisibilityRow(
              icon: Icons.public,
              title: 'Public',
              subtitle: 'Discoverable',
              selected: _visibility == IsleVisibility.public,
              onTap: () => setState(
                  () => _visibility = IsleVisibility.public),
            ),
          ]),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _canCreate ? _create : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Isle',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A skewed mini-spark slot showing the current emoji.
class _SkewedEmojiSlot extends StatelessWidget {
  const _SkewedEmojiSlot({required this.emoji});
  final String emoji;
  static const _skew = -0.244;
  static const _counter = 0.244;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(_skew),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFF4F6F8),
          border: Border.all(color: const Color(0xFFECEFF2)),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_counter),
          child: Center(
            child:
                Text(emoji, style: const TextStyle(fontSize: 26, height: 1)),
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.name,
    required this.selected,
    required this.onTap,
  });
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _isleColor(name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          border: selected
              ? Border.all(color: const Color(0xFF1F2937), width: 2.5)
              : null,
        ),
      ),
    );
  }
}

class _VisibilityRow extends StatelessWidget {
  const _VisibilityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 14),
            Column(
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
            const Spacer(),
            if (selected)
              const Icon(Icons.check, size: 18, color: Color(0xFF3B82F6)),
          ]),
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
