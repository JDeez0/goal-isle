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
| **Create Spark · Shape Picker** | http://localhost:8095/docs/design/mockups/create-spark-shape-picker.html | The Create Spark screen (phone frame) with a **Shape row** that opens an iOS bottom-sheet picker (presets + per-corner sliders, live preview). Default = rhomboid squircle. |
| **Shape Lab** | http://localhost:8095/docs/design/mockups/shape-lab.html | Interactive: drag the 4 corners live, compare all presets, and copy the exact Flutter/CSS values. |
| **Isle Sparks** | http://localhost:8095/docs/design/mockups/sparks.html | Quasi-circle shape, all four states (dull / lit / streaked / greyed), streak badge + squiggly beach line, Create Spark button, and a Home composition with sparks floating on the water. |
| **Buttons** | http://localhost:8095/docs/design/mockups/buttons.html | Button system (filled / outlined / text / icon / destructive), sizes, states, dark mode, design tokens. iOS-first, 2026 spec. |

---

## Notes

- **Shape Lab** and the **Shape Picker** share the same preset set: Rhomboid squircle (default), Soft rhomboid, Squircle, Sharp-corner, Circle. Rhomboid squircle values: `tl 40 / tr 12 / br 40 / bl 12` (%).
- **Sparks mockup** generates the squiggly "beach" line with a small inline JS function (`wavyCirclePath`) — a real wavy circle, not a static asset. Amplitude is small so it reads as a gentle squiggle.
- **Buttons mockup** has a dark-mode toggle (top-right) for previewing both themes.
- All mockups target iOS-first sizing (44×44 touch targets, system font stack).

---

## Relationship to the Spec

- Isle Spark behavior and states → see [`ISLE_SPARKS_SPEC.md`](ISLE_SPARKS_SPEC.md).
- Design tokens → see [`TOKENS.md`](TOKENS.md) (note: some new tokens for the spark shape/states are not yet defined there — see the spec's "Visual tokens to add" section).
