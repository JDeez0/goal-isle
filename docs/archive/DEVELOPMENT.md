# Development Guide — Goal Isle

**Date:** June 22, 2026

How to set up, build, test, and develop the Goal Isle Flutter app.

---

## Prerequisites

| Tool | Version | Path |
|---|---|---|
| Flutter | 3.44.2 | `/home/jasper/flutter/bin/flutter` |
| Dart | 3.12.2 | (bundled with Flutter) |
| Python 3 | any | for serving built web |
| Firefox or Chrome | any | for browser testing |
| Git | any | for version control |

### Add Flutter to PATH (one-time)

```bash
echo 'export PATH="$PATH:/home/jasper/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

After this, `flutter` works everywhere instead of needing the absolute path.

---

## Common Commands

### Run the app (with hot reload)

```bash
cd /home/jasper/projects/goal_isle
flutter run -d chrome
```

Then in the terminal:
- `r` — hot reload
- `R` — hot restart (resets state)
- `q` — quit

### Build for web

```bash
flutter build web --no-tree-shake-icons
```

The output goes to `build/web/`.

### Serve the built web app

```bash
cd build/web
python3 -m http.server 8094
# Open: http://localhost:8094
```

### Run tests

```bash
flutter test
```

### Analyze code

```bash
flutter analyze
```

### Clean and rebuild

```bash
flutter clean
flutter pub get
flutter build web --no-tree-shake-icons
```

### Update dependencies

```bash
flutter pub get
# or
flutter pub upgrade
```

---

## Hot Reload Workflow

Flutter web hot reload is enabled by default since Flutter 3.35. The current project is on 3.44.2.

### How it works

- Edit any Dart file in `lib/`.
- Save the file.
- The running app updates within ~1 second.
- App state is preserved (scroll position, navigation, form data).

### When state IS preservedёт, form data, modal state.
- Hot reload skips changes to `main()`, `initState()`, enum definitions, generic types, and `CupertinoTabView` builders.
- Use `R` (hot restart) when hot reload can't pick up your change.

### When state IS NOT preserved
- Hot restart (`R`) — runs `main()` again.
- Full restart (quit + `flutter run`) — cold start.

### VS Code setup

Add to `.vscode/settings.json`:

```json
{
  "files.autoSave": "afterDelay",
  "dart.flutterHotReloadOnSave": "all"
}
```

This makes hot reload happen automatically on save.

---

## Project Layout

```
lib/
├── main.dart                  # Entry point
├── main_test.dart             # Simple test app (not used)
├── models/                    # Data classes
│   ├── content_report.dart
│   ├── friend.dart
│   ├── goal.dart
│   ├── isle.dart
│   ├── media.dart
│   ├── message.dart
│   ├── sub_point.dart
│   ├── user.dart
│   └── user_block.dart
├── providers/                 # Riverpod state notifiers
│   ├── auth_provider.dart
│   ├── connectivity_provider.dart
│   ├── friend_provider.dart
│   ├── goal_provider.dart
│   ├── isle_provider.dart
│   ├── message_provider.dart
│   └── sub_point_provider.dart
├── screens/                   # UI by feature
│   ├── auth/
│   ├── chat/
│   ├── isle/
│   └── main/
├── services/                  # (Disabled) backend services
│   ├── offline_queue_service.dart
│   └── supabase_service.dart
├── widgets/                   # Reusable widgets
│   ├── mountain_visual.dart
│   ├── spark_button.dart
│   └── sparse_lines_background.dart
├── config/                    # (Disabled) configuration
│   └── supabase_config.dart
└── theme/                     # (To be created in Phase 2)
    ├── tokens.dart
    └── app_theme.dart
```

---

## Mock Data

All data is currently mocked. The mock data lives in the constructor of each notifier:

```dart
class IsleNotifier extends StateNotifier<List<Isle>> {
  IsleNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      Isle(id: '1', name: 'Fitness Journey', ...),
      Isle(id: '2', name: 'Learning Spanish', ...),
      Isle(id: '3', name: 'Save for Vacation', ...),
    ];
  }
}
```

When you need new mock data (e.g., a new screen requires more isles), edit the notifier directly. Do not wire a backend during UI iteration.

---

## Disabled Code (Supabase)

Most `lib/providers/` and `lib/services/` files have Supabase-related code commented out with the marker `// DISABLED FOR MOCKUP`. This is intentional documentation of intent.

