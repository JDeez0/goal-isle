# Design Tokens — Goal Isle

**Date:** June 22, 2026

These tokens are the source of truth for every visual property in the Flutter app. They will be implemented in `lib/theme/tokens.dart` (Phase 2 of the UI plan).

**Design principle:** every token below serves the **Minimal. Literal. Clean/cool** vision in `VISION.md`. If a token feels decorative, it's wrong.

---

## Color Palette

### Background / Surface

The background suggests water or distant haze. Cards and surfaces float on it.

| Token | Hex | Use |
|---|---|---|
| `background` | `#EEF2F5` | The "ocean" behind every screen |
| `surface` | `#FFFFFF` | Isle cards, modal sheets, input fields |
| `surfaceMuted` | `#F8FAFB` | Sub-surface (nested cards, secondary containers) |
| `surfaceDark` | `#1A2332` | Reserved for future dark mode |

### Text

| Token | Hex | Use |
|---|---|---|
| `textPrimary` | `#1F2937` | Isle names, headlines, primary copy |
| `textSecondary` | `#64748B` | Descriptions, helper text, secondary copy |
| `textTertiary` | `#94A3B8` | Timestamps, captions, hints |
| `textInverse` | `#FFFFFF` | Text on dark or accent surfaces |

### Border / Divider

| Token | Hex | Use |
|---|---|---|
| `border` | `#DDE3E8` | Subtle dividers (used sparingly) |
| `borderFocus` | `#3B82F6` | Focus ring on inputs |

### Accent

The accent is a cool blue. Use it sparingly — only for primary actions, selected states, and progress indicators.

| Token | Hex | Use |
|---|---|---|
| `accent` | `#3B82F6` | Spark button, primary CTA, selected isle |
| `accentSubtle` | `#DBEAFE` | Background of selected isle, accent surfaces |
| `accentDark` | `#2563EB` | Pressed state of accent |

### Status

Status colors are rare and reserved for their purpose. No warm colors outside these.

| Token | Hex | Use |
|---|---|---|
| `success` | `#10B981` | Goal completed (used as a checkmark color, not as background) |
| `warning` | `#F59E0B` | Almost never — only for destructive confirmations |
| `error` | `#EF4444` | Error text, validation failure |

### Progress

Sub-points and goals use a cool gray-to-blue gradient for progress.

| Token | Hex | Use |
|---|---|---|
| `progressEmpty` | `#E2E8F0` | Unfilled progress |
| `progressFilled` | `#3B82F6` | Filled progress (matches accent) |

---

## Typography

### Typeface

**Primary:** System default (San Francisco on macOS/iOS, Roboto on Android, Segoe UI on Windows, Inter as web fallback via Google Fonts if needed later).

**Rationale:** System fonts feel native, load instantly, and respect user accessibility settings. We can ship a custom font later if needed, but no custom font is required for the design.

### Scale

| Token | Size / Weight | Use |
|---|---|---|
| `display` | 32px / 600 | Empty-state titles |
| `headline` | 24px / 600 | Isle detail header |
| `title` | 18px / 500 | Isle card title, modal title |
| `body` | 16px / 400 | Default body text |
| `label` | 14px / 500 | Button text, input labels |
| `caption` | 12px / 400 | Timestamps, helper text |

### Line Height

- Headlines: 1.3
- Body: 1.5
- Labels/captions: 1.4

### Spacing Within Text

- Letter spacing: normal (0) for all sizes. No tight tracking, no wide tracking.

---

## Spacing

A simple scale. Most layout decisions should pick from this list.

| Token | Value | Use |
|---|---|---|
| `space1` | 4px | Tight (between an icon and its label) |
| `space2` | 8px | Small (between related elements) |
| `space3` | 12px | Default (between form fields) |
| `space4` | 16px | Card padding, list item spacing |
| `space5` | 24px | Section spacing |
| `space6` | 32px | Top/bottom of screen padding |
| `space8` | 48px | Generous (between major sections) |
| `space10` | 64px | Hero spacing |

**Rule:** if you find yourself wanting a value not on this list, you're probably looking for the next step up or down.

---

## Border Radius

| Token | Value | Use |
|---|---|---|
| `radiusSm` | 8px | Buttons, input fields, small chips |
| `radiusMd` | 12px | Cards, isle tiles |
| `radiusLg` | 16px | Modals, bottom sheets |
| `radiusFull` | 9999px | Circular elements (avatars, spark button) |

---

## Elevation

We use **soft, short shadows**. Elevation makes cards feel like they float on the background.

| Token | Value | Use |
|---|---|---|
| `elevation0` | none | Flat surfaces |
| `elevation1` | `0 1px 2px rgba(31,41,55,0.06), 0 1px 3px rgba(31,41,55,0.04)` | Isle cards on home |
| `elevation2` | `0 4px 6px rgba(31,41,55,0.05), 0 2px 4px rgba(31,41,55,0.06)` | Modal sheets, popovers |
| `elevation3` | `0 10px 15px rgba(31,41,55,0.08), 0 4px 6px rgba(31,41,55,0.06)` | Reserved (rarely used) |

**Rule:** if a card needs more than `elevation1`, it's probably a modal — use `elevation2` and treat it as such.

---

## Motion

Subtle and fast. No celebration.

| Token | Value | Use |
|---|---|---|
| `durationFast` | 150ms | Hover, focus, color changes |
| `durationDefault` | 250ms | Card transitions, modal open |
| `durationSlow` | 400ms | Reserved (avoid using) |

| Token | Value | Use |
|---|---|---|
| `curveDefault` | `easeOut` | All transitions |
| `curveEntrance` | `easeOutCubic` | Modal/sheet open |
| `curveExit` | `easeInCubic` | Modal/sheet close |

**Rule:** No transition should be longer than 300ms unless the user explicitly waits for it (e.g., a deliberate loading state).

---

## Iconography

| Token | Value |
|---|---|
| Style | Outlined (Material `Icons.outlined`) |
| Default size | 24px |
| Small | 16px (inline with text) |
| Large | 32px (hero icons) |

**Custom iconography:** The Spark button is a custom element (✨ emoji or custom-painted star). Other icons come from Material outlined.

---

## Layout

### Canvas (Home screen)

- Padding around the canvas: `space6` (32px) on all sides.
- Isle cards: roughly 160×140 px each.
- Isles can be positioned with slight variation (not a rigid grid).
- Spark button: fixed at bottom-center, 56px diameter.

### Card (Isle)

- Width: 160px (or `LayoutBuilder` for responsive).
- Height: 140px.
- Padding: `space4` (16px) inside.
- Border radius: `radiusMd` (12px).
- Elevation: `elevation1`.
- Background: `surface` (white).

### Spacing Rhythm

- Between elements: `space3` or `space4` (12 or 16px).
- Between sections: `space5` or `space6` (24 or 32px).
- Screen padding: `space6` (32px) at top, `space8` (48px) at bottom.

---

## What This Document Is NOT

- **Not a wireframe.** It defines the language, not the exact pixel positions of every screen.
- **Not a complete theme spec.** Dark mode is intentionally absent — we'll add it after light mode is locked.
- **Not a list of all possible values.** If a value isn't here, ask before adding it. The list is intentionally short.

---

*Last updated: June 22, 2026.*