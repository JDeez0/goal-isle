# Goal Isle — Flutter Web Debugging Log

This file records every attempt to make the Flutter web build run in a browser without a white screen.

**Project:** `/home/jasper/projects/goal_isle/`  
**GitHub:** `git@github.com:JDeez0/goal-isle.git`  
**Started:** June 22, 2026

---

## Background

The project has two artifacts:
1. `goal_isle_working_mockup.html` — a fully functional HTML/CSS/JS mockup.
2. `lib/` — a Flutter codebase that historically showed a blank white screen in the browser.

Earlier documentation claimed the Flutter app was fixed after removing `dart:io` and updating `web/index.html`, but the app had **never been verified rendering in a browser**. This log captures the real debugging process.

---

## Attempt 1: Fix Riverpod state mutation during build

### Observation
`flutter test` initially failed with:
```
Tried to modify a provider while the widget tree was building.
```

### Root cause
`MainScreen.build()` and `SafeMainScreen.build()` called:
```dart
ref.read(isleProvider.notifier).initialize();
```
This modifies a Riverpod provider during the widget build phase, which is illegal and throws an assertion.

### Fix applied
- Moved mock data loading into `IsleNotifier()` constructor.
- Removed `initialize()` call from both main screens.
- Removed the now-unused `initialize()` method.

### Files changed
- `lib/providers/isle_provider.dart`
- `lib/screens/main/main_screen.dart`
- `lib/screens/main/main_screen_safe.dart`
- `test/widget_test.dart` (updated to wrap app in `ProviderScope`)

### Result
```
flutter test: ✅ All tests passed
flutter build web: ✅ Success
```
But **browser still showed a blank white screen** with the same old error:
```
Uncaught (in promise) Error: Null check operator used on a null value
```

The widget test did not exercise the web bootstrap code path.

---

## Attempt 2: Clean rebuild + fresh port

### Commands
```bash
/home/jasper/flutter/bin/flutter clean
/home/jasper/flutter/bin/flutter build web --no-tree-shake-icons
python3 -m http.server 8092
```

### Result
Browser still showed a white screen with the same null check error.

Hypothesis: stale build/port was not the issue.

---

## Attempt 3: Remove mobile-only and web-problematic dependencies

### Hypothesis
Flutter web plugins for `permission_handler`, `image_picker`, `video_player`, and `connectivity_plus` were registering during web bootstrap and failing with a null check.

### Commands
```bash
# Removed from pubspec.yaml:
# - connectivity_plus
# - image_picker
# - video_player
# - permission_handler
/home/jasper/flutter/bin/flutter clean
/home/jasper/flutter/bin/flutter pub get
/home/jasper/flutter/bin/flutter build web --no-tree-shake-icons
python3 -m http.server 8093
```

### Result
Build succeeded and `flutter analyze` showed fewer warnings.  
**Browser still showed a white screen** with the identical null check error.

Hypothesis: these four plugins were not the root cause.

---

## Attempt 4: Remove supabase_flutter

### Hypothesis
`supabase_flutter` pulls in many transitive web plugins (`app_links_web`, `url_launcher_web`, `passkeys_web`, `ua_client_hints`, etc.). Even though Supabase is not initialized in `main.dart`, the web plugin registration code still runs during bootstrap and may fail on a null check.

### Commands
```bash
# Removed from pubspec.yaml:
# - supabase_flutter
/home/jasper/flutter/bin/flutter clean
/home/jasper/flutter/bin/flutter pub get
/home/jasper/flutter/bin/flutter build web --no-tree-shake-icons
python3 -m http.server 8094
```

### Build output note
After removing `supabase_flutter`, the WASM dry run **succeeded** (previously it reported `ua_client_hints` as incompatible). This confirms `supabase_flutter` (or its transitive dependency `url_launcher_web`) was the source of the WASM warning.

### Result
**Pending browser test.** Latest build served on http://localhost:8094

---

## Remaining dependencies after Attempt 4

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  flutter_emoji: ^2.5.1
  cached_network_image: ^3.3.0
  uuid: ^4.0.0
  intl: ^0.18.1
  shared_preferences: ^2.2.2
```

Of these, only `cached_network_image` and `shared_preferences` register web plugins. If the browser still fails after Attempt 4, the next step is to remove those two as well.

---

## Other cleanup done during this session

- Removed dead imports from:
  - `lib/screens/chat/chat_screen.dart`
  - `lib/screens/isle/isle_modal.dart`
  - `lib/providers/connectivity_provider.dart`
- Removed unused fields:
  - `_imagePicker` in `chat_screen.dart`
  - `_emojiTextController` in `isle_create_screen.dart`
- Removed unused methods:
  - `_increaseIsleMass` in `sub_point_provider.dart`
  - `_fillSubPointForUpload` in `chat_screen.dart`
- Fixed protected-member warning in `chat_screen.dart` by adding `setMessages()` to `MessageNotifier`.
- Fixed `test/widget_test.dart` which referenced non-existent `MyApp`.
- Updated `CURRENT_STATUS.md`, `MASTER_INDEX.md`, `WORKING_MOCKUP_SUCCESS.md`.
- Created this log file.

---

## What we know for certain

- `flutter test` passes.
- `flutter build web` succeeds.
- The runtime failure happens during the web bootstrap, before any UI renders.
- The error is always `Null check operator used on a null value`.
- Source maps are not generated by default, making the minified stack trace hard to decode.

---

## Next steps if Attempt 4 fails

1. **Remove `cached_network_image` and `shared_preferences`** from `pubspec.yaml` and rebuild clean.
2. **Build with source maps** using a debug web build to decode the stack trace.
3. **Create a brand-new minimal Flutter web project** and copy the `lib/` code over piece by piece until the failure returns.
4. **Accept the HTML mockup as the working product** and archive the Flutter codebase.

---

*Last updated: June 22, 2026 — after Attempt 4, awaiting browser verification on port 8094.*
