# Design Vision — Goal Isle

> ⚠️ **PARTIALLY SUPERSEDED (July 1, 2026).** The core product has been redesigned around **Isle Sparks**. Two things in this vision are now **reversed**: (1) the **"no streaks"** principle — streaks are now a core motivator; (2) the **Isle/Goal/Sub-point** model is replaced by sparks + dependencies. The current source of truth is **[`ISLE_SPARKS_SPEC.md`](ISLE_SPARKS_SPEC.md)**. The calm/minimal/clean-and-cool spirit below still holds.

**Date:** June 22, 2026
**Project:** `/home/jasper/projects/goal_isle/`

---

## The Vibe in One Paragraph

Goal Isle is **a quiet harbor for your goals**. You open it, you see your isles floating in calm water, you tend to them, you close it. No noise, no streaks, no notifications begging you to come back. The app should feel like opening a notebook on a desk — present, useful, easy to set down.

---

## Three Words

**Minimal. Literal. Clean/cool.**

---

## What Each Word Means

### Minimal
- **One primary action per screen.** No competing CTAs.
- **No decorative elements.** Every visual element serves the metaphor or the function.
- **Generous whitespace.** Let the isles breathe.
- **Subtle interactions.** No scale-on-tap, no bounce. Quick fade or color change is enough.
- **No gamification noise.** No streak counters, no badges, no "level up!" moments. If the user wants to track their own progress, the sub-points do that quietly.

### Literal
The "isle" metaphor is not just a name — it is the visual structure of the app.

- **Isles are visible as floating land masses.** Each isle is a card with soft elevation, sitting on a background that suggests water or sky.
- **Goals are peaks on the isle.** Already represented by the `mountain_visual.dart` widget. Keep this.
- **Sub-points are paths or terrain features.** Could be small markers, dots, or lines connecting from the base to the peak.
- **The background is not pure white.** It's a cool, muted tone — like distant water or haze — so the isles appear to float on it.
- **No flat grids of identical cards.** Isles can have different shapes or sizes. They feel placed, not stamped.

### Clean / Cool
- **Cool color palette.** Blues, slate, off-white. No warm tones except for status (success/error).
- **Modern sans-serif typography.** One typeface, used consistently. Generous line height, limited weights.
- **Subtle depth.** Shadows are soft and short. Borders are rare — prefer spacing to separate.
- **Light mode is primary.** Dark mode is a polish goal, not a launch requirement.

---

## What the App Should NOT Feel Like

- Not **Duolingo** — no green owl, no streaks, no celebrations.
- Not **Habitica** — no RPG mechanics, no party system.
- Not **Strava** — no segment leaderboards, no "kudos."
- Not **Notion** — dense, customizable, full of options.
- Not **Linear** — issue tracker aesthetic, too dense.

It should feel closer to **Things 3** or **Headspace** in its calm — but with the literal isle metaphor as the visual hook.

---

## Personality

The app speaks in **short, calm sentences**. Examples:

- **Empty state:** "No isles yet. Tap the spark to plant your first."
- **Goal complete:** "Done."
- **Streak notice:** (none — we don't track streaks)
- **Error:** "Couldn't save. Try again?"

No exclamation points. No emoji in copy. Emoji appear only as user-selected isle icons.

---

## Design Anti-Goals

Things we explicitly do **not** want:

- ❌ Warm color palette (orange, yellow, red) — except for error states
- ❌ Gradients on primary surfaces — only on the background, if at all
- ❌ Heavy shadows that make cards look like they're hovering
- ❌ Multiple typefaces
- ❌ Animated transitions longer than 300ms
- ❌ Onboarding carousel
- ❌ "Welcome to Goal Isle!" splash screens
- ❌ Tutorial overlays
- ❌ Streak counters or "X days in a row!"
- ❌ Social pressure features ("Your friend is on a 30-day streak!")

---

## The Core Metaphor, Visualized

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│   ┌───────────┐                     │
│   │   🏖️      │                     │
│   │  Vacation │       ┌─────────┐   │
│   │   ▲       │       │  💪     │   │
│   └───────────┘       │ Fitness │   │
│                       │  ▲▲     │   │
│                       └─────────┘   │
│                                     │
│                                     │
│              [✨]                   │
│                                     │
│                                     │
└─────────────────────────────────────┘
        Calm slate-blue water
```

- Isles are cards with elevation, sized roughly 160×140.
- Background is a flat, very light slate-blue (#E8EEF2 or similar).
- Spark button (✨) is centered at the bottom — primary action.
- The layout is not a rigid grid — isles have slight position variation.

---

## How This Connects to the Plan

This vision drives every decision in `TOKENS.md` and `SCREENS.md`:

- **Tokens** — cool palette, single typeface, generous spacing.
- **Screens** — minimal screen count, one action per screen.
- **Widgets** — Isle card, Mountain visual, Spark button, plus whatever else emerges.
- **Interactions** — subtle, fast, no celebration.
- **Architecture** — comes last. The data model is small: isles → goals → sub-points.

---

*Last updated: June 22, 2026.*
---

> Archived on 2026-07-01 during vestigial-information cleanup. See [](../AUDIT_2026_07_01.md) for the full cleanup plan.

---

> Archived on 2026-07-01 during vestigial-information cleanup. See [`AUDIT_2026_07_01.md`](../AUDIT_2026_07_01.md) for the full cleanup plan.
