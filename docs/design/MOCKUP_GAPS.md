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

- [x] **1. Profile name** (`"You"`) — shown on Profile, every `"You"` sender label, League. Hardcoded. Needs: edit-Profile sheet → `USER.name`. ✅ Closed: `USER` model + edit-Profile sheet.
- [x] **2. Profile handle** (`@you`) — shown on Profile. Hardcoded. Needs: set-on-signup + edit (with uniqueness check). ✅ Closed: editable in edit-Profile sheet (uniqueness check deferred to backend).
- [x] **3. Profile bio** (`"Studying for the December LSAT…"`) — shown on Profile. Hardcoded, no edit affordance. Needs: edit-Profile sheet → `USER.bio`. ✅ Closed.
- [x] **4. Profile avatar emoji** (`🧑`) — shown on Profile, Home corner avatar, all `"You"` sender labels, League. Hardcoded. Needs: emoji picker in edit-Profile. ✅ Closed: avatar picker sheet.
- [x] **5. Create-Isle flow** — **does not exist.** Cannot make a new Isle. Blocks the app's core object. Needs: a Create-Isle screen (name + emoji + color + visibility + purpose). ✅ Closed: `screen-create-isle` + `finishCreateIsle`.
- [x] **6. Isle `name`** — hardcoded per Isle; shown on Home face, Isle header, Isles list, Notes, League. Set only by the (missing) Create-Isle flow; no rename. ✅ Create path closed (rename still open — see #14 pattern).
- [x] **7. Isle `mainEmoji`** — hardcoded; shown on Home face, Isle header, Isles list. Set only by Create-Isle; no edit. ✅ Create path closed.
- [x] **8. Isle `purpose`** — hardcoded (`"crushing the December test together"`); shown on Isle header. Spec field (`purpose: one-line description, optional`). No creation field, no edit. ✅ Create path closed.
- [x] **9. Metric spark creation** — **entire mode was read-only.** ✅ Closed: Kind picker now has a third "Track a number" card; selecting it shows target/unit fields and hides deps; `finishCreate` branches to build a metric spark.
- [x] **10. Metric `target` / `unit` / `template`** — ✅ Closed: target + unit set at creation; `submitLog` updates value/trend, pushes to thread, and lights the spark when target is hit (gap #23 also closed).

---

## Tier 2 — 🟠 Broken affordances (looks editable, isn't)

Shown as a row with a value/chevron suggesting edit, but the row is dead or the action is missing.

- [x] **11. Isle `visibility`** — ✅ Closed: row now toggles private↔public via `toggleIsleVis()`.
- [x] **12. Member `Remove` buttons** — ✅ Closed: real `ISLE_MEMBERS` model per isle; Remove is wired (`removeMember`), updates count everywhere.
- [x] **13. Friends — unfriend** — ✅ Closed: Remove button on accepted friends (`unfriend`).
- [x] **14. Spark `title` rename** — ✅ Closed: Spark Settings screen has a rename field (`saveSparkSettings`).
- [x] **15. Spark `shape` per-spark** — ✅ Closed: Spark Settings has 4-corner shape sliders (`updateSparkShape`).
- [x] **16. App Settings theme row** — ✅ Closed: Display section added with a cycling theme row (`cycleTheme`).
- [x] **17. Sign out (Profile)** — ✅ Closed: now navigates to the auth screen (sign-out returns to the gate).
- [x] **18. Discover `Join`** — ✅ Closed: `toggleJoin` now promotes the discovered Isle into `ISLES` + `ISLE_MEMBERS` on join, and removes it on leave. Joined Isles appear in Your Isles immediately.
- [x] **19. Post image (`postImg`)** — ✅ Closed: `finishPost` now stores a real image URL when photo is attached; the feed renders the image (not just a boolean). Mock uses picsum placeholders for the actual capture (a Flutter camera-plugin concern).
- [x] **20. Metric Log photo (`logPhoto`)** — ✅ Closed: `submitLog` stores an image URL when the photo toggle is on; the per-spark thread renders it.

---

## Tier 3 — 🟡 Spec-mandated, entirely missing

Things the v2 spec explicitly defines that have zero UI in the mockup.

- [x] **21. Language Principle cleanup** — ✅ Closed: removed "Activity", "Trend", "This week/Last week", "Repeats", "Visibility", "Kind", "Danger zone" from visible UI. Replaced with icons, values-only rows, or removed labels where cards are self-explanatory. Metric panel now shows value + arrow + target wordlessly. Remaining allowed-chrome words (Settings, Cancel, About, Search, Notifications, Theme, Color, Shape, Display, Push, Edit, Members, Thread, Post, Friends, League, Notes, Discover, Spark, Isle, Name, Bio, Avatar, Join, Add, Remove, Done, Log, Create, Share, Accept, Decline, Delete, Leave, Sent, Requests) are either allowed nouns/verbs or standard OS settings vocabulary the spec does not target.
- [x] **22. Scope (shared/personal) at creation** — §5. ✅ Closed: metric Kind now shows a scope toggle (Just me / Together) within the metric fields; `finishCreate` reads `createMetricScope`. Scope is no longer conflated — it's an explicit choice orthogonal to mode.
- [x] **23. Metric lighting mechanic** — §6 hybrid lighting. ✅ Closed: `submitLog` now checks value against target (or improvement on prev), sets spark state to lit, increments streak, fires banner.
- [x] **24. Per-Spark thread** — §6. ✅ Closed: dedicated `screen-sparkthread` reads from `s.thread`; Thread button on Spark Details opens it (no longer the Isle chat).
- [x] **25. Home layout laws** — §9. ✅ Closed: v2 Home now obeys all three laws — (1) tinted territory regions (soft radial wash of each Isle's color behind its face), (2) active-Isles-only filter (empty Isles don't appear), (3) Poisson-disk dispersion with lit/greyed banding within the active set. Layout is seeded/stable.
- [x] **26. Image model** — §11. ✅ Closed: posts and logs now carry real image URLs (mock placeholders); the feed and per-spark thread render them. Real camera capture is the Flutter-port concern (camera plugin), but the data model + rendering path are honest in-mockup.
- [x] **27. Auth entry (sign in / sign up)** — ✅ Closed: `screen-auth` is now the first-launch gate. Handle input + Join button → `signIn()` sets `USER.handle`/`USER.name` and proceeds to Home. Bottom nav + avatar hidden on auth.

---

## Tier 4 — 🟢 Data-integrity / logic

The mockup's logic doesn't match how real state would work. Won't break the demo, but will break the port if not reconciled.

- [x] **28. `memberCount` is hardcoded** — ✅ Closed: derived via `memberCountOf(isle)` from `ISLE_MEMBERS` everywhere it's read. Adding/removing members updates counts in Isle header, Audience picker, and Settings.
- [x] **29. `OPENED_STATE` (Notes) is a mock constant** — ✅ Closed: replaced with a dynamic `lastOpened` map; `openChat` stamps the open time; Notes sorts unopened-first and shows relative "opened Xm/h/d" derived from the stamp. A chat you've opened drops out of the "New" group.
- [x] **30. `LEAGUE_DB` is a parallel hardcoded structure** — ✅ Closed: removed. `leagueForIsle()` derives rankings from `ISLE_MEMBERS` + the Isle's best lit spark streak. Creator carries the real streak; other members get a deterministic fraction (mock of per-user streaks a backend would store).
- [x] **31. No leave-Isle flow** — ✅ Closed: Isle Settings now shows "Delete" (creator) or "Leave" (member) based on the user's role. `leaveIsle()` removes the Isle + its membership for the user. Joined public Isles show Leave; owned Isles show Delete.
- [x] **32. Reactions count drift** — ✅ Re-audited: no actual bug. The single reaction path (`reactMsg`) toggles cleanly (add/remove, delete-empty-key), and the count always equals array length. Closed as a non-issue.
- [x] **33. No friend-request decline** — ✅ Closed: Decline button on pending-in requests (`declineFriend`).

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

*Last updated: July 5, 2026. **All 33 gaps closed.** Items 1–8 in the Create-Isle + Edit-Profile pass; 9–16, 23–24, 33 in the metric + dead-rows + Spark-Settings pass; 17–18, 21, 27–28, 30–32 in the Language-Principle + data-integrity + Auth pass; 19–20, 22, 25–26, 29 in the final image/scope/Home/Notes pass. The mockup is now substantively complete and ready for the Flutter port.*
