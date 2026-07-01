# Goal Isle — Current Status

**Date:** July 1, 2026
**Project:** `/home/jasper/projects/goal_isle/`

> 🚨 **BIG CHANGE (July 1):** The product has been redesigned around **Isle Sparks**. The full spec is in **[`docs/design/ISLE_SPARKS_SPEC.md`](docs/design/ISLE_SPARKS_SPEC.md)**. The Flutter code below still reflects the **old** model and has **not** been migrated yet. UI design mockups are in **[`docs/design/mockups/`](docs/design/mockups/)**.

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
| **`docs/design/ISLE_SPARKS_SPEC.md`** | **🔒 THE current system spec — Isle Sparks redesign (read this first)** |
| **`docs/design/MOCKUPS.md`** | **How to run the design mockups** |
| `UI_DEVELOPMENT_PLAN.md` | 7-phase plan for UI work (pre-redesign; still broadly useful) |
| `FLUTTER_DEBUG_LOG.md` | Debugging history that got Flutter rendering |
| `docs/ARCHITECTURE.md` | Code architecture |
| `docs/DEVELOPMENT.md` | How to develop |
| `docs/HISTORY.md` | Project timeline |
| `docs/design/VISION.md` | The vibe (⚠️ partially superseded — streaks reversed, model changed) |
| `docs/design/SCREENS.md` | ⚠️ Superseded by `ISLE_SPARKS_SPEC.md` |
| `docs/design/TOKENS.md` | Design tokens (⚠️ mass/progress tokens orphaned) |
| `docs/design/README.md` | Design docs index |

### Archived docs (do not use)

See `docs/archive/README.md` for the full list. These were written before the actual root cause was discovered and contain contradictory information.

---

## 🚀 What to Do Next

The redesign spec is locked. The Flutter code has **not** been migrated yet.

### Immediate — port the redesign into Flutter
1. **Build the `IsleSpark` widget** from the sparks mockup (`docs/design/mockups/sparks.html`): quasi-circle shape, the four states (dull/lit/streaked/greyed), sparkles, streak badge. (A circumscribing "beach line" was designed and then deferred to `docs/archive/BEACH_LINE.md` — do **not** build it yet.)
2. **Build `CreateSparkButton`** (dashed silhouette + grey `?`, bottom-right).
3. **Rebuild Home** to show only floating sparks + Create button (lit float, greyed sink).

### Short term — migrate the data model (per `ISLE_SPARKS_SPEC.md` §8)
4. `Isle` → `Spark`: drop `mass`; add `title`, `timerMode`, `streakBreaksOnMiss`, `streak`, `lastCompletedAt`, `cycleDueAt`, `members`, `dependencies`.
5. `SubPoint` → `Dependency`: drop `goalId`, add `requiredCount`.
6. **Delete** `goal.dart`, `media.dart`, `content_report.dart`, `user_block.dart`, `mountain_visual.dart`, `sparse_lines_background.dart`.
7. **Create the `Membership` model** (the biggest structural gap).
8. Build the **New Spark equation-builder** screen and **Spark Details**.

### Long term
9. Real auth + identity (required for sharing/members). Currently mocked.
10. Completion-detection logic in the chat (exact emoji match, typed or reacted).

---

*Last updated: July 1, 2026 — Isle Sparks redesign spec locked; mockups added; Flutter migration pending.*