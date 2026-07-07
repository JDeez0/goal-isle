import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Settings — Display (theme cycle), Notifications toggle, About.
/// Per Language Principle: settings chrome is allowed OS-level vocabulary.
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  int _themeIdx = 0;
  static const _themes = ['Light', 'Dark'];
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionLabel('Display'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _SettingsPanel(children: [
            _SettingsRow(
              icon: Icons.light_mode_outlined,
              label: 'Theme',
              value: _themes[_themeIdx],
              onTap: () => setState(() => _themeIdx = (_themeIdx + 1) % _themes.length),
              showChevron: true,
            ),
          ]),
          const SizedBox(height: 16),
          const _SectionLabel('Notifications'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          _SettingsPanel(children: [
            _SettingsRow(
              icon: Icons.notifications_outlined,
              label: 'Push',
              toggle: _notifications,
              onToggle: (v) => setState(() => _notifications = v),
            ),
          ]),
          const SizedBox(height: 16),
          const _SectionLabel('About'),
          const Divider(height: 1, color: Color(0xFFECEFF2)),
          const _SettingsPanel(children: [
            _SettingsRow(label: 'v2.0 · Flutter', isStatic: true),
          ]),
        ],
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
      child: Text(text,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF94A3B8))),
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
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, color: Color(0xFFECEFF2)),
          ],
        ]),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.toggle,
    this.onToggle,
    this.showChevron = false,
    this.isStatic = false,
  });

  final IconData? icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final bool showChevron;
  final bool isStatic;

  @override
  Widget build(BuildContext context) {
    if (isStatic) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? (onToggle != null ? () => onToggle!(!(toggle!)) : null),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: const Color(0xFF64748B)),
              const SizedBox(width: 14),
            ],
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (value != null)
              Text(value!,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            if (toggle != null) ...[
              const SizedBox(width: 10),
              _Toggle(value: toggle!, onChanged: onToggle),
            ] else if (showChevron)
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42, height: 25,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF3B82F6) : const Color(0xFFECEFF2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: value
              ? const [BoxShadow(color: Color(0x4D3B82F6), blurRadius: 3)]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 19, height: 19,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }
}
