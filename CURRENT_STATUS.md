# Goal Isle — Current Status

**Date:** July 4, 2026
**Project:** `/home/jasper/projects/goal_isle/`

> 🔑 **Rename (July 4):** "Isle Sparks" are now called **Isle Keys**. A key is **"turned"** or **"lit"** when its condition is met — but per the Language Principle, neither word appears in the UI; the user only sees the visual state change. "Spark" remains a fully valid synonym throughout docs and conversation. The governing spec keeps its body text as "spark" with a terminology note at the top; the codebase will standardize on `Key`/`keys` during the Flutter migration.

> 🚨 **BIG CHANGE (July 3):** The spec has been re-locked as **v2**. The product now targets a wedge — **college grads studying for the LSAT** — which added communities, metric keys, posts, and discovery. The governing spec is **[`docs/design/ISLE_SPARKS_SPEC_v2.md`](docs/design/ISLE_SPARKS_SPEC_v2.md)** (v1 retained as history). The Flutter code and the existing HTML mockups still reflect **v1** and have **not** been updated yet.

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
- Latest commit: `194c34a` (pushed)

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
| **`docs/design/ISLE_SPARKS_SPEC_v2.md`** | **🔒 THE governing spec — Isle Sparks v2 (read this first)** |
| `docs/design/ISLE_SPARKS_SPEC.md` | v1 spec — historical, superseded by v2 |
| **`docs/design/MOCKUPS.md`** | **How to run the design mockups** (⚠️ mockups currently reflect v1) |
| `docs/AUDIT_2026_07_01.md` | Whole-repo vestigial-information audit (what's outdated, what to fix) |
| `FLUTTER_DEBUG_LOG.md` | Debugging history that got Flutter rendering |
| `docs/HISTORY.md` | Project timeline + Key Decisions (Phase 8 = v2) |
| `docs/design/TOKENS.md` | Design tokens (colors, typography, spacing, motion). ⚠️ Layout section removed (orphaned). |

### Archived docs (do not use)

See `docs/archive/README.md` for the full list. The following were moved there on 2026-07-01 as part of a vestigial-information cleanup: `VISION.md`, `SCREENS.md`, `ARCHITECTURE.md`, `DEVELOPMENT.md`, `UI_DEVELOPMENT_PLAN.md`, and the old `goal_isle_working_mockup.html`.

---

## 🚀 What to Do Next

v2 spec is locked. The Flutter code and the existing mockups both reflect **v1** (or older) and need updating. Order matters: mock against the locked v2 spec first, then port to Flutter.

### Immediate — mock the two highest-risk v2 surfaces
These are the v2 inventions most likely to feel wrong and need iteration before they're worth coding:
1. **Home with territories** — rebuild the existing floating-sparks Home as sparks-grouped-on-Isle-territories (the three layout laws in v2 §9). The signature screen, now harder.
2. **New Spark type picker** — the plain-language 2-question flow (v2 §6) that secretly sets mode/scope/template. Hides the metric engine behind friendly choices.

### Short term — mock the rest of the v2 delta
3. **Isle Home** — the community drill-in (its sparks, feed, chat, members).
4. **Post Composer** — image/text/emoji + audience picker (one/several/all). New mental model.
5. **Metric Log sheet** + **per-Spark thread** — number + optional photo, off a metric spark.
6. **Discover/Search** — find public Isles by school/emoji/name; join flow. The network-effect surface.
7. **Isle Settings** — join policy (public/private), creator-chosen color swatch, member management, delete.

### Before Flutter — de-risk images
8. **Verify `image_picker` is re-addable on Flutter web.** It was removed (Phase 4 of HISTORY) for causing bootstrap null-checks. v2 needs it for Posts + metric proof. If it can't be re-added on web, scope Posts/images to mobile-first and gate on web.

### Flutter migration (per v2 §14)
9. Data model: `isle.dart` → community Isle; ➕ new `Spark`, `Post`, `Membership`; delete `goal.dart`, old `media.dart`, `content_report.dart`, `user_block.dart`, `mountain_visual.dart`, `sparse_lines_background.dart`, old `spark_button.dart`, one `main_screen`.
10. Build the widget library (v2 §15), including new `IsleTerritory`, `MetricLogSheet`, `PostComposer`, `PersonalSparkCluster`, `ConfirmPulse`.
11. Port screens using the v2 mockups as reference.

### Long term
12. Real auth + identity (required for all social mechanics). Currently mocked.
13. Moderation loop (report + creator-removes) for public Isles.

---

*Last updated: July 3, 2026 — v2 spec locked; existing docs/mockups now flagged as v1.*