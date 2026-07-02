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
| **Create Spark** | http://localhost:8095/docs/design/mockups/create-spark.html | The Create Spark screen (phone frame) — **icon-led, no noun headers**; the equation as hero (deps above `=`, main emoji below); a grouped settings card (shape / repeats / streak / share); and a **Shape picker** bottom sheet that reshapes the whole screen live. Default = rhomboid squircle. |
| **Spark Details** | http://localhost:8095/docs/design/mockups/spark-details.html | The Spark Details screen (phone frame). The read-only **recipe / equation** (deps above `=`, main-emoji hero below) — each dep grey→fills as satisfied in chat; the hero lights when all deps are met (or, for a no-dep spark, when the main emoji is posted). Action card: Members · Chat (becomes the primary CTA "Light this spark" when dull) · Settings (creator only). **Interactive** — toggle dep satisfaction, streak, parked state, and creator/member access; plus a **static gallery** of variants (no-dep, parked, streaked-win, partial-fill). |
| **Shape Lab** | http://localhost:8095/docs/design/mockups/shape-lab.html | Interactive: drag the 4 corners live, compare all presets, and copy the exact Flutter/CSS values. |
| **Isle Sparks** | http://localhost:8095/docs/design/mockups/sparks.html | Quasi-circle shape, all four states (dull / lit / streaked / greyed), streak badge, Create Spark button, and a Home composition with sparks floating on the water. |
| **Buttons** | http://localhost:8095/docs/design/mockups/buttons.html | Button system (filled / outlined / text / icon / destructive), sizes, states, dark mode, design tokens. iOS-first, 2026 spec. |

---

## Notes

- **Create Spark** (`create-spark.html`) is the canonical Create Spark design. Earlier `create-spark-shape-picker.html` and a `label-free.html` experiment were retired in favor of it.
- **Spark Details** (`spark-details.html`) is interactive: the right-hand "Preview controls" panel toggles dependency satisfaction, streak count, parked state, and creator/member access so the grey→fill transition and each visual state can be felt live. Those controls are dev preview chrome — not part of the shipped screen. The **state gallery** below the phone shows static variants the toggles can't show side-by-side (no-dep spark, parked, streaked-win, partial-fill). Per the spec (July 2, 2026), dependencies are single-occurrence / binary — no `requiredCount`.
- **Shape Lab** and the **Shape Picker** share the same preset set: Rhomboid squircle (default), Soft rhomboid, Squircle, Sharp-corner, Circle. Rhomboid squircle values: `tl 40 / tr 12 / br 40 / bl 12` (%).
- **Buttons mockup** has a dark-mode toggle (top-right) for previewing both themes.
- All mockups target iOS-first sizing (44×44 touch targets, system font stack).

---

## Relationship to the Spec

- Isle Spark behavior and states → see [`ISLE_SPARKS_SPEC.md`](ISLE_SPARKS_SPEC.md).
- Design tokens → see [`TOKENS.md`](TOKENS.md) (note: some new tokens for the spark shape/states are not yet defined there — see the spec's "Visual tokens to add" section).
