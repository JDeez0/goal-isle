# Isle Keys — System Specification v2

> 🔑 **Terminology note (July 4, 2026):** The core object is now called an **Isle Key** (was "Isle Spark"). The two terms are **fully interchangeable** throughout this project — "spark" remains a valid synonym and appears throughout earlier docs and code. A key is **"turned"** or **"lit"** when its condition is met, but per the Language Principle below, **neither word appears in the UI** — the user only sees the visual state change. This document keeps the body text as-written ("spark") for readability; read "spark" as "key" everywhere. The codebase will standardize on `Key`/`keys` during the Flutter migration.

**Date:** July 3, 2026
**Status:** 🔒 LOCKED v2 — single source of truth for the redesign
**Supersedes:** `ISLE_SPARKS_SPEC.md` (v1). v1 is retained as the historical locked record but is no longer the governing spec.

> 📝 **Why v2 exists:** The product gained a **wedge** — college grads studying for the LSAT — which surfaced use cases v1 could not express (score-tracking rituals, one-off acceptances broadcast to cohorts, discoverable communities, camera-image proof). Seven axes were re-decided (Isle-as-community, hybrid lighting, shared+personal scope, ritual+metric modes, per-Isle+per-Spark chat, Posts as a distinct object, public+private Isles). v2 also adopts a governing language principle v1 lacked.

---

## 0. The Language Principle (governs all UI text)

The app speaks in **two nouns** and a **handful of plain verbs**. Everything else is communicated through the **visual state of the keys themselves**.

**Allowed nouns:** Isle, Key (legacy synonym: "Spark" — both are valid). (These are the product's core concepts and cannot be avoided.)
**Allowed verbs:** Done, Log, Create, Join, Share, Add, Remove. (Plain words for actions the user is actually performing.)
**Banned from UI text:** "light," "ritual," "metric," "mode," "scope," "window," "cycle," "dependency," "ingredient," "territory," "membership," "mass," "fill." These are internal/developer vocabulary.

The principle: **show, don't tell.** A spark that meets its condition brightens — there is no "Light it!" button, no "Your spark lit!" banner. The mechanic is visual. Where a confirmation step is required, it is wordless (a pulse + the spark's own emoji, never the word "light").

This is a hard rule. Every mockup and screen below must obey it.

---

## 1. Mental Model

Goal Isle is a calm ritual app for **small communities**. A user belongs to one or more **Isles** (communities). Inside each Isle, members share **Keys** (small recurring rituals — legacy name "Sparks"; the terms are interchangeable) and **Posts** (one-off moments).

- An **Isle** = a community: a persistent group with its own identity, members, chat, and set of keys. "Harvard Law admitted 2026," "my LSAT study group," "morning runners."
- A **Key** (was "Spark") = a recurring ritual that lives inside an Isle. A key is **turned** (or **lit** — interchangeable) when its members complete it; the user only ever sees the visual state change, never these words.
- A **Post** = a one-off broadcast (an acceptance, a result screenshot, a question) that can go to one Isle, several, or all of them.

> The name "Isle" is both metaphor and literal: on Home, each Isle appears as a soft colored region on the water, with its sparks floating on it.

### What this reverses from v1

v1 said *"An Isle = one spark + its members + its chat."* **v2 separates the Isle (community) from the Spark (ritual).** An Isle now contains *many* sparks, its own chat, and its own feed. This is the foundational structural change.

---

## 2. Objects

### Isle (community)

| Field | Notes |
|---|---|
| `id` | |
| `name` | Free text. |
| `mainEmoji` | The Isle's identity. |
| `purpose` | One-line description (optional). |
| `color` | **Creator-chosen** from a fixed swatch row of ~8 curated calm hues. Powers the Home territory tint. |
| `visibility` | `public` \| `private`. Public Isles are discoverable via search; private are invite-only. |
| `createdBy` | Owner. |
| `createdAt` | |

