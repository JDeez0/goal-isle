import 'package:flutter/material.dart';

/// Wraps any widget with a tiny, unobtrusive identification label in the
/// top-left corner. Labels use a screen-code + element-number scheme
/// (e.g. "H-03", "CI-07") so every UI element can be precisely referenced.
///
/// Labels are rendered at 8px in a faint semi-transparent gray that is
/// barely visible during normal use but legible when you look for it.
class DebugLabel extends StatelessWidget {
  const DebugLabel({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  static const _labelStyle = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w400,
    color: Color(0x354B5563), // ~21% gray-600 — faint but findable
    height: 1,
    letterSpacing: 0.3,
    fontFamily: 'monospace',
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: Text(label, style: _labelStyle),
          ),
        ),
      ],
    );
  }
}

/// Convenience shorthand for adding a debug label without wrapping in
/// DebugLabel constructor boilerplate.
extension DebugLabelExtension on Widget {
  /// Attaches a debug label overlay to this widget.
  Widget labeled(String label) => DebugLabel(label: label, child: this);
}