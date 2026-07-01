# Design Documentation — Goal Isle

**Date:** June 22, 2026

This directory contains the design intent for the Goal Isle Flutter app.

## Files

| File | Purpose |
|---|---|
| **[`ISLE_SPARKS_SPEC.md`](./ISLE_SPARKS_SPEC.md)** | **🔒 THE current system spec — Isle Sparks redesign. Read this first.** |
| **[`MOCKUPS.md`](./MOCKUPS.md)** | How to run the design mockups (`mockups/sparks.html`, `mockups/buttons.html`). |
| [`VISION.md`](./VISION.md) | The vibe, personality, and core metaphor. ⚠️ Partially superseded (streaks reversed; model changed). |
| [`SCREENS.md`](./SCREENS.md) | ⚠️ Superseded by `ISLE_SPARKS_SPEC.md`. Kept for history. |
| [`TOKENS.md`](./TOKENS.md) | Design tokens: colors, typography, spacing, motion. ⚠️ mass/progress tokens now orphaned. |

## The Vibe

**Minimal. Literal. Clean/cool.**

- **Minimal** — one primary action per screen, no decoration, no gamification noise.
- **Literal** — isles are visible as floating land masses on a calm water-like background.
- **Clean / cool** — cool color palette, modern sans-serif, subtle depth.

## The Direction at a Glance

```
Background:    #EEF2F5  (calm slate water)
Surface:       #FFFFFF   (floating isle cards)
Accent:        #3B82F6   (cool blue, used sparingly)
Text:          #1F2937   (deep slate)
Typography:    System sans-serif
Spacing:       4-8-12-16-24-32-48-64 px scale
Motion:        ≤ 300ms, easeOut
```

Read [`VISION.md`](./VISION.md) for the full rationale.

## Status

- [x] Phase 1 — Design intent documented
- [ ] Phase 2 — Tokens implemented in `lib/theme/tokens.dart`
- [ ] Phase 3 — Widget library extracted
- [ ] Phase 4 — Screens built
- [ ] Phase 5 — Interaction and motion
- [ ] Phase 6 — User testing
- [ ] Phase 7 — Design locked

See [`../../UI_DEVELOPMENT_PLAN.md`](../../UI_DEVELOPMENT_PLAN.md) for the full plan.

---

*Last updated: July 1, 2026.*