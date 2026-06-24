# Goal Isle — Current Status

**Date:** June 22, 2026
**Project:** `/home/jasper/projects/goal_isle/`

---

## ✅ What Works Right Now

### 1. Flutter Web App — RENDERS IN BROWSER
- **Run it:**
  ```bash
  cd /home/jasper/projects/goal_isle
  flutter run -d chrome
  # Or serve the existing build:
  cd build/web && python3 -m http.server 8094
  ```
- **Open:** http://localhost:8094/index.html
- **Status:** ✅ Verified rendering in Firefox
- **Theme:** Light mode with slate water background (`#EEF2F5`)
- **Build:** `flutter build web --no-tree-shake-icons` ✅
- **Test:** `flutter test` ✅ passes

### 2. HTML/CSS/JS Mockup — Archived
- **File:** `goal_isle_working_mockup.html`
- **Status:** Kept in repo as an archive of an earlier design exploration. **No longer the visual reference for the Flutter app.** The Flutter codebase defines its own look and feel independently.
- **Run it (only if you want to see the archive):**
  ```bash
  cd /home/jasper/projects/goal_isle
  python3 -m http.server 9999
  ```
- **Open:** http://localhost:9999/goal_isle_working_mockup.html

### 3. Local Git Repo
- Remote: `git@github.com:JDeez0/goal-isle.git`
- Branch: `main`
- Latest commit: `010eeb0` (pushed)

---

## 🔧 The Final Fix

The Flutter app now renders in the browser. The root cause was a **null check failing during web plugin bootstrap**. Resolution steps:

1. Fixed Riverpod state mutation during build (move mock data init into `IsleNotifier()` constructor).
2. Removed the following plugins from `pubspec.yaml`:
   - `permission_handler` (mobile only)
   - `image_picker` (problematic web plugin)
   - `video_player` (problematic web plugin)
   - `connectivity_plus` (WASM incompatible)
   - `supabase_flutter` (pulls in many web plugins: `ua_client_hints`, `url_launcher_web`, `passkeys_web`, etc.)
3. Cleaned dead imports and unused fields.
4. Ran `flutter clean && flutter pub get && flutter build web --no-tree-shake-icons`.

The combination of these removed plugins' web registration code (particularly the transitive `ua_client_hints` from `supabase_flutter`) was throwing a null check error during the Flutter engine bootstrap.

See `FLUTTER_DEBUG_LOG.md` for the full attempt-by-attempt record.

---

## ⚠️ Remaining Issues

- **Lint warnings remain.** `flutter analyze` reports info-level issues — deprecated `withOpacity`, missing `const` constructors, leftover `print()` calls. No errors or warnings.
- **Dead code still present.** Lots of commented-out Supabase code is left as documentation of intent. Can be removed later.
- **Feature gaps:** Chat, friends, auth, offline queue, and real-time collaboration exist as files but are mocked/disabled.

---

## 📚 Documentation Notes

The doc set was consolidated on June 22. Many older files were moved to `docs/archive/`.

### Current docs (use these)

| Doc | Purpose |
|---|---|
| `README.md` | Project root, comprehensive entry point |
| `CURRENT_STATUS.md` | This file — project state, source of truth |
| `UI_DEVELOPMENT_PLAN.md` | 7-phase plan for UI work |
| `FLUTTER_DEBUG_LOG.md` | Debugging history that got Flutter rendering |
| `docs/ARCHITECTURE.md` | Code architecture |
| `docs/DEVELOPMENT.md` | How to develop |
| `docs/HISTORY.md` | Project timeline |
| `docs/design/VISION.md` | The vibe and core metaphor |
| `docs/design/SCREENS.md` | Screen inventory |
| `docs/design/TOKENS.md` | Design tokens |
| `docs/design/README.md` | Design docs index |

### Archived docs (do not use)

See `docs/archive/README.md` for the full list. These were written before the actual root cause was discovered and contain contradictory information.

---

## 🚀 What to Do Next

### Immediate
1. ✅ ~~Open the Flutter build in a browser to visually verify it works.~~ DONE — confirmed rendering.
2. ✅ ~~Decide whether to use HTML mockups or Flutter for UI iteration.~~ DONE — Flutter with hot reload (see `UI_DEVELOPMENT_PLAN.md`).
3. ✅ ~~Define the design intent.~~ DONE — `docs/design/VISION.md`, `SCREENS.md`, `TOKENS.md` (minimal, literal, clean/cool).
4. ✅ ~~Start Phase 2 of the UI plan:~~ create `lib/theme/tokens.dart` and `lib/theme/app_theme.dart`. DONE.
5. **Start Phase 3 of the UI plan:** Build widget library (extract IsleCard, SparkButton, etc.) with Widget Previews.

### Short Term
5. Extract the widget library and use Widget Previews for isolated iteration.
6. Build screens using tokens and widgets.

### Long Term
7. After the design is locked (Phase 7), make architecture decisions: backend, platform target, data models.
8. Implement the real feature set (chat, friends, auth, goal/sub-point CRUD).

---

*Last updated: June 22, 2026 — Flutter web app renders; design phase ready to begin.*