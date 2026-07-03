# Mockups — Goal Isle

**Date:** July 1, 2026

HTML/CSS mockups used for **design iteration only**. They are not part of the shipped app — they exist to eyeball look-and-feel before porting to Flutter.

The Flutter codebase is the source of truth for what ships. These mockups are scratchpads.

---

## How to Run

From the project root:

```bash
python3 -m http.server 8095
```

Then open in a browser:

| Mockup | URL | What it shows |
|---|---|---|
| **App Shell (connected flow)** | http://localhost:8095/docs/design/mockups/app.html | The full connected app shell: **Home** (floating sparks) ↔ **Notes** (chronological spark activity) ↔ **League** (emoji-based streak leaderboard). Swipe left/right on Home, or use the durable bottom nav. Profile avatar is persistent top-right. Includes Friends, Profile, App Settings, Spark Details, Spark Settings, New Spark, and Chat sub-flows. This is the current canonical interactive prototype. |
| **Create Spark** | http://localhost:8095/docs/design/mockups/create-spark.html | Standalone Create Spark reference. Superseded by the connected `app.html` flow; kept as isolated reference for the equation layout. |
| **Spark Details** | http://localhost:8095/docs/design/mockups/spark-details.html | The Spark Details screen (phone frame). The read-only **recipe / equation** (deps above `=`, main-emoji hero below) — each dep grey→fills as satisfied in chat; the hero lights when all deps are met (or, for a no-dep spark, when the main emoji is posted). Action card: Members · Chat (becomes the primary CTA "Light this spark" when dull) · Settings (creator only). **Interactive** — toggle dep satisfaction, streak, parked state, and creator/member access; plus a **static gallery** of variants (no-dep, parked, streaked-win, partial-fill). |
| **Chat (per-spark)** | http://localhost:8095/docs/design/mockups/chat.html | Standalone Chat reference. Superseded by the per-spark chat in `app.html`. |
| **Spark Details** | http://localhost:8095/docs/design/mockups/spark-details.html | Standalone Spark Details reference. Superseded by the expandable card in `app.html`. |
| **Shape Lab** | http://localhost:8095/docs/design/mockups/shape-lab.html | Interactive: drag the 4 corners live, compare all presets, and copy the exact Flutter/CSS values. |
| **Isle Sparks** | http://localhost:8095/docs/design/mockups/sparks.html | Quasi-circle shape, all four states (dull / lit / streaked / greyed), streak badge, Create Spark button, and a Home composition with sparks floating on the water. |
| **Buttons** | http://localhost:8095/docs/design/mockups/buttons.html | Button system (filled / outlined / text / icon / destructive), sizes, states, dark mode, design tokens. iOS-first, 2026 spec. |

---

## Notes

- **App Shell** (`app.html`) is now the canonical connected-flow prototype. It wires together all major surfaces: Home, Notes (formerly Chats), League, Chat, Spark Details, Spark Settings, New Spark, Friends, Profile, and App Settings. Key patterns demonstrated:
  - Durable **bottom nav** (Home / Notes / League) on the three main screens.
  - Durable **profile avatar** (top-right) everywhere that opens the You menu.
  - **Swipe left/right** on Home to reach Notes/League.
  - **Notes** shows a chronological list of all spark activity, full-width horizontal dividers, no status/streak noise.
  - **League** is a left-justified header with a switchable emoji (tap the hero spark) and a streak-length leaderboard for that emoji.
- **Create Spark** (`create-spark.html`) is now a standalone reference only. The connected `app.html` flow supersedes it.
- **Spark Details** (`spark-details.html`) is a standalone reference only. Its expandable-card form lives in `app.html`.
- **Chat** (`chat.html`) is a standalone reference only. The interactive per-spark chat is inside `app.html`.
- **Shape Lab** and the **Shape Picker** share the same preset set: Rhomboid squircle (default), Soft rhomboid, Squircle, Sharp-corner, Circle. Rhomboid squircle values: `tl 40 / tr 12 / br 40 / bl 12` (%).
- **Buttons mockup** has a dark-mode toggle (top-right) for previewing both themes.
- All mockups target iOS-first sizing (44×44 touch targets, system font stack).

---

## Relationship to the Spec

- Isle Spark behavior and states → see [`ISLE_SPARKS_SPEC.md`](ISLE_SPARKS_SPEC.md).
- Design tokens → see [`TOKENS.md`](TOKENS.md) (note: some new tokens for the spark shape/states are not yet defined there — see the spec's "Visual tokens to add" section).
- Screen inventory and gaps → see [`SCREEN_INVENTORY.md`](SCREEN_INVENTORY.md).

---

## Changelog

- **July 3, 2026** — Added `app.html` connected app shell with Home/Notes/League nav, durable profile avatar, Friends, Profile, App Settings, and all sub-flows.
- **July 3, 2026** — Renamed Chats screen to Notes.
- **July 3, 2026** — Made League switchable by emoji and left-justified; made Notes list full-width with horizontal dividers.
- **July 2, 2026** — Spark Details and Chat (per-spark) mocked; dependencies changed to single-occurrence / binary.
- **July 1, 2026** — Initial mockup set: Create Spark, Spark Details, Chat, Shape Lab, Buttons, Isle Sparks.