An Isle contains: its **Members**, its **Sparks**, its **Posts**, one **Isle chat room**, and its **feed** (posts + spark activity for this Isle).

### Spark (ritual)

| Field | Notes |
|---|---|
| `id` | |
| `isleId` | Which Isle it belongs to. |
| `mainEmoji` | The spark's identity / result. |
| `title` | Optional free-text name. |
| `mode` | `ritual` \| `metric` (see §4). |
| `scope` | `shared` \| `personal` (see §5). |
| `shape` | `{ tl, tr, br, bl }` four radius fractions `0–0.5`; default rhomboid squircle `{0.4, 0.12, 0.4, 0.12}`. Cosmetic; editable in Spark Settings. |
| `state` | `dull` \| `lit` \| `streaked` \| `greyed`. Per-member if `personal`. |
| `streak` | int. Per-member if `personal`. |
| `lastCompletedAt` | DateTime. |
| `cycleDueAt` | DateTime — drives fade + cycle reset. |
| `timerMode` | `instant` \| `daily` \| `weekly` \| `monthly`. Creation-only. |
| `streakBreaksOnMiss` | bool, default true. Creation-only. |
| `dependencies` | 0+ dependency emojis (ritual mode only). Creation-only, never editable. |
| `metric` | If `mode == metric`: `{ template, target, unit }` (see §6). Creation-only. |
| `members` | Inherited from the Isle (all members participate). |

### Post (one-off broadcast) — NEW

| Field | Notes |
|---|---|
| `id` | |
| `author` | |
| `body` | text \| image \| emoji (image re-introduces camera capture — see §11). |
| `audience` | `[isleId, ...]` or `'all'`. The audience picker. |
| `createdAt` | |

Posts land in each chosen Isle's feed and surface in the cross-Isle **Notes** feed.

### Membership — NEW

| Field | Notes |
|---|---|
| `isleId` | |
| `userId` | |
| `role` | `creator` \| `member` |
| `joinedAt` | |

Membership scopes to an **Isle**, not a spark (v1 scoped it to a spark — that model is gone).

### Message

Kept from v1. Lives in a chat (either the Isle room or a per-Spark thread). Carries `id`, `senderId`, `content`, `reactions`, `createdAt`. May carry an image (Posts and metric proof).

### Friend

Kept from v1. Models the friend**request** (userId/friendId/status). Friendship is a **global** relationship; **membership** is **per-Isle**.

---

## 3. Spark Visual States

Unchanged from v1 — the visual treatment is the part that survived intact.

| State | Appearance | Meaning |
|---|---|---|
| **Dull** | Desaturated, muted surface | Not yet completed this cycle |
| **Lit** | Full-color + barely-visible sparkles | Completed this cycle |
| **Streaked** | Lit + streak number badge | Streak ≥ 2 |
| **Greyed** | Full grayscale, no shadow | Missed & parked; sinks to bottom |

### Streak badge
Appears after streak ≥ 2. Number badge, top-right (the rounded side). Grows unboundedly.

### Decay
An uncompleted spark fades grey evenly across the window until due. When the window passes uncompleted → fully grey + parked at the bottom of its Isle's Home territory. Stays parked until completed again.

---

## 4. Spark Modes — Ritual vs. Metric

A spark lights by one of two paths.

### Ritual mode (the common case)
Lights by doing/confirming the thing. Dependencies (0+ emojis) are satisfied by a **single occurrence** of each emoji in chat (one typed message **or** one reaction) — binary, not-yet / satisfied, no per-dependency count. No dependencies → typing the **main emoji** lights it. This is v1's mechanic, unchanged.

### Metric mode (the LSAT-wedge case)
Lights by posting a **number** that meets a **rule** over a **window**. The rule is evaluated at window close. See §6 for the engine. The primary action on a metric spark is **"Log"** (enter number + optional photo), not a chat emoji.

