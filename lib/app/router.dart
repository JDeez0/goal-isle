import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/repositories/mock/mock_providers.dart';
import 'bottom_nav.dart';
import 'widgets/placeholder_screen.dart';

/// The GoRouter for the Goal Isle app.
///
/// Watches [authStateProvider] so the auth gate re-evaluates whenever the
/// signed-in flag changes. The shell is a [StatefulShellRoute.indexedStack] so
/// each bottom-nav branch keeps its own navigator/nesting state. Drill-in
/// routes (Isles, Spark, Chat, …) are top-level routes pushed on top of the
/// shell, so they don't render the bottom bar.
final routerProvider = Provider<GoRouter>((ref) {
  // Refresh redirects whenever the signed-in flag changes.
  ref.listen(authStateProvider, (_, __) {});

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final signedIn = ref.read(authStateProvider);
      final goingToAuth = state.matchedLocation == '/auth';
      if (!signedIn && !goingToAuth) return '/auth';
      if (signedIn && goingToAuth) return '/';
      return null;
    },
    routes: [
      // ---------------------------------------------------------------------------
      // Auth gate (no bottom nav).
      // ---------------------------------------------------------------------------
      GoRoute(
        path: '/auth',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Auth'),
      ),

      // ---------------------------------------------------------------------------
      // Bottom-nav shell (Home / Notes / League) + their nested tab routes.
      // ---------------------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BottomNavShell(navigationShell: navigationShell),
        branches: [
          // Notes tab.
          StatefulShellBranch(
            navigatorKey: _notesNavKey,
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Notes'),
              ),
            ],
          ),
          // Home tab (the app root).
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Home'),
              ),
            ],
          ),
          // League / Streaks tab.
          StatefulShellBranch(
            navigatorKey: _leagueNavKey,
            routes: [
              GoRoute(
                path: '/league',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'League'),
              ),
            ],
          ),
        ],
      ),

      // ---------------------------------------------------------------------------
      // Drill-in routes (pushed on top of the shell, no bottom nav).
      // These read activeIsleIdProvider / activeSparkIdProvider once wired up
      // in later phases; placeholders for now.
      // ---------------------------------------------------------------------------
      GoRoute(
        path: '/isles',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Your Isles'),
      ),
      GoRoute(
        path: '/isle',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Isle Home'),
      ),
      GoRoute(
        path: '/spark',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Spark Details'),
      ),
      GoRoute(
        path: '/sparkthread',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Spark Thread'),
      ),
      GoRoute(
        path: '/sparksettings',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Spark Settings'),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Isle Chat'),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'New Spark'),
      ),
      GoRoute(
        path: '/create-isle',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Create Isle'),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Post Composer'),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Discover'),
      ),
      GoRoute(
        path: '/isle-settings',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Isle Settings'),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Friends'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: '/appsettings',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'App Settings'),
      ),
    ],
  );
});

// -----------------------------------------------------------------------------
// Branch navigator keys — one GlobalKey per bottom-nav branch so each branch
// keeps an independent navigation state.
// -----------------------------------------------------------------------------

final GlobalKey<NavigatorState> _homeNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _notesNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'notes');
final GlobalKey<NavigatorState> _leagueNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'league');

/// Bridges [authStateProvider] to GoRouter's [GoRouter.refreshListenable].
///
/// GoRouter needs a [Listenable] to know when to re-run redirects; this listens
/// to the provider and notifies the router whenever auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<bool>(authStateProvider, (_, __) => notifyListeners());
  }
}
