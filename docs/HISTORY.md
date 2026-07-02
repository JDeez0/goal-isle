# History — Goal Isle

**Date:** June 22, 2026

A chronological record of significant decisions, attempts, and milestones. This is the story of how the project got from "blank white screen" to "working Flutter app with a design plan."

---

## Phase 0 — The Stalled Project (Pre-June 18)

The original Flutter app was scaffolded but never ran in a browser. Build succeeded; runtime crashed with:

```
Uncaught (in promise) Error: Null check operator used on a null value
```

The codebase had:
- A Riverpod-based state management architecture.
- A Supabase integration (auth, real-time, offline queue).
- Multiple mobile-only packages (`image_picker`, `permission_handler`, `video_player`).
- A `dart:io` import in `chat_screen.dart`.

The cause of the runtime failure was misdiagnosed multiple times:

1. **First diagnosis:** Supabase initialization.
2. **Second diagnosis:** Provider race conditions.
3. **Third diagnosis:** Unsafe `!` null operators in `setState`.
4. **Fourth diagnosis:** `dart:io` web incompatibility.
5. **Fifth diagnosis:** Deprecated FlutterLoader API.

None of these were the root cause.

---

## Phase 1 — The HTML Mockup (June 18)

When debugging failed, the project pivoted to a working HTML/CSS/JS mockup:

- Built `goal_isle_working_mockup.html` (~19KB, self-contained).
- Featured 3 interactive isles, task filling, create flow, modal animations.
- Served at `http://localhost:9999/goal_isle_working_mockup.html`.
- Became the "working product" while the Flutter app sat broken.

The mockup served as a design validation tool. It proved the concept worked. It was never intended to ship.

---

## Phase 2 — Documentation Cleanup (June 18–22)

The project accumulated many `.md` files from the debugging attempts:

- `DEBUGGING_SUMMARY.md`, `STRUCTURAL_ANALYSIS.md`, `ROOT_CAUSE_RESOLUTION.md`
- `ADDITIONAL_FIXES.md`, `HONEST_ASSESSMENT.md`
- `QUICK_START.md`, `RESUME_WORK_GUIDE.md`, `TEST_RESUME.md`
- `WORKING_MOCKUP_SUCCESS.md`, `README_MOCKUP.md`
- `MASTER_INDEX.md` (with conflicting status notes)

These were written at different times and contradicted each other. The Flutter codebase had drifted from the documentation.

---

## Phase 3 — Git and Code Cleanup (June 22, morning)

Morning of June 22, work began on consolidating the project:

- **Git initialized** on `main` branch, all 175 files committed.
- **GitHub remote** added: `git@github.com:JDeez0/goal-isle.git`.
- **Code cleanup:**
  - Fixed Riverpod state mutation during build (moved mock data init to notifier constructor).
  - Removed dead imports (`dart:io`, `image_picker`, etc.) — these were never used.
  - Removed unused fields and methods.
  - Fixed widget test (`test/widget_test.dart`).
- **`flutter test`** now passes.
- **`flutter build web`** still succeeds.
- **`CURRENT_STATUS.md`** created as the single source of truth.

---

## Phase 4 — The Real Root Cause (June 22, afternoon)

A new debugging session revealed the actual cause of the white-screen bug. The pattern was:

1. Remove 4 suspected plugins (`permission_handler`, `image_picker`, `video_player`, `connectivity_plus`).
2. **Still broken.**
3. Remove `supabase_flutter`.
4. **Works.**

The root cause: the **transitive web plugin `ua_client_hints`** pulled in by `supabase_flutter` was throwing a null check error during Flutter engine bootstrap. Even though Supabase was never initialized in `main.dart`, the web plugin registration code still ran and crashed.

**This was never diagnosed correctly before.** The earlier "fixes" (removing `dart:io`, deprecated API updates, race condition fixes) were either harmless or already-correct. They didn't break the app, but they didn't fix it either.

`FLUTTER_DEBUG_LOG.md` records every attempt in detail.

---

## Phase 5 — The Flutter App Finally Renders (June 22)

After removing the problematic plugins, the Flutter web app rendered in Firefox:

- `flutter build web` ✅
- `flutter test` ✅
- Browser renders ✅
- WASM dry run ✅ (also fixed by removing `ua_client_hints`)
- No more white screen.

Commits:
- `04f7737` — Fix Flutter runtime, clean dead imports, fix widget test, update docs
- `0c3d16d` — Remove problematic plugins
- `4c6880d` — Update docs: Flutter app confirmed rendering
- `d2398a4` — Add UI development plan
- `5c76a62` — Update UI plan: design from scratch
- `010eeb0` — Document design vision, screens, tokens

---

## Phase 6 — Design From Scratch (June 22, current)

With the Flutter app finally rendering, the project shifted from "make Flutter work" to "make it look right."

### Decision: design in Flutter, not HTML mockups

The user asked: should we keep iterating in HTML mockups or move to Flutter?

Analysis showed that Flutter web hot reload became default in Flutter 3.35, making direct iteration nearly as fast as HTML refresh — with state preservation and no throwaway code.

The HTML mockup is **archived**. The Flutter codebase defines its own design.

### The vibe

> **Minimal. Literal. Clean/cool.**
>
> A quiet harbor for your goals. Calm, present, easy to set down. No streaks, no notifications, no gamification noise.

### Design docs

- `docs/design/VISION.md` — the vibe and personality
- `docs/design/SCREENS.md` — screen inventory
- `docs/design/TOKENS.md` — design tokens (cool palette, system typography, generous spacing)
- `docs/design/README.md` — index

### The plan

`UI_DEVELOPMENT_PLAN.md` lays out 7 phases:

1. Design from scratch (intentional — done)
2. Establish design tokens
3. Build the widget library
4. Screen-by-screen port
5. Interaction and motion
6. User testing
7. Lock the design, then architecture

---

## Phase 7 — The Redesign: Isle Sparks (July 1, 2026)

The product was reimagined from the ground up. The old model (Isles → Goals → Sub-points, with Mass as a progress indicator) was discarded in favor of a single core object: the **Isle Spark**.

### What changed

- **Isle Spark** is now the only object on Home — a 0.5″ quasi-circular button (circle with a sharp top-left corner) holding a main emoji.
- **Goals, Sub-points, and Mass are gone.** Replaced by: a main emoji + 0–N **dependency emojis** ("ingredients").
- **Completion is now social and chat-driven:** a spark lights when its emoji-ingredients are placed (typed or reacted) in the spark's shared chat room. Solo users just type the main emoji to themselves.
- **Streaks** — explicitly **reversing** the earlier "no streaks" principle. Completing a cycle increments a streak; a number badge appears at streak ≥ 2. (A squiggly "beach line" circumscribing the spark was also part of the original design but was deferred to `docs/archive/BEACH_LINE.md` later the same day — see Key Decisions.)
- **Repetition + decay:** sparks repeat on a timer (instant 10s / daily / weekly / monthly). Missed sparks **fade grey evenly and sink to the bottom of Home** — they are **never auto-deleted**; only the creator can delete via Settings.
- **An Isle = one spark + its members + its chat.** Sharing a spark creates members with shared progress. Sparks are creator-owned: if the creator leaves/expires/deletes, it vanishes for everyone.

### Decisions resolved during the spec session

- Timer boundaries: daily=midnight, weekly=Mon 00:00, monthly=1st 00:00, instant=+10s from completion.
- One emoji occurrence satisfies a dependency — dependencies are **single-occurrence / binary** (no `requiredCount`; that concept was removed July 2, 2026).
- Satisfaction resets each cycle.
- Match rule: **exact/definite match only**.
- `streak-breaks-on-miss` is a **per-spark creation choice** (default: breaks).
- No auto-delete on miss — sparks grey out and sink instead.

### Artifacts produced

- **`docs/design/ISLE_SPARKS_SPEC.md`** — the locked, definitive system spec (new source of truth).
- **`docs/design/MOCKUPS.md`** + **`docs/design/mockups/sparks.html`** and **`buttons.html`** — HTML/CSS mockups for design iteration.
- `SCREENS.md` and `VISION.md` marked superseded.

### What's NOT done yet

- The Flutter codebase still reflects the **old** model. The spec's **Migration** section lists every model/widget change.
- **No membership model exists** yet — the biggest structural gap.
- Auth is still mocked, so the social mechanics can't be truly tested yet.

---

## Key Decisions

| Date | Decision |
|---|---|
| June 18 | Pivot to HTML mockup when Flutter fails |
| June 22 | Fix Flutter app properly (find real root cause) |
| June 22 | Archive HTML mockup; design in Flutter instead |
| June 22 | Minimal, literal, clean/cool vibe locked in |
| June 22 | Defer all architecture decisions until design is locked |
| **July 1** | **Redesign to Isle Sparks; reverse the "no streaks" principle** |
| **July 1** | **Lock the Isle Sparks spec (see `ISLE_SPARKS_SPEC.md`)** |
| **July 1** | **Spark silhouette is user-chosen (Shape picker on Create Spark); default = rhomboid squircle** |
| **July 1** | **Create Spark design language locked: icon-led, no noun headers; equation as hero (`create-spark.html`)** |
| **July 1** | **Beach line (streaked-spark circumscription stroke) deferred to archive (`docs/archive/BEACH_LINE.md`) — to revisit later** |
| **July 1** | **Whole-repo vestigial-information audit completed — 19/27 `lib/` files, 6/11 top-level docs, 1 security issue flagged; full plan in `docs/AUDIT_2026_07_01.md`** |
| **July 1** | **Vestigial-information cleanup completed: Supabase key rotated (fake placeholder), uncommitted Flutter changes reverted, 5 docs moved to archive (VISION, SCREENS, ARCHITECTURE, DEVELOPMENT, UI_DEVELOPMENT_PLAN), old mockup moved to archive, README/CURRENT_STATUS/TOKENS/VISION/TOKENS updated, docs/archive/README updated** |
| **July 1** | **Full screen inventory documented — 8 spec-named screens + Tier 2/3/4 supporting/edge-case screens + shared components; `docs/design/SCREEN_INVENTORY.md` is the mockup roadmap** |

---

## What Wasn't Tried

Things that would have sped up debugging but weren't attempted:

- **Build with source maps** for stack trace decoding. Could have revealed the `ua_client_hints` culprit earlier.
- **Binary search of plugins** from the start. Instead of fix-and-test cycles, remove half the plugins per rebuild.
- **Look at the generated `web_plugin_registrant.dart`**. This file shows exactly which web plugins get registered.
- **Try a brand-new minimal Flutter web project**. If it works, the issue is project-specific. If it doesn't, the issue is environmental.

---

## What's Next

Per `UI_DEVELOPMENT_PLAN.md`:

- **Phase 2:** Create `lib/theme/tokens.dart` and `lib/theme/app_theme.dart`.
- **Phase 3:** Extract reusable widgets, write Widget Previews.
- **Phase 4:** Build screens using tokens and widgets.
- **Phase 5:** Add gestures, animations, transitions.
- **Phase 6:** Walk through user flows, document feedback.
- **Phase 7:** Lock the design. Then architecture: backend, platform, data models.

---

*Last updated: July 1, 2026.*