To see all disabled Supabase references:

```bash
grep -rn "DISABLED FOR MOCKUP" lib/ --include="*.dart" | wc -l
```

Do **not** re-enable Supabase code until the design is locked (Phase 7 of `UI_DEVELOPMENT_PLAN.md`). Re-enabling it was the cause of the original white-screen bug.

---

## Debugging

### Browser console

When running in a browser, open DevTools (F12) → Console for runtime errors.

Common things to check:
- **"Null check operator used on a null value"** — usually a plugin or initialization issue. See `FLUTTER_DEBUG_LOG.md`.
- **Missing dependencies** — run `flutter pub get`.
- **Service worker caching** — see `FLUTTER_DEBUG_LOG.md` Attempt 2.

### Widget Inspector

In DevTools (F12), click the Flutter Inspector tab. You can:
- View the widget tree.
- Inspect properties of any widget.
- Edit values live (colors, text, etc.) for visual debugging.

### Logs

In `flutter run -d chrome`, logs appear in the terminal. Hot reload prints `Reloaded X of Y libraries in Zms`.

---

## Adding a New Dependency

**Do not add dependencies during UI iteration.** If you think you need one:

1. Check if it can be done with existing packages.
2. Check the design impact (`docs/design/`).
3. Test that adding it doesn't re-introduce the white-screen bug (rebuild, serve, test).
4. Document the decision in the PR/commit message.

The last dependency-related incident caused the white-screen bug. Removing `supabase_flutter` was the fix. See `FLUTTER_DEBUG_LOG.md`.

---

## Common Mistakes to Avoid

### Don't Hardcode Colors

If you set `backgroundColor` on widgets directly, it **overrides the theme**:

```dart
// ❌ BAD — this overrides the theme
Scaffold(
  backgroundColor: const Color(0xFF0A0E17),
  body: ...
)

// ✅ GOOD — let the theme control it
Scaffold(
  body: ...
)
```

When applying a new theme, search your codebase for hardcoded colors:

```bash
grep -rn "Color(0xFF" lib/ --include="*.dart"
```

**Fix:** Remove explicit `backgroundColor` assignments and let the `createAppTheme()` from `lib/theme/app_theme.dart` control the visual appearance.

This issue occurred during Phase 2: the theme was updated to light mode, but `main_screen.dart` still had `backgroundColor: const Color(0xFF0A0E17)` hardcoded in its Scaffold widgets, which overrode the new light theme and kept showing dark mode.

---

## Version Control

### Repo

```
origin: git@github.com:JDeez0/goal-isle.git
branch: main
```

### Common git commands

```bash
git status
git add -A
git commit -m "..."
git push origin main
git log --oneline | head -10
```

### Commit message style

Plain English, present tense, descriptive:

- ✅ `Add design tokens for cool palette`
- ✅ `Fix Riverpod state mutation during build`
- ✅ `Update CURRENT_STATUS.md with final fix`
- ❌ `wip`
- ❌ `fix stuff`

---

## Server Management

### Kill all Python servers

```bash
pkill -9 -f "python3.*http.server"
```

### Check what's on a port

```bash
lsof -ti:8094
```

### Free a specific port

```bash
lsof -ti:8094 | xargs kill -9
```

---

## Troubleshooting

### Build fails with "couldn't resolve package X"

You have a generated `web_plugin_registrant.dart` referencing a removed package. Run:

```bash
flutter clean
flutter pub get
flutter build web --no-tree-shake-icons
```

### Browser shows a blank white screen

See `FLUTTER_DEBUG_LOG.md`. Most likely:
1. Stale build — `flutter clean` and rebuild.
2. Stale server cache — hard-refresh browser or kill the server.
3. Plugin issue — check the latest dependency changes.

### `flutter` command not found

PATH isn't set. Use the absolute path `/home/jasper/flutter/bin/flutter`, or add Flutter to PATH (see top of this doc).

### `flutter test` fails

Most common: an updated notifier changed the mock data shape, and a test relies on specific values. Update the test or fix the mock data.

---

*Last updated: June 22, 2026.*