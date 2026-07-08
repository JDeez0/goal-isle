# Supabase Integration — Status

Last updated: 2026-07-07

## What works

End-to-end, against your real Supabase project (mjnitlwhpqylivplkkxu):

| Flow | Status | Notes |
| --- | --- | --- |
| Email sign-up + sign-in | ✅ | Email confirmation required; auto-creates `profiles` row via trigger |
| Sign-out | ✅ | Clears session, returns to auth screen |
| Create Isle | ✅ | Inserts `isles` row + creator `memberships` row atomically with the real Supabase UUID |
| View Isles list | ✅ | Isles index screen reads from provider |
| Discover (public isles) | ✅ | List rendered from Supabase; Join inserts a `memberships` row |
| Join public Isle | ✅ | Real `memberships` insert against the existing isle |
| Isle territory on Home | ✅ | Poisson-disk layout renders all active isles |
| League / Streaks | ✅ | Ranks members by streak; shows the test isles |

## What's still cosmetic / local-only

These screens read from providers but writes are local-only or partially wired:

- **Sparks (keys):** create / rename / shape / delete → `islesProvider` mutates, then fire-and-forget to Supabase. Read-back from Supabase on app launch works.
- **Posts:** composer writes to `islesProvider`, then `createPost` posts to Supabase.
- **Chat messages:** send works, persisted to `messages` table.
- **Friends (write paths):** accept/decline/unfriend are local-only. Read-back now works.
- **Profile edit:** writes to `profiles` table.

## Read-from-Supabase matrix

| Provider | On sign-in | On cold start |
| --- | --- | --- |
| `currentUser` | ✅ | — (default) |
| `isles` | ✅ | ✅ |
| `memberships` | ✅ | ✅ |
| `friends` | ✅ | ✅ |
| `discover` (public isles) | ✅ (on screen open) | ✅ (on screen open) |

## Schema

8 tables in `public`: `profiles`, `isles`, `memberships`, `sparks`, `dependencies`, `messages`, `posts`, `friends`.

All have RLS enabled with policies:
- Isles: read public OR creator OR member; insert/update/delete by creator only
- Memberships: read if self OR isle creator; insert/delete if self OR isle creator
- Sparks: read if member OR isle creator; write by isle creator
- Messages: read if sender OR member of `chat_id`; insert by sender if member
- Posts: read if author OR member of any isle in `audience`; insert by author if member
- Friends: read/insert/update/delete if user_id OR friend_id matches auth.uid()
- Helper: `public.is_member(isle_uuid)` — SECURITY DEFINER, breaks the read-policy recursion

## Critical fix in this session

The biggest bug was a **double-insert** on Isle creation:

1. `create_isle_screen._create` called `addIsle(isle)` — this hits `createIsle` in the repo, which inserts the isle AND the creator's membership using the real Supabase UUID. ✅
2. The screen then ALSO called `addMember(id, Membership(isleId: id, ...))` where `id` was the local client-generated string (`is-1234567890`). The second insert went to `memberships` with an `isle_id` that didn't exist in the `isles` table → `23503 foreign key violation`. ❌

**Fix:** Removed the redundant `addMember` call in `create_isle_screen`. Now the membership is inserted exactly once, with the correct UUID.

Same bug class in `discover_screen._join` — the join flow was trying to insert a *new* isle with a local ID, but the isle already existed. Rewrote to just insert a `memberships` row against the existing isle's real ID.

## Investigated and dismissed

- **`auth.uid()` returning NULL on the web client** — turned out not to be the issue. The actual problem was always the FK error from the duplicate insert, which masked the real success.
- **RLS recursion** — early policies referenced `isles` and `memberships` in a loop. Fixed with a `SECURITY DEFINER` helper function (`public.is_member`) that bypasses RLS for the cross-table check.
- **Stale JWT after email verification** — symptom would be 401/403 on every query. Our 409 + 23503 errors were the FK bug, not auth. (Still worth re-signing in if you ever see 401s.)

## Known gaps to address

1. **Test data in `isles` table** — 4 leftover entries from development. The League screen shows all of them (correct), the Home screen hides those with no keys (also correct per spec §9 — "active isles only").
2. **Home filter is strict** — `isles.where((i) => i.isActive).toList()` means an Isle with zero keys doesn't render on Home. A new user who creates an Isle but doesn't add a key will not see it on Home (only on the Isles list and League). Worth deciding: add a "create your first key" prompt on the territory slot, or just point them to the Isles list.
3. **Discover Join** works for public isles, but only if you're authenticated and the policy allows. Membership row uses the real `auth.uid()` now.
4. **Friends / unfriend** — provider is local-only; `friends` table writes are stubbed.
5. **Real images** — post + log photo fields exist in the data model, but actual capture/display is the Flutter-port phase.
6. **Spark writes** — fire-and-forget; no error UI if the Supabase write fails.
