# Goal Isle — UI Development Plan

**Date:** June 22, 2026
**Project:** `/home/jasper/projects/goal_isle/`

---

## The Question

> "Before we make architectural changes, I want to continue to make the app look and feel the way I want. Is it safest to do that in HTML mockups, or what?"

This is the right question. UI/UX is downstream of architecture but upstream of code stability — get the look and feel locked before you commit to a backend, data model, or platform target.

### Update: Starting from scratch

After the Flutter app finally rendered, the decision shifted to: **design from scratch in Flutter**, not iterate toward the HTML mockup. The HTML mockup is no longer the visual reference. It served its purpose as a working prototype that proved the concept could work; now the Flutter codebase will define the look and feel independently.

This is a cleaner path because:

- No visual baggage from the mockup constrains the design.
- Every pixel ships — no "we'll match this later" reconciliation phase.
- The design is owned entirely by the Flutter widget code.
- The HTML mockup becomes an archive (kept in repo for reference, not modified).

---

## The Options

### Option A — Direct Flutter iteration with hot reload
Edit `lib/` while `flutter run -d chrome` is open. Hot reload preserves app state and reflects visual changes in ~1 second.

| | |
|---|---|
| **Iteration speed** | ~1s per change (hot reload) |
| **State preservation** | Yes — scroll, navigation, form data survive |
| **Throwaway code** | None — code ships directly |
| **Tooling for isolated work** | Widget Previews (Flutter 3.35+) |
| **Catches Flutter constraints early** | Yes (touch targets, Material widgets, navigation patterns) |
| **Learning curve** | Flutter widget patterns |

### Option B — Continue iterating in HTML mockups
Keep editing `goal_isle_working_mockup.html` until the design feels right, then port to Flutter.

| | |
|---|---|
| **Iteration speed** | ~100ms (browser refresh) |
| **State preservation** | No — form data lost on refresh |
| **Throwaway code** | 100% of design work |
| **Catches Flutter constraints early** | No — HTML doesn't reflect Flutter widgets |
| **Risk** | High. Research shows Figma-to-Flutter conversions need 2–4× manual adjustments per screen due to pixel discrepancies. Same applies to HTML-to-Flutter. |

### Option C — Figma or design tool first
Design in Figma, then port to Flutter.

| | |
|---|---|
| **Iteration speed** | Fast visual iteration |
| **Throwaway code** | 100% of design work |
| **Conversion accuracy** | 70–80% of conversions have pixel discrepancies |
| **Cost** | Highest — design phase + implementation phase + reconciliation |

### Option D — Hybrid: HTML for variety, Flutter for ship
Explore alternatives in HTML, then commit to Flutter implementation.

| | |
|---|---|
| **Best for** | Large teams with separate designers |
| **Cost** | Two systems to maintain during design phase |

---

## Recommendation: **Option A — Direct Flutter with hot reload**

### Why this wins now (it didn't before)

You started this project before **Flutter web hot reload became default in Flutter 3.35**. That changes the math:

1. **Hot reload on web is now default.** `flutter run -d chrome` gives you state-preserving sub-second iteration with no flags. (Your Flutter is 3.44.2, so this is active.)

2. **State preservation matters for UI work.** Hot reload keeps scroll position, navigation stack, form data, and selected tabs. HTML mockups lose all of this on refresh.

3. **Your existing HTML mockup is already a visual reference.** It doesn't need more iteration. It needs to be read as a design spec.

4. **Figma-to-Flutter conversion projects hit 70–80% pixel discrepancies.** The same applies to HTML-to-Flutter. Doing it once in Flutter code eliminates the entire reconciliation phase.

5. **You are the sole developer.** There's no handoff cost. Every hour spent in HTML is an hour not spent in code that ships.

### Why this is the safest path

- **Code that ships.** No throwaway work.
- **Catch Flutter constraints during design phase** (touch targets, Material widgets, gesture patterns). If you build it in HTML first, you'll discover these constraints during port and have to redesign.
- **Widget Inspector lets you tweak colors and spacing live** in DevTools.
- **Widget Previews** (Flutter 3.35+) let you iterate on a single component in isolation without running the full app.

---

## Detailed Plan

### Phase 1 — Design from scratch

**Goal:** Define the look and feel of the app directly in Flutter, starting from a blank slate. No reference to the HTML mockup.

**Steps:**
1. Decide the **vibe** of the app (one paragraph in `docs/design/VISION.md`):
   - What emotion should the user feel when they open it?
   - What's the personality (playful, serious, minimal, dense)?
   - What's the core metaphor and how does it show up visually?
2. Decide the **core screens** (list in `docs/design/SCREENS.md`):
   - What screens exist? (Home, create, detail, chat, profile, settings…)
   - What's the primary user flow?
3. Decide the **visual language** (in `docs/design/TOKENS.md`):
   - Color palette direction (warm, cool, monochrome, etc.)
   - Typography pairing
   - Spacing rhythm
   - Iconography style (line, filled, custom)
4. Move directly into Phase 2 (tokens) to make these decisions concrete in code.

**Outcome:** A clear design intent written down before any pixels are committed to code.

**Note:** The HTML mockup stays in the repo at `goal_isle_working_mockup.html` as an archive of an earlier design exploration. It is **not** the reference for the Flutter app.

---

### Phase 2 — Establish design tokens in Flutter

**Goal:** Replace ad-hoc styling with a centralized token system. This is what makes future UI iteration fast.

**Steps:**
1. Create `lib/theme/tokens.dart` with:
   - Color palette (primary, secondary, surface, error, etc.)
   - Spacing scale (4, 8, 16, 24, 32, 48)
   - Typography (display, headline, title, body, label)
   - Border radii
   - Elevation values
