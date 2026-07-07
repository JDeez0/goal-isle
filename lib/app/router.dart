import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/repositories/mock/mock_providers.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/chat/presentation/isle_chat_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/app_settings_screen.dart';
import '../features/isles/presentation/home_screen.dart';
import '../features/isles/presentation/isles_index_screen.dart';
import '../features/isles/presentation/create_isle_screen.dart';
import '../features/isles/presentation/isle_home_screen.dart';
import '../features/isles/presentation/isle_settings_screen.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/league/presentation/league_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/posts/presentation/post_composer_screen.dart';
import '../features/sparks/presentation/spark_details_screen.dart';
import '../features/sparks/presentation/spark_settings_screen.dart';
import '../features/sparks/presentation/spark_thread_screen.dart';
import '../features/sparks/presentation/new_spark_screen.dart';
import 'bottom_nav.dart';

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
        builder: (context, state) => const AuthScreen(),
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
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),
          // Home tab (the app root).
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // League / Streaks tab.
          StatefulShellBranch(
            navigatorKey: _leagueNavKey,
            routes: [
              GoRoute(
                path: '/league',
                builder: (context, state) => const LeagueScreen(),
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
        builder: (context, state) => const IslesIndexScreen(),
      ),
      GoRoute(
        path: '/isle',
        builder: (context, state) => const IsleHomeScreen(),
      ),
      GoRoute(
        path: '/spark',
        builder: (context, state) => const SparkDetailsScreen(),
      ),
      GoRoute(
        path: '/sparkthread',
        builder: (context, state) => const SparkThreadScreen(),
      ),
      GoRoute(
        path: '/sparksettings',
        builder: (context, state) => const SparkSettingsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const IsleChatScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const NewSparkScreen(),
      ),
      GoRoute(
        path: '/create-isle',
        builder: (context, state) => const CreateIsleScreen(),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostComposerScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/isle-settings',
        builder: (context, state) => const IsleSettingsScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/appsettings',
        builder: (context, state) => const AppSettingsScreen(),
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
