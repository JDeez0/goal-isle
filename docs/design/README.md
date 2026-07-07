# Design Documentation — Goal Isle

**Date:** June 22, 2026

This directory contains the design intent for the Goal Isle Flutter app.

## Files

| File | Purpose |
|---|---|
| **[`ISLE_SPARKS_SPEC_v2.md`](./ISLE_SPARKS_SPEC_v2.md)** | **🔒 THE governing spec — Isle Keys v2. Read this first.** (Note: the file keeps the v1 name for stable links; the object is now "Isle Key" — "spark" is a valid synonym. Terminology note at the top of the spec.) |
| [`ISLE_SPARKS_SPEC.md`](./ISLE_SPARKS_SPEC.md) | v1 (historical, superseded by v2). Retained for the record. |
| **[`MOCKUPS.md`](./MOCKUPS.md)** | How to run the design mockups (`mockups/sparks.html`, `mockups/buttons.html`). |
| **[`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md)** | Every potential screen, mocked vs. gap, state variations, open questions — the mockup roadmap. |
| [`VISION.md`](../archive/VISION.md) | ⚠️ Archived — the original vibe doc. Three Words still hold; most concrete examples are outdated. |
| [`TOKENS.md`](./TOKENS.md) | Design tokens: colors, typography, spacing, motion. ⚠️ Layout section removed (orphaned). |

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

- [x] Spec locked — Isle Sparks v2 (July 3, 2026) — adds communities, metric sparks, posts, discovery
- [x] Spec v1 (July 1, 2026) — historical, superseded
- [x] Mockups aligned to v1 (app shell, sparks, shape-lab, create-spark, buttons) — **need v2 updates**
- [ ] Tokens implemented in `lib/theme/tokens.dart`
- [ ] Widget library built (`IsleSpark`, `CreateSparkButton`, `ShapePicker`, `SparkDetailsScreen`, + v2: `IsleTerritory`, `MetricLogSheet`, `PostComposer`, etc.)
- [ ] Screens implemented in Flutter
- [ ] Interactions and motion
- [ ] User testing

See [`../../UI_DEVELOPMENT_PLAN.md`](../../UI_DEVELOPMENT_PLAN.md) for the full plan.

---

*Last updated: July 3, 2026 — v2 spec locked as governing.*