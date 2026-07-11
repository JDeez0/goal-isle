import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/isle.dart';
import '../../../core/models/membership.dart';
import '../../../core/repositories/mock/mock_providers.dart';
import '../../../core/utils/debug_label.dart';

/// Isle Settings — members, color, visibility, and danger (delete/leave).
/// Creator-only rows (color, visibility, delete) are hidden for plain members.
class IsleSettingsScreen extends ConsumerWidget {
  const IsleSettingsScreen({super.key});

  static const _colors = <String>[
    'blue', 'green', 'amber', 'violet', 'rose', 'teal', 'orange', 'indigo',
  ];

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
            onPressed: () => context.go('/isle'),
          ).labeled('IS-00'),
          title: const Text('Settings').labeled('IS-00-title'),
        ),
        body: const Center(
          child: Text('Isle not found',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ).labeled('IS-00-err'),
      );
    }

    final memberships = ref.watch(membershipsProvider);
    final members = memberships[isle.id] ?? const <Membership>[];
    final meId = ref.watch(currentUserProvider).id;
    final myMembership =
        members.where((m) => m.userId == meId).firstOrNull;
    final isCreator =
        myMembership != null && myMembership.role == 'creator';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/isle'),
        ).labeled('IS-01'),
        title: const Text('Settings').labeled('IS-02'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // Members section.
          _SectionLabel('Members (${members.length})').labeled('IS-03'),
          const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IS-04'),
          _Panel(children: [
            _SettingsRow(
              icon: Icons.group_outlined,
              label: 'Members',
              value: '${members.length}',
              showChevron: true,
              onTap: () => _showMembersModal(
                  context, isle, members, isCreator, meId, ref),
            ).labeled('IS-06'),
          ]).labeled('IS-05'),

          if (isCreator) ...[
            const SizedBox(height: 24),
            const _SectionLabel('Isle').labeled('IS-07'),
            const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IS-08'),
            _Panel(children: [
              _SettingsRow(
                icon: Icons.palette_outlined,
                label: 'Color',
                trailing: _ColorDot(name: isle.color).labeled('IS-10'),
                showChevron: true,
                onTap: () => _showColorModal(context, isle, ref),
              ).labeled('IS-09'),
              const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IS-11'),
              _SettingsRow(
                icon: isle.visibility == IsleVisibility.private
                    ? Icons.lock_outline
                    : Icons.public,
                label: 'Visibility',
                value: isle.visibility == IsleVisibility.private
                    ? 'Private'
                    : 'Public',
                showChevron: true,
                onTap: () => _toggleVisibility(isle, ref),
              ).labeled('IS-12'),
            ]).labeled('IS-13'),
          ],

          const SizedBox(height: 24),
          _SectionLabel(isCreator ? 'Danger zone' : 'Leave').labeled('IS-14'),
          const Divider(height: 1, color: Color(0xFFECEFF2)).labeled('IS-15'),
          _Panel(children: [
            _DangerRow(
              label: isCreator ? 'Delete Isle' : 'Leave Isle',
              onTap: () => _onDanger(context, isle, isCreator, meId, ref),
            ).labeled('IS-17'),
          ]).labeled('IS-16'),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showMembersModal(BuildContext context, Isle isle,
      List<Membership> members, bool isCreator, String meId, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                ).labeled('IS-modal-title'),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFECEFF2)).labeled('IS-modal-divider'),
              for (int i = 0; i < members.length; i++)
                DebugLabel(
                  label: 'IS-modal-${i + 1}',
                  child: ListTile(
                    leading:
                        Text(members[i].userAvatar, style: const TextStyle(fontSize: 22)),
                    title:
                        Text(members[i].userName, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      members[i].role == 'creator' ? 'Creator' : 'Member',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    trailing: (isCreator &&
                            members[i].role != 'creator' &&
                            members[i].userId != meId)
                        ? TextButton(
                            onPressed: () {
                              ref
                                  .read(membershipsProvider.notifier)
                                  .removeMember(isle.id, members[i].userId);
                              Navigator.of(context).pop();
                              _showMembersModal(
                                  context, isle, ref.read(membershipsProvider)[isle.id] ?? const [], isCreator, meId, ref);
                            },
                            child: const Text('Remove',
                                style: TextStyle(
                                    color: Color(0xFFEF4444), fontSize: 13)),
                          ).labeled('IS-modal-remove')
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorModal(BuildContext context, Isle isle, WidgetRef ref) {
    String picked = isle.color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Color',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)).labeled('IS-color-title'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (int i = 0; i < _colors.length; i++)
                        GestureDetector(
                          onTap: () => setSt(() => picked = _colors[i]),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _isleColor(_colors[i]),
                              borderRadius: BorderRadius.circular(10),
                              border: picked == _colors[i]
                                  ? Border.all(
                                      color: const Color(0xFF1F2937),
                                      width: 2.5)
                                  : null,
                            ),
                          ),
                        ).labeled('IS-color-${i + 1}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(islesProvider.notifier)
                            .updateIsle(isle.copyWith(color: picked));
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ).labeled('IS-color-done'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleVisibility(Isle isle, WidgetRef ref) {
    final next = isle.visibility == IsleVisibility.private
        ? IsleVisibility.public
        : IsleVisibility.private;
    ref
        .read(islesProvider.notifier)
        .updateIsle(isle.copyWith(visibility: next));
  }

  Future<void> _onDanger(BuildContext context, Isle isle, bool isCreator,
      String meId, WidgetRef ref) async {
final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DebugLabel(
        label: 'IS-dialog',
        child: AlertDialog(
          title: Text(isCreator ? 'Delete ${isle.name}?' : 'Leave ${isle.name}?').labeled('IS-dialog-title'),
          content: Text(isCreator
              ? 'This permanently removes the Isle for everyone. This can\'t be undone.'
              : 'You\'ll no longer see this Isle or its keys.').labeled('IS-dialog-content'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ).labeled('IS-dialog-cancel'),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(isCreator ? 'Delete' : 'Leave',
                  style: const TextStyle(color: Color(0xFFEF4444))),
            ).labeled('IS-dialog-confirm'),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    if (isCreator) {
      ref.read(islesProvider.notifier).removeIsle(isle.id);
    } else {
      ref.read(membershipsProvider.notifier).removeMember(isle.id, meId);
    }
    ref.read(activeIsleIdProvider.notifier).state = null;
    if (context.mounted) context.go('/');
  }
}

// ---------------------------------------------------------------------------
// Small reusable chrome — mirrors the _SettingsRow pattern from
// app_settings_screen.dart but lives locally so this screen is self-contained.
// ---------------------------------------------------------------------------

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final IconData? icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: const Color(0xFF64748B)),
              const SizedBox(width: 14),
            ],
            Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null)
              trailing!
            else if (value != null)
              Text(value!,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B))),
            if (showChevron)
              const Icon(Icons.chevron_right,
                  size: 16, color: Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            const Icon(Icons.logout, size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444))),
          ]),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _isleColor(name),
        borderRadius: BorderRadius.circular(5),
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
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, color: Color(0xFFECEFF2)),
            ],
          ],
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
