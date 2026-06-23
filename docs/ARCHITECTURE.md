# Architecture — Goal Isle Flutter App

**Date:** June 22, 2026

This document describes the current code architecture. It will evolve as the app is rebuilt with the new design tokens and widget library.

---

## High-Level Structure

```
main()
  └── GoalIsleApp (MaterialApp)
       └── MainScreen (home)
            ├── IsleCreateScreen (modal)
            ├── IsleModal (modal)
            └── ChatScreen, LoginScreen, SignupScreen (placeholders)
```

The app is **single-user, single-screen-at-a-time** with modal sheets for sub-flows. There is no bottom nav, no drawer, no nested navigation.

---

## Entry Point

### `lib/main.dart`

```dart
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const ProviderScope(child: GoalIsleApp()));
  } catch (e) {
    print("FATAL APP ERROR: $e");
  }
}

class GoalIsleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Isle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, ...),
      home: const MainScreen(),
    );
  }
}
```

**Note:** `main()` is `async` even though it does not `await`. This is a relic of an earlier attempt to initialize Supabase. It is harmless.

**Theme:** Currently uses ad-hoc dark theme with hardcoded colors. This will be replaced by the tokens in `docs/design/TOKENS.md` during Phase 2 of the UI plan.

---

## State Management

### Riverpod 2.6.1

State is managed via Riverpod `StateNotifier`s. Each domain (isles, goals, sub-points, etc.) has its own notifier and provider.

**Providers live in `lib/providers/`.**

| Provider | File | Status |
|---|---|---|
| `isleProvider` | `isle_provider.dart` | Mock data — 3 hardcoded isles |
| `goalProvider` | `goal_provider.dart` | Empty, ready for mock data |
| `subPointProvider` | `sub_point_provider.dart` | Empty, ready for mock data |
| `friendProvider` | `friend_provider.dart` | Mock data — 2 hardcoded friends |
| `messageProvider` | `message_provider.dart` | Mock data — placeholder messages |
| `authProvider` | `auth_provider.dart` | Disabled (Supabase off) |
| `connectivityProvider` | `connectivity_provider.dart` | Disabled (no plugin) |

### Mock Data Pattern

Mock data is loaded in the **notifier constructor**, not in `build()`:

```dart
class IsleNotifier extends StateNotifier<List<Isle>> {
  IsleNotifier() : super([]) {
    _loadMockData();  // ✅ Loaded in constructor
  }

  void _loadMockData() {
    state = [/* hardcoded isles */];
  }
}
```

**Why this matters:** Riverpod forbids modifying providers during widget `build()`. Earlier code called `initialize()` from `build()`, which crashed. The fix is to load data in the constructor.

---

## Models (`lib/models/`)

Pure Dart classes with `fromJson`/`toJson`. They represent the data shapes regardless of backend.

| Model | File | Purpose |
|---|---|---|
| `Isle` | `isle.dart` | Major goal with mass, emoji, settings |
| `Goal` | `goal.dart` | Specific objective on an isle |
| `SubPoint` | `sub_point.dart` | Task or milestone under a goal |
| `User` | `user.dart` | User profile |
| `Friend` | `friend.dart` | Friend relationship |
| `Message` | `message.dart` | Chat message |
| `Media` | `media.dart` | Image/video attachment |
| `ContentReport` | `content_report.dart` | User-submitted content moderation |
| `UserBlock` | `user_block.dart` | Blocked user |

### Isle Model (key data shape)

```dart
class Isle {
  final String id;
  final String name;
  final String mainEmoji;
  final int mass;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? settings;  // whoCanFill, refillFrequency, etc.
}
```

The `settings` map is a placeholder for future configuration (refill intervals, visibility, permissions).

---

## Screens (`lib/screens/`)

Organized by feature, not by type.

```
screens/
├── main/                    # Home canvas
│   ├── main_screen.dart     # Current production home
│   └── main_screen_safe.dart  # Earlier fallback (not in active flow)
├── auth/                    # Disabled
│   ├── login_screen.dart
│   └── signup_screen.dart
├── isle/                    # Isle-related screens
│   ├── isle_modal.dart      # Detail modal (tap an isle)
│   └── isle_create_screen.dart  # Create modal (tap Spark)
└── chat/
    └── chat_screen.dart     # Chat UI (mocked)
```

### MainScreen

Shows:
- Sparse lines background (CustomPainter).
- Mountain visual at the bottom (decorative; grows with total mass).
- Isle cards in a centered Wrap.
- Floating action button to create a new isle.

Empty state: only the Spark button is visible.

### IsleCreateScreen

Modal sheet. Form fields: name + emoji picker. Submit creates a new isle in the mock provider.

### IsleModal

Modal sheet shown when an isle is tapped. Shows goals and sub-points for that isle.

---

## Widgets (`lib/widgets/`)

| Widget | File | Purpose |
|---|---|---|
| `MountainVisual` | `mountain_visual.dart` | Decorative mountain peaks that scale with total mass |
| `SparkButton` | `spark_button.dart` | Animated CTA for "plant new isle" |
| `SparseLinesBackground` | (inline painter in `main_screen.dart`) | Subtle grid pattern |

These will be expanded during Phase 3 of the UI plan to include:
- `IsleCard` (replaces inline card in `main_screen.dart`)
- `GoalCard`, `SubPointTile`
- `AppTextField`, `AppButton`
- `ModalSheet` (consistent modal style)

---

## Services (`lib/services/`)

| File | Status |
|---|---|
| `supabase_service.dart` | Disabled (Supabase not initialized) |
| `offline_queue_service.dart` | Disabled (depends on Supabase) |

These exist as scaffolds for when a real backend is added.

---

## Configuration (`lib/config/`)

| File | Status |
|---|---|
| `supabase_config.dart` | Disabled (Supabase not initialized) |

---

## What's NOT Here Yet

The following don't exist and need to be created in upcoming phases:

- `lib/theme/tokens.dart` — design tokens (Phase 2)
- `lib/theme/app_theme.dart` — theme built from tokens (Phase 2)
- `lib/widgets/isle_card.dart`, `goal_card.dart`, etc. — widget library (Phase 3)
- Real implementations of chat, auth, friends — after Phase 7 (architecture lock)

---

## Dependency Map

```yaml
dependencies:
  flutter_riverpod: ^2.4.9    # State management
  flutter_emoji: ^2.5.1       # Emoji picker (unused currently)
  cached_network_image: ^3.3.0  # Network images (unused currently)
  uuid: ^4.0.0                # ID generation (unused currently)
  intl: ^0.18.1               # Date/number formatting (unused currently)
  shared_preferences: ^2.2.2  # Local storage (unused currently)
```

Many dependencies are installed but not yet imported. They were planned for features that haven't been built yet (chat, friends, auth, persistence). They are inert until imported.

---

## Why This Architecture

- **Single user flow.** No router complexity. One screen, modal sheets for sub-flows.
- **Mock providers.** Real data can be slotted in later without changing screens.
- **Riverpod.** Provider-based DI, simple testing, hot-reload-friendly.
- **No premature abstractions.** Services exist but are empty. Conditional imports, platform abstractions, and feature flags are deferred until needed.

---

*Last updated: June 22, 2026.*