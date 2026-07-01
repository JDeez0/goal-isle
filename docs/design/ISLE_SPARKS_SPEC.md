# Isle Sparks — System Specification

**Date:** July 1, 2026
**Status:** 🔒 LOCKED — single source of truth for the redesign
**Supersedes:** `docs/design/SCREENS.md`, the goal/sub-point/mass model in `docs/design/VISION.md` and `docs/design/TOKENS.md`, and the "no streaks" principle in `VISION.md`.

> This document defines the **new** Goal Isle. The Flutter codebase still reflects the **old** model (Isles/Goals/Sub-points/Mass) until the redesign is implemented. See the **Migration** section for the full map of what changes.

---

## 1. Mental Model

Goal Isle is a calm ritual app. The only objects that exist are **Isle Sparks** — small recurring commitments, each represented by a main emoji. A spark **lights up** when its members place its emoji-ingredients inside a shared chat. Lighting builds **streaks**; neglect greys a spark out and sinks it to the bottom.

> **An Isle = one spark + its members + its chat.** Every spark is its own little island of people. The word "Isle" is a live concept, not vestigial.

The whole point: **small recurring social rituals, visualized as glowing objects on the water.**

### What this reverses from the earlier vision

The original `VISION.md` said *"No streaks, no gamification noise."* The redesign **deliberately reverses** the streaks principle — streaks (and the streak badge + beach line) are now a core motivator. Everything else about "calm, minimal, clean/cool" still holds.

---

## 2. The Isle Spark (core object)

A small (0.5″ / 48px) **quasi-circular** button floating on the water.

