# Screens — Goal Isle

**Date:** June 22, 2026

The screen list is deliberately small. Every screen has one job.

---

## Core Screens (Phase 4 — must build)

### 1. Home (Isles)
**Job:** Show all isles, let the user create a new one.

**Layout:**
- Header: app title or current user name (small, top-left).
- Canvas: floating isle cards on cool background. Each card shows the isle's emoji icon, name, and a progress indicator (number of sub-points completed / total).
- Spark button (✨): fixed at bottom-center. Primary action: create a new isle.
- No bottom navigation bar. No tabs.

**Empty state:** "No isles yet. Tap the spark to plant your first." with a subtle illustration hint at the spark.

**States:**
- Default: isles visible.
- Pressing an isle: opens detail.
- Long-pressing an isle: shows "delete" affordance (with confirmation).

---

### 2. Isle Detail
**Job:** Show the goals and sub-points for one isle. Let the user add goals.

**Layout:**
- Header: isle name + emoji + back button.
- Mountain visual: the existing `mountain_visual.dart` widget, showing goal peaks rising.
- Goal list: each goal is a card with its sub-points listed underneath.
- "+ Add goal" affordance below the list.
- Sub-points can be checked off (toggle).

**States:**
- Default: viewing goals.
- Adding a goal: inline form or sheet.
- Goal completed: check the goal card (still editable).

---

### 3. Create Isle
**Job:** Let the user plant a new isle.

**Layout:**
- Modal sheet (full-height on mobile, centered on web).
- Fields: isle name, emoji picker (limited to ~20 common options), optional description.
- Single primary button: "Plant Isle" (disabled until name is non-empty).
- No multi-step wizard. No onboarding copy.

**States:**
- Default: empty form.
- Valid: "Plant Isle" enabled.
- Submitting: brief loading state.
- Done: closes, returns to home with new isle visible.

---

### 4. Chat (per-isle)
**Job:** Talk to friends who are also on the isle.

**Layout:**
- Standard message list (sender name, avatar, timestamp).
- Input field at the bottom.
- Mocked: messages are static, no real-time.

**Note:** Chat is mocked for now. The layout can mirror common chat patterns without being novel.

---

### 5. Friends List
**Job:** See who you're connected with.

**Layout:**
- List of friends with avatar, name, and current activity (e.g., "on Fitness Isle").
- Mocked data for now.

---

## Optional Screens (Phase 7+ — only if needed)

### 6. Settings
- Account (placeholder)
- Theme (light/dark)
- About

### 7. Profile / Account
- Mocked for now.

### 8. Onboarding
- **One screen, not a carousel.** Pick an emoji, name your first isle, done.
- Skippable. Returning users land on Home directly.

---

## What We Are NOT Building

To keep the scope tight and the design honest:

- ❌ Search
- ❌ Filters
- ❌ Sort options
- ❌ Notifications
- ❌ Activity feed
- ❌ Achievements or badges
- ❌ Streaks
- ❌ Leaderboards
- ❌ Stats dashboards ("You completed 47 goals this month!")
- ❌ Onboarding tutorial overlay
- ❌ Settings menu with 20 items

---

## Screen Flow

```
Home ──tap isle──> Isle Detail ──tap goal──> (goal stays put, sub-points expand)
  │                   │
  │                   └──> Chat (per-isle)
  │
  └──tap spark──> Create Isle ──submit──> Home (with new isle)
```

No deep navigation. No drawer. No bottom nav bar. One screen in, one screen out.

---

*Last updated: June 22, 2026.*