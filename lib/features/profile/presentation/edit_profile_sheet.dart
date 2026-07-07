import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/mock/mock_providers.dart';

/// Edit Profile — bottom sheet with avatar picker, name, handle, bio.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _handleCtrl;
  late TextEditingController _bioCtrl;
  String _avatar = '';
  bool _showAvatarPicker = false;

  static const _avatars = [
    '🧑', '🧑‍🦰', '🧑‍🦱', '🧑‍🦲', '👩', '👨', '🧑‍🦳',
    '👩‍🦰', '👨‍🦰', '👩‍🦱', '🧑‍🎤', '🧑‍🎨', '🦸', '🧙',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user.name);
    _handleCtrl = TextEditingController(text: user.handle);
    _bioCtrl = TextEditingController(text: user.bio ?? '');
    _avatar = user.avatar;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    ref.read(currentUserProvider.notifier).updateUser(
          user.copyWith(
            name: _nameCtrl.text.trim(),
            handle: _handleCtrl.text.trim().replaceFirst('@', ''),
            bio: _bioCtrl.text.trim(),
            avatar: _avatar,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Edit',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          // Avatar slot
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _showAvatarPicker = !_showAvatarPicker),
              child: Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: Color(0x243B82F6), shape: BoxShape.circle),
                child: Center(
                  child: Text(_avatar, style: const TextStyle(fontSize: 34)),
                ),
              ),
            ),
          ),
          if (_showAvatarPicker) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
              children: _avatars.map((e) => GestureDetector(
                onTap: () => setState(() { _avatar = e; _showAvatarPicker = false; }),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _avatar == e ? const Color(0x243B82F6) : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 14),
          _Field(controller: _nameCtrl, hint: 'Name'),
          const SizedBox(height: 8),
          _Field(controller: _handleCtrl, hint: '@handle'),
          const SizedBox(height: 8),
          _Field(controller: _bioCtrl, hint: 'Bio (optional)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFECEFF2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
    );
  }
}
