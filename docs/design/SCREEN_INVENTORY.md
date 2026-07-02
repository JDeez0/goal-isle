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
```

Eight named screens. The full inventory below adds the supporting + edge-case screens the spec implies but doesn't name.

---

## § 2 — Tier 1: Core (explicitly in spec, must exist)

| # | Screen | What it does | Mockup? |
|---|---|---|---|
| 1 | **Home** | Floating sparks on water + Create button (bottom-right). Lit float, greyed sink. Empty state = just the Create button. | ✅ `mockups/sparks.html` |
| 2 | **New Spark (Create Spark)** | Equation hero + grouped icon-led settings card (shape / repeats / streak / share) + shape picker sheet. | ✅ `mockups/create-spark.html` |
| 3 | **Spark Details** | Recipe / equation (emojis grey → filled as satisfied), Members button, Chat button, Settings button (creator only). | ❌ **Gap** |
| 4 | **Chat (per-spark)** | Room where members type / react emojis to light the spark. Shared across members. | ❌ **Gap** |
| 5 | **Spark Settings (creator only)** | Member management (add / remove), shape (reopens picker), delete spark. | ❌ **Gap** |
| 6 | **Member list** | Avatars, names, status (online / offline / last-seen) for a spark's Isle. | ❌ **Gap** (could be a sheet off Spark Details) |
| 7 | **Friends** | Friends list + add-by-username / phone requests. Global relationship (vs per-spark membership). | ❌ **Gap** |

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
| 14 | **Parked-spark recovery view** | A greyed / sunk spark tapped from Home → Spark Details showing its greyed state + "complete to relight." Probably **same as Spark Details** in greyed state, not a separate screen. | ❌ (state of #3) |

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
| Chat | Empty · messages flowing · a dependency just satisfied (spark lights — animation / feedback) |
| New Spark | Empty (no main emoji) · main-emoji-only · with deps · with shape changed · invalid (Create disabled) |
| Friends | Empty · has friends · pending requests |

---

## § 7 — Summary: Mocked vs. Gap

**Already mocked (4 + 1 dev tool):**
- Home — `sparks.html`
- New Spark — `create-spark.html`
- Shape Picker — inside `create-spark.html`
- Buttons — `buttons.html`
- Shape Lab — `shape-lab.html` (dev tool, not a shipped screen)

**Gaps to mock, in priority order:**

| Priority | Screen | Why this priority |
|---|---|---|
| 1 | **Spark Details** | The single most important gap — every spark taps into it; it *is* the completion-status visualization (spec § 3, § 7). |
| 2 | **Chat (per-spark)** | Core to the lighting mechanic (spec § 4 — typing / reacting lights the spark). |
| 3 | **Spark Settings + Member list** | Creator flows (spec § 6, § 7). Member list may be a sheet off Spark Details. |
| 4 | **Emoji Picker** (shared) | Needed by both New Spark and Chat — block both screens' final form. |
| 5 | **Friends** | Low-impact per spec, but needed for the Share field to be real. |
| 6 | **Auth entry** | Needed before any social flow is real (spec § 10). |
| 7 | **App Settings + Profile** | Entry point TBD (see § 3 open question). |
| 8 | **Invite-link landing** | Edge case, can wait. |

---

## § 8 — Open Design Questions (decide before / during mocking)

1. **Where are the entry points for Friends / Profile / App Settings**, given Home has no chrome? (blocks Tier 2)
2. **Is there an onboarding screen**, or does the app open straight to empty Home? (spec leans: no onboarding)
3. **Does Profile have an avatar / emoji identity?** Custom emojis are future (spec § 10); what represents "you" until then?
4. **Auth entry point** — modal? first-launch gate? triggered only when a social action is attempted?
5. **Member list** — full screen or bottom sheet off Spark Details?
6. **How does a parked (greyed) spark indicate its parked-ness** when tapped — same Spark Details with greyed visuals, or a distinct recovery view? (current lean: same screen, greyed state)

---

*Last updated: July 1, 2026.*
