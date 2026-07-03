# Screen Inventory — Goal Isle

**Date:** July 1, 2026
**Companion to:** [`ISLE_SPARKS_SPEC.md`](ISLE_SPARKS_SPEC.md) (🔒 locked) — this expands spec § 7 into a full mockup roadmap.

The spec § 7 names **8 screens**. A complete app needs more — auth, profile, app-level settings, edge-case flows. This doc enumerates **every** potential screen, marks which already have mockups vs. which are gaps, lists the state variations each screen needs, and flags the open design questions that must be decided before mocking.

This is the plan for the HTML/CSS mockup work: design every screen in HTML first, get the feel right, then port to Flutter.

---

## § 1 — What the Spec Already Names

From `ISLE_SPARKS_SPEC.md` § 7 screen-flow:

```
Home ─tap spark─► Spark Details ─┬─ Members ─► Member list
                                 ├─ Chat ────► Chat (per-spark)
                                 └─ Settings ► Spark Settings (creator only)
Home ─Create────► New Spark ─Shape► Shape Picker (sheet)
Home ───────────► Friends (low-impact)
Home ←swipe right─ Notes (chronological spark activity)
Home ─swipe left→ League (emoji-based streak ranking)
```

Eight named screens. The full inventory below adds the supporting + edge-case screens the spec implies but doesn't name.

---

## § 2 — Tier 1: Core

| # | Screen | What it does | Mockup? |
|---|---|---|---|
| 1 | **Home** | Floating sparks on water + Create button (bottom-right). Lit float, greyed sink. Empty state = just the Create button. | ✅ `mockups/app.html` |
| 2 | **New Spark (Create Spark)** | Equation hero + grouped icon-led settings card (shape / repeats / streak / share) + shape picker sheet. | ✅ in `mockups/app.html` |
| 3 | **Spark Details** | Recipe / equation (emojis grey → filled as satisfied), Members button, Chat button, Settings button (creator only). | ✅ in `mockups/app.html` |
| 4 | **Chat (per-spark)** | Room where members type / react emojis to light the spark. Shared across members. | ✅ in `mockups/app.html` |
| 5 | **Spark Settings (creator only)** | Member management (add / remove), shape (reopens picker), delete spark. | ✅ in `mockups/app.html` |
| 6 | **Member list** | Avatars, names, status (online / offline / last-seen) for a spark's Isle. | ✅ sheet in `mockups/app.html` |
| 7 | **Friends** | Friends list + add-by-username / phone requests. Global relationship (vs per-spark membership). | ✅ in `mockups/app.html` |
| 8 | **Notes** | Chronological list of all spark activity across sparks. Swipe right from Home or bottom nav. | ✅ in `mockups/app.html` |
| 9 | **League** | Global leaderboard for a selected emoji, ranked by streak length. Swipe left from Home or bottom nav. | ✅ in `mockups/app.html` |

---

## § 3 — Tier 2: Required Supporting (auth is mocked now but must be designed)

| # | Screen | Why it's needed | Mockup? |
|---|---|---|---|
| 8 | **Auth entry (Sign in / Sign up)** | Spec § 10: "Auth & identity — required for all social mechanics; currently mocked." Cannot share / create members without it. Entry point unknown (modal? first-launch?). | ❌ **Gap** |
| 9 | **Profile (own)** | See / edit own username, emoji identity, account. Where the user lands when they tap their own avatar — but spec says Home has **no avatars**, so profile entry is unclear. | ❌ **Gap** |
| 10 | **App Settings** | Theme, notifications, account, about, sign out. Standard app-level settings. | ❌ **Gap** |