2. Create `lib/theme/app_theme.dart` that builds `ThemeData` from tokens.
3. Replace hardcoded `Color(0xFF...)`, `withOpacity(0.5)`, and pixel values across `lib/` with token references.
4. Verify widget test still passes.

**Outcome:** Changing one color in `tokens.dart` updates the entire app on hot reload.

**Why this matters:** Without tokens, every visual change is a find-and-replace. With tokens, visual changes are one-line edits with instant preview.

---

### Phase 3 — Build the widget library

**Goal:** Extract repeated visual patterns into reusable widgets.

**Steps:**
1. Audit `lib/` for repeated patterns (cards, buttons, text fields, modal sheets, isle tiles).
2. Create `lib/widgets/` entries for each pattern (some may already exist).
3. For each widget, write a Widget Preview (Flutter 3.35+) to iterate on it in isolation.
4. Replace inline implementations with the new widgets.

**Outcome:** A library of composable widgets you can rearrange without rewriting layout code.

---

### Phase 4 — Screen-by-screen build

**Goal:** Build every screen in the Flutter app, using the new tokens and widgets. The HTML mockup is not a reference — the design comes from `docs/design/SCREENS.md` and your own taste.

**Steps:**
1. List every screen and modal in `docs/design/SCREENS.md` (already done).
2. For each screen, in order of user flow:
   - Open the Flutter screen file.
   - Build the layout using widgets from Phase 3 and tokens from Phase 2.
   - Use hot reload to tweak until the screen matches your intent.
   - Mark as "DONE" in `docs/design/SCREENS.md` when satisfied.
3. Start with the home screen (isles grid), then create flow, then isle detail, then chat, then friends.

**Outcome:** Every screen in `docs/design/SCREENS.md` has a working Flutter counterpart.

---

### Phase 5 — Interaction and motion

**Goal:** Add the things HTML can't show — gestures, animations, transitions.

**Steps:**
1. Identify interactions missing from the mockup:
   - Tap targets (mobile-first hit areas)
   - Drag-to-reorder
   - Pull-to-refresh
   - Page transitions (Hero animations between isle grid and detail)
   - Loading states
   - Empty states
2. Add `flutter_animate` or hand-roll `AnimatedContainer`/`Hero` transitions.
3. Test each interaction on a real mobile viewport via Chrome DevTools device emulation.

**Outcome:** The Flutter app feels alive in ways the HTML mockup can't.

---

### Phase 6 — User testing

**Goal:** Validate the look and feel with real usage before locking the design.

**Steps:**
1. Run the app on `flutter run -d chrome`.
2. Walk through every user flow end-to-end.
3. Note friction points in `docs/design/feedback.md`.
4. Tweak and retest until the feel is right.
5. Capture before/after screenshots for the record.

**Outcome:** A documented feel-test pass with a list of any remaining issues.

---

### Phase 7 — Lock the design, then make architecture decisions

**Goal:** Freeze UI/UX and make backend/platform decisions.

**Steps:**
1. Document the locked design in `DESIGN_LOCK.md` (palette, typography, spacing, motion principles, screen list).
2. Use this as the input for architecture decisions:
   - Backend (Supabase, Firebase, custom, local-only)
   - Platform target (web, mobile, both)
   - State management (Riverpod is already chosen — confirm)
   - Data models (already exist — adjust to match locked UI fields)
3. Implement features now that the design doesn't change underneath them.

**Outcome:** Architecture work proceeds without design churn.

---

## What NOT to do

- **Don't reference the HTML mockup as a design target.** It's an archive. The Flutter app defines its own look.
- **Don't add backend code, real auth, or real persistence during UI iteration.** Mock everything; this is the principle that kept the codebase shippable so far.
- **Don't introduce new dependencies for UI work.** If a package is needed, evaluate it after the design is locked. Adding `supabase_flutter` back was the cause of the white-screen bug.
- **Don't try to ship the Flutter app from this state.** It's not ready. The plan is to make it look right first.

---

## When to deviate from this plan

- **If a Flutter widget constraint makes a design impossible** (e.g., Material Design doesn't support a particular gesture natively): document the deviation in `docs/design/deviations.md` and propose an alternative. Don't silently redesign.
- **If hot reload stops preserving state** during heavy changes: use hot restart (`R` in terminal) or full restart, but don't go back to HTML mockups.
- **If you discover you need real data to evaluate a screen** (e.g., the chat feels wrong without real messages): extend the mock data in `IsleNotifier._loadMockData()` rather than wiring a backend.

---

## Workflow Setup (one-time)

### Enable hot reload on save in your editor

`.vscode/settings.json`:
```json
{
  "files.autoSave": "afterDelay",
  "dart.flutterHotReloadOnSave": "all"
}
```

### Add Flutter to PATH

```bash
echo 'export PATH="$PATH:/home/jasper/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Run command

```bash
cd /home/jasper/projects/goal_isle
flutter run -d chrome
```

Hot reload: press `r` in terminal, or save file in VSCode (if configured).  
Hot restart: press `R` in terminal.  
Quit: press `q`.

---

## Success criteria for this plan

The plan is successful when:

1. The Flutter app has a defined visual identity owned entirely by its own code.
2. The Flutter app's UI is exactly what you want it to be (vibe, screens, interactions).
3. The Flutter app feels correct on interaction (gestures, transitions, states).
4. You can change any visual aspect (color, spacing, font) by editing one token file.
5. No architecture decisions have been locked in yet — those happen in Phase 7.
6. `flutter test` still passes.
7. `flutter build web` still succeeds.
8. No new dependencies were added for UI work.

---

*Last updated: June 22, 2026.*