> Both modes end in the same visual states and feed behavior. Ritual sparks are lit *in* the chat; metric sparks are lit *at* the spark.

---

## 5. Spark Scope — Shared vs. Personal

| Scope | Meaning | Example |
|---|---|---|
| **Shared** | One group-wide progress state. All members contribute to one completion. | "Everyone studied 2 hrs today" |
| **Personal** | Each member has their own instance + streak. | "My weekly average improved" — the LSAT hero |

For Personal sparks: each member's entries/scores are tagged to them. The spark shows per-member mini-progress (small trend arrows next to each name) inside Spark Details. On Home, a Personal spark shows **only your instance** by default (your streak, your lit/greyed state); other members' states are revealed by tapping a **visible expand chevron** on the spark.

---

## 6. The Metric Engine

Calculated lighting **without a rules engine.** The user never sees "template," "aggregation," or "rule." They answer two plain-language questions at creation; the answers secretly set mode, scope, template, and target.

### Creation — two questions

**Q1 — "What kind of spark?"**
- "We all do a thing together" → `ritual / shared`
- "Each of us does a thing" → `ritual / personal`
- "Our numbers go up" → `metric / shared`
- "My numbers go up" → `metric / personal`

**Q2 (metric only) — "What counts?"**
- "Just doing it" → **count of actions** in window ≥ target (e.g. "did 3 timed sections")
- "How much in total" → **sum** in window ≥ target (e.g. "studied 10 hrs")
- "A score or average" → **avg of entries this window** > **avg of previous window** (e.g. weekly PT average improved) ← the LSAT hero
- "Hitting a goal number" → **any entry** ≥ threshold (e.g. "broke 170")

That is the entire engine: **four templates**, each a single comparison at window close. The target/threshold is a plain number input. No operators, no custom formulas. If a use case cannot be phrased as one of these four, it is out of scope — that boundary is what keeps it from becoming a rules engine.

### Window
The window maps to the existing `timerMode` (instant / daily / weekly / monthly). The "average vs previous window" template needs **two** consecutive windows of data to evaluate, so it is grey/dull for its first window by definition — creation shows a one-line explainer.

### Lighting (hybrid — the decided mechanic)
At window close, the engine evaluates the rule against that window's entries:

```
window closes
  ├─ rule met → wordless prompt:
  │              ├─ the spark pulses on Home + its emoji appears as a row in Notes
  │              ├─ shared:   first member to confirm (tap the pulsing spark) completes it
  │              └─ personal: the member confirms their own
  │              └─ on confirm: LIT, streak +1, celebration ripple (no text)
  │
  └─ rule not met / unconfirmed at close → missed
                                              → fades grey, sinks to bottom of its Isle territory
                                              → streak resets (if streakBreaksOnMiss)
```

There is **no "Light it?" text anywhere.** The prompt is a visual pulse + a Notes row. This is the deliberate social moment — the reason hybrid beats pure auto-light.

---

## 7. Lighting — Ritual path (unchanged from v1, restated for completeness)

- **No dependencies** → typing the main emoji in chat lights the spark.
- **Has dependencies** → the main emoji is not needed; lighting requires all dependency emojis to be satisfied (one occurrence each).
- Exact/definite match only — no fuzzy, no substring.
- Satisfaction resets each cycle.
- Lighting is automatic — no claim step, no confirm. (Ritual sparks do *not* use the hybrid prompt; only metric sparks do.)
- Progress is shared across members (for shared scope).

---

## 8. Lifecycle

```
CREATED (dull)
   │   ritual: deps / main emoji matched in chat
   │   metric:  rule met at window close + confirmed
   ▼
LIT (full-color + sparkles)         streak +1
   │   cycle boundary hits
   ▼        (daily=midnight · weekly=Mon 00:00 · monthly=1st 00:00 · instant=+10s)
RESETS to DULL, satisfaction clears
   │
   ├── re-completed in window ──► LIT again, streak +1
   │
   └── window passes uncompleted ──► fades grey (evenly, across the window)
                                     FULLY GREY + SINKS TO BOTTOM of its Isle territory
                                     parked until completed again
```

