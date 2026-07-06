# Mockup Gaps Audit — `app-v2.html`

**Date:** July 5, 2026
**Audits:** [`mockups/app-v2.html`](mockups/app-v2.html) (the active v2 mockup)
**Against:** [`ISLE_SPARKS_SPEC_v2.md`](ISLE_SPARKS_SPEC_v2.md) (🔒 locked v2)

> **What this is.** A complete trace of every value the user *sees* in `app-v2.html` back to whether it can be **created** and **edited**. The mockup is currently read-heavy: most UI is a display surface with no write-back. This doc enumerates every dead end, broken affordance, missing flow, and data-integrity issue — with priorities and checkboxes — so the work can be tracked to closure before the Flutter port.
>
> **Convention:** 🔴 = dead end (shown, never changeable). 🟠 = broken affordance (looks editable, isn't). 🟡 = spec-mandated, entirely missing. 🟢 = data-integrity / logic. Each item has a `[ ]` checkbox; mark `[x]` when closed in the mockup.

---

## Tier 1 — 🔴 Dead ends (shown, NEVER changeable)

Hardcoded values with no input path. These are the highest-impact gaps because they block core identity flows.

- [ ] **1. Profile name** (`"You"`) — shown on Profile, every `"You"` sender label, League. Hardcoded. Needs: edit-Profile sheet → `USER.name`.
- [ ] **2. Profile handle** (`@you`) — shown on Profile. Hardcoded. Needs: set-on-signup + edit (with uniqueness check).
- [ ] **3. Profile bio** (`"Studying for the December LSAT…"`) — shown on Profile. Hardcoded, no edit affordance. Needs: edit-Profile sheet → `USER.bio`.
- [ ] **4. Profile avatar emoji** (`🧑`) — shown on Profile, Home corner avatar, all `"You"` sender labels, League. Hardcoded. Needs: emoji picker in edit-Profile.
- [ ] **5. Create-Isle flow** — **does not exist.** Cannot make a new Isle. Blocks the app's core object. Needs: a Create-Isle screen (name + emoji + color + visibility + purpose).
- [ ] **6. Isle `name`** — hardcoded per Isle; shown on Home face, Isle header, Isles list, Notes, League. Set only by the (missing) Create-Isle flow; no rename.
- [ ] **7. Isle `mainEmoji`** — hardcoded; shown on Home face, Isle header, Isles list. Set only by Create-Isle; no edit.
- [ ] **8. Isle `purpose`** — hardcoded (`"crushing the December test together"`); shown on Isle header. Spec field (`purpose: one-line description, optional`). No creation field, no edit.
- [ ] **9. Metric spark creation** — **entire mode is read-only.** Spark details renders metric sparks with data panels, but the Kind picker only offers solo/together (ritual). `finishCreate()` hardcodes `mode:'ritual'`. Needs: a third Kind card → metric creation fields.
- [ ] **10. Metric `target` / `unit` / `template`** — hardcoded in seed data; shown in the metric panel ("This week / Last week"). Spec §6 requires these at creation; no UI exists.

---

## Tier 2 — 🟠 Broken affordances (looks editable, isn't)

Shown as a row with a value/chevron suggesting edit, but the row is dead or the action is missing.

- [ ] **11. Isle `visibility`** — Isle Settings shows it as a row with a value (`private`/`public`), but **no `onclick`, no picker**. Dead row.
- [ ] **12. Member `Remove` buttons** — rendered in member list, but **`onclick` is missing**. Clicking does nothing.
- [ ] **13. Friends — unfriend** — no remove button on accepted friends. Can accept incoming requests; cannot unfriend.
- [ ] **14. Spark `title` rename** — correctly read on create (`finishCreate` reads `mainLabel.value`), but **no edit path** post-creation. Spark Settings (which doesn't exist in v2) would hold this.
- [ ] **15. Spark `shape` per-spark** — spec says cosmetic + editable in Spark Settings. **There is no Spark Settings screen in v2** — only Isle Settings. Shape can't be changed after creation (and isn't settable at creation either).
- [ ] **16. App Settings theme row** — "Theme · Light" row exists, **dead — no picker**.
- [ ] **17. Sign out (Profile)** — row navigates to Home but **doesn't clear any auth state** (no auth state exists). Cosmetic only.
- [ ] **18. Discover `Join`** — `toggleJoin` flips the button label but **does not add the Isle to `ISLES`**. Join is purely cosmetic; the Isle never appears in Your Isles.
- [ ] **19. Post image (`postImg`)** — toggle works, but it's a CSS placeholder. **No real image, no proof** (spec §11 re-introduces camera capture).
- [ ] **20. Metric Log photo (`logPhoto`)** — same: boolean toggle, no actual image capture or proof stored.

---

## Tier 3 — 🟡 Spec-mandated, entirely missing

Things the v2 spec explicitly defines that have zero UI in the mockup.

- [ ] **21. Language Principle cleanup** — §0 restricts UI text to nouns "Isle/Key" + plain verbs (Done/Log/Create/Join/Share/Add/Remove). Overages in the mockup: "Activity", "Trend", "Visibility", "Repeats", "Push", "Kind", "Color", "To". Need a screen-by-screen pass to replace with allowed words or icons.
- [ ] **22. Scope (shared/personal) at creation** — §5. The Kind picker conflates scope with mode. Personal-vs-shared is real in the data but the metric path offers no scope choice.
- [ ] **23. Metric lighting mechanic** — §6 hybrid lighting. Ritual lighting works; **metric lighting has no mechanic** — logging a score doesn't check against `target`, doesn't change spark state. `submitLog()` just pushes a thread message.
- [ ] **24. Per-Spark thread** — §6. Spec says metric sparks have their own thread. The "Thread" button opens the **Isle chat**, not a per-spark thread.
- [ ] **25. Home layout laws** — §9. The Poisson-disk dispersion from `app.html` (v1) **was not ported** to v2 Home. Need to verify v2 Home's face grouping obeys the spec's three layout laws + density cap.
- [ ] **26. Image model** — §11. Posts + Log both reference images but there's no image data, no capture UI, no rendering of a real image.
- [ ] **27. Auth entry (sign in / sign up)** — inherited Tier-2 gap from v1. Blocks every social flow. No screen exists.

---

## Tier 4 — 🟢 Data-integrity / logic

The mockup's logic doesn't match how real state would work. Won't break the demo, but will break the port if not reconciled.

- [ ] **28. `memberCount` is hardcoded** (`memberCount:6`) and never reconciled with the actual members array (also hardcoded to 3 names in `renderMemberList`). Real app: derive count from memberships.
- [ ] **29. `OPENED_STATE` (Notes) is a mock constant** — real read-state needs persistence per user per Isle.
- [ ] **30. `LEAGUE_DB` is a parallel hardcoded structure** — real rankings derive from sparks' streaks + memberships, not a separate array.
- [ ] **31. No leave-Isle flow** — a creator can delete; a member cannot leave. Spec §12 implies leaving.
- [ ] **32. Reactions count drift** — `reactMsg` toggling has edge cases where counts can get out of sync across messages.
- [ ] **33. No friend-request decline** — only Accept. Pending-in requests can't be dismissed.

---

## Recommended build order

The biggest structural holes, addressed in order of leverage:

1. **Create-Isle flow** (closes #5–8) — unblocks the app's core object.
2. **Edit-Profile sheet** (closes #1–4) — fixes the most user-facing dead ends; needs a `USER` model.
3. **Metric spark creation** (closes #9–10, #23) — makes the v2 wedge (LSAT) real.
4. **Wire the dead rows** (closes #11–13, #16) — visibility picker, member Remove, unfriend, theme.
5. **Spark Settings screen** (closes #14–15) — rename + shape.
6. **Language-Principle cleanup** (closes #21) — fastest spec-alignment win.
7. **Auth entry** (closes #27) — gates the social flows for the port.

---

*Last updated: July 5, 2026. Checkboxes marked as gaps close in `app-v2.html`.*
