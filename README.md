# Goal Isle

A calm ritual/social app for small communities. Track recurring commitments
("Isle Keys" / sparks) inside shared communities ("Isles"), light them by
typing the right emoji ingredients in chat, and stay accountable with friends.

> **Status:** v2 app fully ported (20 screens, Supabase backend, **iOS on TestFlight**).
> See [`CURRENT_STATUS.md`](CURRENT_STATUS.md) for the current state.

---

## Quick Start

### Prerequisites
- Flutter 3.44+ / Dart 3.12+ (at `/home/jasper/flutter/bin/`)
- A Supabase project (URL + anon key in `lib/core/repositories/supabase/supabase_client.dart`)

### Run (web)
```bash
cd /home/jasper/projects/goal_isle
export PATH="/home/jasper/flutter/bin:$PATH"
flutter run -d chrome
```

### Run (iOS)
Install via **TestFlight**. Every push to `main` builds + uploads automatically
(see `.github/workflows/ios-build.yml`). Add your Apple ID as an internal tester
in App Store Connect → Goal Isle → TestFlight.

### Build
```bash
flutter build web --no-tree-shake-icons    # web
# iOS builds happen in GitHub Actions (macos-26 runner, Xcode 26)
```

### Test
```bash
flutter test
flutter analyze    # 0 errors
```

---

## What This Is

**Goal Isle** helps small communities stay accountable through shared rituals.

- **Isle** — a community (your LSAT study group, your gym crew, your family).
- **Spark / Isle Key** — a recurring commitment, represented by a main emoji.
- **Dependencies** — the "ingredients": 0–N emojis that must appear in the
  spark's chat before it lights.
- **Lighting a spark** is social and chat-driven: type the emoji ingredients
  (or react to messages that have them).
- **Streaks** motivate. A missed spark fades grey and sinks; completing cycles
  builds a streak (streak ≥ 2 shows a number badge).

The visual signature: sparks float as soft-aura rounded parallelograms on
quiet water. Lit sparks rise; greyed sparks sink.

---

## Architecture

- **State:** Riverpod (manual `StateNotifier`, no codegen)
- **Routing:** GoRouter with `StatefulShellRoute` (3 branches: Home / Notes / League)
- **Backend:** Supabase (Auth + Postgres + RLS), hybrid optimistic-local +
  fire-and-forget-write providers
- **Models:** Plain Dart (no freezed — Dart 3.12 analyzer breaks codegen)
- **iOS:** Storyboard-free programmatic launch via `SceneDelegate` +
  `FlutterSceneDelegate`; manual signing with "Apple Distribution" cert

See [`CURRENT_STATUS.md`](CURRENT_STATUS.md) for the full architecture map,
signing-material details, and the iOS build lessons.

---

## Docs

| Doc | Purpose |
|---|---|
| [`CURRENT_STATUS.md`](CURRENT_STATUS.md) | **Source of truth** — current state, next steps |
| [`docs/design/ISLE_SPARKS_SPEC_v2.md`](docs/design/ISLE_SPARKS_SPEC_v2.md) | **🔒 The governing spec** |
| [`docs/HISTORY.md`](docs/HISTORY.md) | Project timeline |
| [`SUPABASE_STATUS.md`](SUPABASE_STATUS.md) | Schema + RLS details |
| `.github/workflows/ios-build.yml` | iOS build + TestFlight pipeline |