### Deletion
- **No auto-delete.** A missed spark only goes grey and sinks.
- Only the **creator of the Isle** can delete a spark, from Spark Settings.
- Deleting an Isle (creator only) removes it for everyone.

---

## 9. Home — The Signature Screen

Home shows **all the user's active sparks, grouped by Isle, on the water.**

### The three layout laws (what keeps it calm)

1. **Territories are regions, not shapes.** Each Isle owns a soft **tinted region** of the water — a faint rounded wash of the Isle's `color`, no hard coastline, no landmass drawn. Sparks float *within* their Isle's region.
2. **Only active Isles appear.** Home shows only Isles that have at least one spark (active or greyed). An Isle with zero sparks is reached via the Isles index, not Home. This caps visual density to "however many communities you're actively ritualling in" — for most users, 2–4.
3. **Within a region, float/sink physics apply unchanged.** Lit sparks rise to the top of their region; greyed ones sink to the bottom of their region. Poisson-disk dispersion places them without overlap, constrained to the region's bounding box. Regions are laid out once (deterministic packed layout) and stay stable across sessions; a new active Isle animates its region in.

### Density cap
If a user is in many active Isles (say 8+), Home collapses to the top few regions + an "all Isles" chip. Prevents polka-dot water.

### What you tap
- **Tap a spark** → Spark Details.
- **Tap empty water in a region** (or the Isle's small label chip) → that Isle's Home (drill-in to the community layer).
- **Create button** — bottom-right, dashed silhouette + grey `?`. Unchanged from v1.
- **Personal spark expand chevron** — visible on the spark; tap to fan out per-member mini-cluster.

### Home has
No headers, no nav bar (the durable bottom nav lives here per the existing app shell: Home / Notes / League), no avatars except the persistent top-right profile avatar that opens the You menu.

---

## 10. Screens

```
HOME (all my sparks, grouped on Isle territories)
   ├─ tap spark ──► Spark Details
   ├─ Create ────► New Spark (lives in current Isle; plain-language type picker)
   ├─ Post ──────► Post Composer (image/text/emoji + audience picker)
   ├─ tap region ─► ISLE HOME (community: its sparks · feed · chat · members)
   │                 ├─ Isle chat room (the socializing space)
   │                 ├─ tap spark ─► Spark Details + per-Spark thread
   │                 └─ (creator) Isle Settings: members, join policy, color, delete
   └─ bottom nav: Home · Notes · League   (durable)

NOTES  — chronological feed: Posts (acceptances, results, questions) + spark activity, across all Isles
LEAGUE — rankings: streak leaderboards + metric-spark rankings, switchable by emoji
ISLES  — index of your communities (entry to Discover/Search)
```

### Spark Details
- **Recipe / equation** (ritual): main emoji below an `=`; dependencies above; each greyed until satisfied.
- **Metric panel** (metric): the spark's number entries for the window, per-member trend arrows (personal), the target/threshold.
- **Primary action:** **"Done"** (ritual) or **"Log"** (metric: number + optional photo).
- **Members** button → member list (sheet).
- **Thread** button → the per-Spark thread (focused log/proof/reactions room).
- **Settings** (Isle creator only) → shape, delete.

### New Spark (Create Spark screen)
The equation is the hero (unchanged visual language from v1). The grouped icon-led settings card gains the **plain-language type picker** (§6's two questions) for metric sparks. Shape picker (default rhomboid squircle), timer, streak-break toggle, share — all retained from v1.

### Post Composer — NEW
- Body: text / image / emoji.
- Image capture re-introduces camera (see §11).
- **Audience picker:** one Isle / several / all. This is a new mental model ("post to *these* communities") and must feel obvious.

### Metric Log sheet — NEW
Off a metric spark: number input + optional photo. Entries go to the per-Spark thread.

### Discover / Search — NEW
Find public Isles by school, by emoji, by name. Join / request-to-join flow. This is the **network-effect surface** — where cohort identity ("Harvard Law 2026") becomes findable and the wedge spreads.

### Friends, Profile, App Settings
Retained from the existing app shell. Profile is **free-form** (name, emoji, bio) — structured fields (target school, test date, score range) deferred. Cohort-finding happens through Isle membership, not profile filtering, for now.

---

## 11. Image Policy — AMENDED

v1 said *"chat is text + emoji + reactions only"* and `image_picker`/`video_player` were removed during the Flutter-web debugging saga. **v2 re-introduces images**, bounded:

- **Posts** may carry an image (acceptance screenshots, results pages, questions, faces).
- **Metric Log** entries may carry an optional photo (proof of a score).
- Chat remains primarily text + emoji + reactions; images enter via Posts and metric proof, not as a general chat attachment.

> ⚠️ **Technical risk:** `image_picker` was removed because its web plugin caused bootstrap null-check errors (see `FLUTTER_DEBUG_LOG.md`). Re-introducing it on web must be **de-risked early** — verify it's re-addable, or scope Posts/images to mobile-first and gate on web. This decision affects the Flutter implementation plan, not the design.

---

## 12. Membership, Sharing & Discovery

### Sharing a spark's Isle
- Invitees become **members of the Isle** (not of a single spark).
- Invite paths: direct invite to an accepted friend (username / phone), or invite link (friendship-free).
- Members can be added/removed by the Isle creator.

### Public vs. private Isles
- **Private** (default for friend groups): invite-only. Not searchable.
- **Public** (for cohorts): discoverable via search. Anyone can find and join (or request to join).
- `visibility` is set at creation; the creator can toggle it in Isle Settings.

### Ownership
Isle ownership is creator-held. If the creator deletes the Isle, it vanishes for everyone.

### Every social feature requires real identity / auth
Auth is currently mocked. Social mechanics cannot be truly tested until identity exists.

---

## 13. Moderation

Bare minimum for launch (public Isles make this necessary):

- Any member can **Report** a post, spark, or Isle.
- The **Isle creator** reviews reports and removes content/members.
- No dedicated moderators, no trust-and-safety team, no automated filtering.
- This is the lightest viable loop for a friends-first app.

---

## 14. Data Model — Migration (from current Flutter code)

The current code reflects the **old** model (Isles/Goals/Sub-points/Mass). v2's migration supersedes v1's §8.

### `isle.dart` → `Isle` (community)
Keep: `id`, `mainEmoji`, `createdBy`, `createdAt`, `updatedAt`.
Change: `name` stays; drop `mass`. 
Add: `purpose` (optional), `color` (curated swatch value), `visibility` (`public`/`private`).
Reparent: Isle now **contains** sparks (one-to-many), rather than being one.

### `goal.dart` → ❌ Delete entirely
The middle layer is gone (was true in v1 too).

### `sub_point.dart` → `Dependency` (ritual mode only)
Keep: `id`, `emoji`, `description` (→ label), `fillCount`/`fillHistory`/`lastFilledAt` (→ "used in chat" tracking).
Delete: `goalId` → reparent to `sparkId`.
Not added: `requiredCount` (single-occurrence binary, per v1's July 2 change).

### ➕ NEW: `Spark` (was partly `isle.dart`)
The ritual object. Fields per §2. This is the big new model — mode, scope, metric, per-member state.

### ➕ NEW: `Post`
Per §2. Author + body + audience.

### ➕ NEW: `Membership`
Per §2. `isleId` / `userId` / `role` / `joinedAt`. (v1 put this at the spark level; v2 puts it at the Isle level.)

### `message.dart` → ✅ Keep (minor)
Keep `id`, `senderId`, `content`, `reactions`, `createdAt`. Rename `isleId` → `chatId` (scoped to either the Isle room or a per-Spark thread). May carry image.

### `friend.dart` → ✅ Keep
Unchanged.

### ❌ Delete — extraneous / out of scope
`models/media.dart`, `models/content_report.dart`, `models/user_block.dart`, `widgets/mountain_visual.dart`, `widgets/sparse_lines_background.dart`, old `widgets/spark_button.dart`, one of `main_screen.dart` / `main_screen_safe.dart`. (Same as v1.)

---

## 15. UI Components to Build

| Component | Notes |
|---|---|
| `IsleSpark` widget | Renders main emoji with stored `shape`; switches among dull/lit/streaked/greyed. Default rhomboid squircle. (Retained from v1.) |
| `IsleTerritory` widget | The soft tinted region on Home; constrains spark dispersion to its bounds. **NEW.** |
| `CreateSparkButton` | Dashed silhouette + grey `?`. (Retained.) |
| `ShapePicker` | Bottom sheet: preset chips + 4 sliders + live preview. (Retained.) |
| **Plain-language type picker** | The 2-question flow (§6) for mode/scope/template. **NEW.** |
| **MetricLogSheet** | Number + optional photo, off a metric spark. **NEW.** |
| **PostComposer** | Image/text/emoji + audience picker. **NEW.** |
| **PersonalSparkCluster** | The expandable per-member mini-cluster, triggered by the visible chevron. **NEW.** |
| **ConfirmPulse** | The wordless hybrid prompt (pulse + Notes row). **NEW.** |
| **Discover/Search** | Find public Isles; join flow. **NEW.** |
| **IsleHomeScreen** | The community drill-in. **NEW.** |
| **Per-Spark thread** | Scoped chat under a spark. **NEW.** |
| Recipe viewer (Spark Details) | Equation with per-emoji grey→filled state. (Retained, extended for metric.) |

### Isle color system
A fixed swatch row of ~8 curated calm hues, chosen by the Isle creator at creation. Not random, not derived — curated to stay on-brand and prevent clashing/neon.

### Visual tokens still to add (from v1, unchanged)
Default spark shape (rhomboid squircle); dull/desaturation treatment; sparkle styling; streak-badge styling.

---

## 16. Open / Forward-Looking

- **Auth & identity** — required for all social mechanics; currently mocked.
- **Custom emojis** — future system for custom main-emoji identities.
- **Emoji-match normalization** — exact-match is the rule; variant-sequence normalization is an implementation detail.
- **Structured profile fields** — deferred (target school, test date, score range) for cohort-filtering in a future release.
- **Image picker on web** — must be de-risked before depending on it (see §11).
- **Notifications strategy** — currently in-app only, wordless. System push is a future decision.
- **Moderation scaling** — report + creator-removes is the minimum; appointed moderators are a future option if public Isles grow large.

---

## 17. Reference Mockups (status after v2)

Existing mockups in `docs/design/mockups/` reflect **v1**. They need v2 updates:

| Mockup | v2 change needed |
|---|---|
| `app.html` Home | 🔴 Rebuild as territory layout |
| `app.html` New Spark | 🔴 Add plain-language type picker |
| `app.html` Spark Details | 🟡 Add metric panel + Log action + thread entry |
| `app.html` Notes | 🟡 Add Posts |
| `app.html` League | 🟢 Add metric rankings |
| `app.html` Chat | 🟢 Repurpose as Isle room; add per-Spark thread |
| — | ➕ **NEW mockups:** Isle Home, Discover, Post Composer, Metric Log sheet |

The two highest-risk new surfaces to mock first (most likely to feel wrong and need iteration): **Home-with-territories** and **New-Spark type picker**.

---

*Locked July 3, 2026 — v2. Governs all design and implementation going forward. v1 retained for history.*