### Shape
The silhouette is **user-chosen per spark** via a shape picker on the Create Spark screen (presets + per-corner sliders). The **default** for a new spark is the **rhomboid squircle**:
- Top-left & bottom-right corners **rounded** (40%), top-right & bottom-left corners **pointed** (12%) → a slight rhomboid.
- Stored as **four radius fractions** `{ tl, tr, br, bl }`, each `0–0.5` (0 = sharp, 0.5 = full quarter-circle), so it scales with spark size.
- Presets offered in the picker: **Rhomboid squircle** (default), Soft rhomboid, Squircle, Sharp-corner (the old quasi-circle: sharp TL, round rest), Circle.
- Flutter: `BorderRadius.only(topLeft/topRight/bottomLeft/bottomRight: Radius.circular(fraction * size))`.
- CSS (mockup): `border-radius: 40% 12% 40% 12%`.
- Shape is **cosmetic** (it does not affect behavior), so unlike the structural settings it **remains editable in Spark Settings** after creation. (Say the word if you'd rather lock it at creation only.)

### Identity
- **1 main emoji** — the spark's identity / "result." Future: custom emojis (so this field must stay a flexible identifier, not a hardcoded system-emoji char).
- **Optional title** — a free-text name. The main emoji alone is a valid identity (two sparks may share an emoji; position + title disambiguate).

### Dependencies ("ingredients")
- **0, 1, 2, or more dependency emojis**, set at creation.
- Each dependency has an **optional text label**.
- Each dependency has an **optional required count** (default **1**) — "unless specified otherwise on the Create Spark screen."
- Dependencies **cannot be edited after creation.**

### The five creation-time settings
1. **Timer mode** — instant (10s) / daily / weekly / monthly. *(creation-only)*
2. **Streak-breaks-on-miss** — boolean. Default **true** (a missed cycle resets streak to 0). User may choose "lenient" (streak freezes on a miss). *(creation-only)*
3. **Dependencies** (see above). *(creation-only, never editable)*
4. **Share** — invitees who become members at creation. *(members are editable later)*
5. **Shape** — silhouette, defaulting to **rhomboid squircle**. *(cosmetic — editable later in Settings; see Shape above)*

---

## 3. Visual States

A spark is always in exactly one primary state. Completion is driven entirely by emoji appearing in the spark's chat (see §5).

| State | Appearance | Meaning |
|---|---|---|
| **Dull** | Desaturated, muted surface | Not yet completed this cycle |
| **Lit** | Full-color + **barely-visible** sparkles | Completed this cycle |
| **Streaked** | Lit + streak number badge + squiggly "beach" line | Streak ≥ 2 |
| **Greyed** | Full grayscale, no shadow | Missed & parked; **sinks to bottom of Home** |

### Streak badge & beach line
- Appears only after **streak ≥ 2**.
- **Number badge** — top-right (the rounded side, away from the sharp corner). Grows **unboundedly**.
- **Beach line** — a thin squiggly stroke circumscribing the spark (the isle's beach). The line **barely changes** as the streak grows; only the number grows.

### Decay
- An uncompleted spark **fades grey evenly across the entire window** until it is due.
- When the window passes uncompleted → spark is **fully grey + parked at the bottom of Home**.
- It stays parked until completed again (at which point it relights).

---

## 4. Completion Mechanics

### Rules
- **No dependencies** → typing the **main emoji** in chat lights the spark.
- **Has dependencies** → the **main emoji is not needed in chat**; lighting requires **all dependency emojis** to be satisfied.
- A dependency is satisfied by **one occurrence** (typed in a message **or** reacted to a message), unless its `requiredCount` is higher.
- **Exact/definite match only** — no fuzzy, no substring. (Normalization for emoji ZWJ/skin-tone sequences is a future implementation detail; the rule is exact.)
- **Satisfaction resets each cycle** — dependencies must be re-earned every cycle.
- Lighting is **automatic** — no "claim" step.
- Progress is **shared** across all members (not per-user).

### Detection
- The spark's chat knows its own relevant emojis, so there is **no cross-spark confusion**.
- Both **message text** and **reactions** count.

---

## 5. Lifecycle

```
CREATED (dull)
   │   deps / main emoji matched in chat
   ▼
LIT  (full-color + sparkles)         streak +1
   │   cycle boundary hits
   ▼        (daily=midnight · weekly=Mon 00:00 · monthly=1st 00:00 · instant=+10s)
RESETS to DULL, satisfaction clears
   │
   ├── re-completed in window ──► LIT again, streak +1
   │
   └── window passes uncompleted ──► fades grey (even, across the window)
                                     FULLY GREY + SINKS TO BOTTOM
                                     parked until completed again
```

### Cycle boundaries
| Mode | Resets at |
|---|---|
| Daily | start of next day (midnight) |
| Weekly | Monday 00:00 |
| Monthly | 1st of month, 00:00 |
| Instant (10s) | 10 seconds after the last completion (or creation if never completed) |

### Deletion
- **There is NO auto-delete.** A missed spark only goes grey and sinks.
- Only the **creator** can delete a spark, from **Settings**.

---

## 6. Membership & Sharing

- Sharing a spark turns the invitees into **members of that Isle**, with **shared progress**.
- Invite paths:
  - Direct invite to an **already-accepted friend** (by **username** or **phone number**).
  - **Invite link** (friendship-free path).
- Members can be **added or removed after creation** (creator, via Settings).
- If a member **leaves**, the rest of the Isle is unaffected.
- **Ownership is creator-held.** If the creator leaves, the spark expires, or the creator deletes it → **the spark vanishes for everyone.**

> ⚠️ Every social feature above **requires real identity / auth**. Auth is currently mocked. The social mechanics cannot be truly tested until identity exists. For mock/design work, assume a single mock user + mock members.

---

## 7. Screens

```
Home (only floating sparks + Create Spark button, bottom-right)
  │
  ├─ tap spark ──► Spark Details
  │                  • Recipe/equation (emojis greyed → fill in as satisfied)
  │                  • Members button  → full member list (avatar, name, status)
  │                  • Chat button
  │                  • Settings button (creator only) → members, shape, delete
  │                  └─ chat ──► Chat Screen (per-spark room)
  │
  └─ Create Spark (bottom-right) ──► New Spark screen
                                       • Equation builder
                                       • Timer picker · streak-breaks-on-miss toggle
                                       • Shape picker (default rhomboid squircle)
                                       • Share field
                                       • Cancel + Create (enabled once main emoji chosen)
```

### Home
- **Only** floating Isle Sparks on the water. No headers, no nav bar, no avatars.
- **Lit/active sparks float; greyed-missed sparks sink to the bottom.**
- **Create Spark button** — bottom-right: a dashed silhouette of the spark shape with a cartoonish grey question mark. Opens the New Spark screen.
- Empty state: only the Create Spark button visible.

### Spark Details
- **Recipe / equation** — the main emoji sits below an `=`; dependencies sit above. **Each emoji is greyed until its condition is met** (dependencies: until used in chat this cycle; main emoji: until the spark is lit). This *is* the completion-status visualization.
- **Members button** → member list (avatars, names, status).
- **Chat button** → the spark's chat room.
- **Settings button** (creator only) → member management, delete spark.

### Chat (per-spark)
- The room where members **type** emojis and **react** to messages to satisfy dependencies / light the spark.
- Shared across all members.

### New Spark (Create Spark screen)
> **Design language (locked):** icon-led, **no noun section headers**. Each setting is identified by an icon (or the shape itself) inside one grouped card — not by a word like "Shape" / "Repeats" / "Streak" / "Share". Only **verb** chrome remains (Cancel / Create).

- **The equation is the hero.** Dependencies sit **above** the `=`; the **main emoji** is the large focal spark **below** it (top→down reads: ingredients = result). Tiny **content** labels may sit under each dependency (those are values the user types, not headers).
- **Grouped settings card**, one icon-led row each (see mockup `create-spark.html`):
  - **Shape** — the row's icon is a **live mini spark** of the current silhouette; value = the preset name. Tapping opens the **Shape picker** (iOS bottom sheet: preset chips + per-corner sliders + large live preview). **Default = rhomboid squircle.** Changing the shape **reshapes the whole screen live** (hero, ingredient chips, mini preview, buttons all share one silhouette).
  - **Repeats** — clock icon; value = timer mode (instant / daily / weekly / monthly).
  - **Streak** — flame icon + toggle; short verb-phrase ("Breaks on miss") is allowed since a bare flame+toggle is ambiguous.
  - **Share** — user-plus icon; value/placeholder = members or invite.
- **Dependencies** — spark-shaped chips (`[emoji]` + optional per-dep required-count) with an `+ add` chip.
- **Top bar:** `Cancel` (left) + `Create` (right). **No center title.** Create is **disabled until the main emoji is chosen**.

### Friends (low-impact)
- A friends list + the ability to **add friends by username or phone-number request**.
- Friendship is a **global** relationship; **membership** is **per-spark**.

### Spark Settings (creator only)
- Member management (add/remove).
- **Shape** (cosmetic — reopens the same shape picker).
- Delete spark.

---

## 8. Data Model — Migration

The current model reflects the **old** system. Below is the change map.

### `isle.dart` → `Spark`
| Field | Action |
|---|---|
| `id`, `mainEmoji`, `createdBy`, `createdAt`, `updatedAt`, `settings` | ✅ Keep |
| `name` | ⚠️ Keep, make **optional** (title) |
| `mass` | ❌ **Delete** (dead concept) |
| *new* `title` (optional) | ➕ (= the optional name) |
| *new* `timerMode` | ➕ instant/daily/weekly/monthly (first-class, not buried in settings) |
| *new* `streakBreaksOnMiss` | ➕ bool (default true) |
| *new* `streak` | ➕ int |
| *new* `lastCompletedAt` | ➕ DateTime |
| *new* `cycleDueAt` | ➕ DateTime (drives fade + cycle reset) |
| *new* `members` | ➕ list (see new Membership model) |
| *new* `dependencies` | ➕ relation (see Dependency) |
| *new* `shape` | ➕ `{ tl, tr, br, bl }` four radius fractions `0–0.5`; default rhomboid squircle `{0.4, 0.12, 0.4, 0.12}` |

### `sub_point.dart` → `Dependency`
| Field | Action |
|---|---|
| `id`, `emoji` | ✅ Keep |
| `description` | ✅ Keep → repurpose as **label** |
| `fillCount`, `fillHistory`, `lastFilledAt` | ✅ Keep — repurpose as **"used in chat" tracking** (powers the grey→filled detail view) |
| `goalId` | ❌ **Delete** (no goals) → reparent to `sparkId` |
| *new* `requiredCount` | ➕ int, default 1 |

### `goal.dart` → ❌ Delete entirely
The middle layer is gone.

### `friend.dart` → ✅ Keep
Models the friend**request** (userId/friendId/status). Still needed for the low-impact friends list. (Friendship = global; Membership = per-spark — a separate concept.)

### `message.dart` → ✅ Keep (minor)
- Keep: `id`, `senderId`, `content`, `reactions`, `createdAt`.
- `reactions` already exists → perfect for the react-to-complete mechanic.
- Rename `isleId` → `sparkId` (conceptual).

### ➕ NEW: `Membership` model
A spark ↔ user membership relation. **Currently does not exist anywhere in the codebase** — this is the biggest structural gap. Needs at minimum: `sparkId`, `userId`, `role` (creator/member), `joinedAt`.

### ❌ Delete — extraneous / out of scope
| File | Reason |
|---|---|
| `models/media.dart` | Image/video model, but `image_picker`/`video_player` were deliberately removed. Chat is text + emoji + reactions only. |
| `models/content_report.dart` | Full moderation platform — out of scope for a calm friends-only app. |
| `models/user_block.dart` | Same — moderation, out of scope. |
| `widgets/mountain_visual.dart` | Mountain concept removed (confirmed). |
| `widgets/sparse_lines_background.dart` | Contradicts calm-water vision; Home is only floating sparks. |
| `widgets/spark_button.dart` (old) | Old 120×120 gradient ✨ design — nothing matches new Create button. Rewrite as `CreateSparkButton`. |
| `screens/main/main_screen.dart` **or** `main_screen_safe.dart` | Redundant pair — keep one, delete the other. |

---

## 9. UI Components to Build

| Component | Notes |
|---|---|
| `IsleSpark` widget | Renders main emoji with the spark's stored `shape`; switches among dull/lit/streaked/greyed states. Default shape = rhomboid squircle |
| Sparkles overlay | Tiny, low-opacity gold `✦` glyphs ("barely visible") |
| Streak badge | Blue pill, top-right, unbounded number |
| Beach line | Squiggly circumscribing stroke (SVG/CustomPainter), thin, warm-sand tone |
| `ShapePicker` | Bottom-sheet UI: preset chips + 4 per-corner sliders + live preview; used on New Spark screen **and** Spark Settings |
| `CreateSparkButton` | Dashed quasi-circle silhouette + grey `?`, bottom-right |
| New Spark screen | Equation (deps above `=`, main emoji as focal hero below) + grouped icon-led settings card (shape/repeats/streak/share) + shape picker sheet — see `create-spark.html` |
| Recipe viewer (Spark Details) | Equation with per-emoji grey→filled state |

### Visual tokens to add (not yet in `TOKENS.md`)
- Default spark shape: rhomboid squircle `{tl:0.4, tr:0.12, br:0.4, bl:0.12}` (shape itself is per-spark / user-chosen, so this is a *default*, not a fixed token).
- Dull/desaturation treatment; sparkle styling; beach-line stroke; streak-badge styling.

### Progress/mass tokens (`progressEmpty`/`progressFilled`) → now orphaned
Tied to the deleted mass/progress-bar concept. Re-purpose only if the grey-fade needs them (likely not — fade is desaturation, not bar fill).

---

## 10. Open / Forward-Looking

- **Custom emojis** — future system for creating custom main-emoji identities. Main-emoji field must stay a flexible identifier.
- **Auth & identity** — required for all social mechanics; currently mocked.
- **Emoji-match normalization** — exact-match is the rule; normalization for variant sequences is an implementation detail to settle during build.
- **Friends vs. invite-link flow at creation** — if a creator shares during creation with someone who is not yet a friend, the invite-link path is the fallback (minor flow detail).

---

## 11. Reference Mockups

HTML/CSS mockups for design iteration (served locally, not shipped to users):

| File | Shows |
|---|---|
| `docs/design/mockups/sparks.html` | Isle Spark shape, all four states, streak/beach detail, Create button, Home composition |
| `docs/design/mockups/shape-lab.html` | Interactive shape lab: drag the 4 corners live, compare presets, get the exact Flutter/CSS values |
| `docs/design/mockups/create-spark.html` | The **Create Spark screen** (phone frame) — icon-led, noun-header-free design language; equation hero; grouped settings card; **Shape picker** bottom sheet that reshapes the whole screen live (default = rhomboid squircle) |
| `docs/design/mockups/buttons.html` | Button system (filled/outlined/text/icon/destructive) — iOS-first, 2026 spec |

See `docs/design/MOCKUPS.md` for how to run them.

---

*Last updated: July 1, 2026.*