> ⚠️ **Open design question (blocks #9, #10, and Friends entry):** Home has no headers, nav, or avatars (spec § 7). So **where are the entry points** for Friends, Profile, and App Settings? Options:
> - (a) a long-press or swipe gesture on Home;
> - (b) a minimal top-corner icon;
> - (c) accessed only from within a spark.
>
> This needs a decision before mocking Tier 2.

---

## § 4 — Tier 3: Edge-Case / Secondary Flows

| # | Screen | Why | Mockup? |
|---|---|---|---|
| 11 | **Invite-link landing** | Spec § 6: "Invite link (friendship-free path)." A non-member taps a link → needs a screen: "You're invited to [spark]. Join?" (auth gate if not signed in). | ❌ **Gap** |
| 12 | **Friend request (incoming)** | Accept / decline a friend request. Could be inline in Friends list, or its own sheet. | ❌ (part of Friends) |
| 13 | **Onboarding / first spark** | First-time user → empty Home → guided first spark creation? Spec § 7 says empty state = just Create button (no onboarding carousel). **Likely not needed** — confirm. | ❌ (likely **none**) |
| 14 | **Parked-spark recovery view** | A greyed / sunk spark tapped from Home → Spark Details showing its greyed state + "complete to relight." **Confirmed: same as Spark Details** in greyed state, not a separate screen — see the "Parked (missed)" variant in `mockups/spark-details.html`. | ✅ (state of #3) |

---

## § 5 — Tier 4: Shared Components / Sheets (not screens, but reused everywhere)

These are **bottom sheets or overlays** reused across multiple screens — design them once.

| # | Component | Used by | Mockup? |
|---|---|---|---|
| A | **Shape Picker** (bottom sheet) | New Spark, Spark Settings. Preset chips + per-corner sliders + live preview. Reshapes whole screen live. | ✅ inside `create-spark.html`; `shape-lab.html` is the dev tool |
| B | **Emoji Picker** | New Spark (main emoji + dependencies), Chat (typing / reacting). Need a unified picker. | ❌ **Gap** |
| C | **Reactions overlay** | Chat — long-press a message to react with an emoji. | ❌ (part of Chat) |
| D | **Member-add sheet** | Spark Settings, New Spark Share field. Search by username / phone + invite-link copy. | ❌ (part of #5, #2) |
| E | **Delete-confirmation sheet** | Spark Settings. "This deletes the spark for everyone" (creator-owned). | ❌ (part of #5) |
| F | **Button system** | Everywhere. | ✅ `mockups/buttons.html` |

---

## § 6 — State Variations to Design (same screen, multiple states)

When mocking, each screen needs its states mocked too:

| Screen | States |
|---|---|
| Home | Empty (just Create button) · 1 spark · many sparks · mix of lit + greyed (sunk) |
| Spark Details | Dull · Lit · Streaked (badge) · Greyed (parked) · no-deps spark · multi-dep spark (partial fill) · solo spark |
| Spark Details (access) | Creator view (has Settings) · Member view (no Settings) |
| Chat | Empty · messages flowing · a dependency just satisfied (spark lights — animation / feedback) — ✅ all covered live in `chat.html` (post / react deps to watch them light; "Spark lit" banner + mini-spark pulse) |
| New Spark | Empty (no main emoji) · main-emoji-only · with deps · with shape changed · invalid (Create disabled) |
| Friends | Empty · has friends · pending requests |

---

## § 7 — Summary: Mocked vs. Gap

**Already mocked:**
- Home — `app.html`
- Notes — `app.html`
- League — `app.html`
- New Spark — `app.html`
- Spark Details — `app.html`
- Chat (per-spark) — `app.html`
- Spark Settings + Member list — `app.html`
- Friends — `app.html`
- Profile — `app.html`
- App Settings — `app.html`
- Buttons — `buttons.html`
- Shape Lab — `shape-lab.html` (dev tool)

**Standalone reference files** (superseded by `app.html` but kept as isolated references):
- `create-spark.html`
- `spark-details.html`
- `chat.html`
- `sparks.html`

**Gaps to mock, in priority order:**

| Priority | Screen | Why this priority |
|---|---|---|
| 1 | ~~**Spark Details**~~ | ✅ Done in `app.html`. |
| 2 | ~~**Chat (per-spark)**~~ | ✅ Done in `app.html`. |
| 3 | ~~**Spark Settings + Member list**~~ | ✅ Done in `app.html`. |
| 4 | ~~**Friends**~~ | ✅ Done in `app.html`. |
| 5 | ~~**Emoji Picker**~~ | ✅ Picker sheets inside `app.html`. |
| 6 | ~~**Profile + App Settings**~~ | ✅ Done in `app.html`. |
| 7 | **Auth entry** | Needed before any social flow is real (spec § 10). |
| 8 | **Invite-link landing** | Edge case, can wait. |

---

## § 8 — Open Design Questions

1. ✅ **Entry points for Friends / Profile / App Settings** — resolved July 3, 2026: durable top-right avatar opens You menu; durable bottom nav on Home for Notes/League.
2. **Is there an onboarding screen**, or does the app open straight to empty Home? (spec leans: no onboarding)
3. **Does Profile have an avatar / emoji identity?** Currently a generic avatar; custom emojis are future (spec § 10).
4. **Auth entry point** — modal? first-launch gate? triggered only when a social action is attempted?
5. ✅ **Member list** — resolved as a bottom sheet off Spark Details (in `app.html`).
6. ✅ **Parked spark recovery view** — resolved July 2, 2026: same Spark Details, greyed state.

---

*Last updated: July 3, 2026 — connected app shell mocked; Notes + League added; entry points resolved.*
