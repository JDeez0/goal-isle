import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/debug_label.dart';
import '../theme/tokens.dart';

/// Shell that hosts the three bottom-nav branches (Home, Notes, League) and
/// renders the icon-only navigation bar beneath them.
///
/// Drill-in routes (Isles, Spark, Chat, …) are pushed on top of this shell via
/// their own top-level [GoRoute]s, so they don't show the bottom bar.
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  /// The navigation shell provided by [StatefulShellRoute.indexedStack].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell.labeled('BN-01'),
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ).labeled('BN-02'),
    );
  }
}

/// The icon-only bottom nav bar.
///
/// Tabs (left → right): Notes (chat bubble), Home (circle-with-dot), League
/// (trophy). There's a 44px gap between buttons. The active tab uses the accent
/// blue; inactive tabs use the faint slate.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _activeColor = TokenColors.accent; // #3B82F6
  static const _inactiveColor = TokenColors.textTertiary; // #94A3B8

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      _NavButton(
        icon: Icons.chat_bubble_outline,
        label: 'Notes',
        active: currentIndex == 0,
        onTap: () => onTap(0),
      ),
      _NavButton(
        icon: Icons.radio_button_checked,
        label: 'Home',
        active: currentIndex == 1,
        onTap: () => onTap(1),
      ),
      _NavButton(
        icon: Icons.emoji_events_outlined,
        label: 'League',
        active: currentIndex == 2,
        onTap: () => onTap(2),
      ),
    ];

    // Interleave 44px gaps between the buttons.
    final rowChildren = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      rowChildren.add(buttons[i].labeled('BN-0${i + 3}'));
      if (i < buttons.length - 1) {
        rowChildren.add(const SizedBox(width: 44));
      }
    }

    return SafeArea(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      ),
    );
  }
}

/// A single icon-only navigation button.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _BottomNav._activeColor : _BottomNav._inactiveColor;
    return Semantics(
      label: label,
      button: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
