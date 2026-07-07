# Goal Isle

A calm, minimal habit-ritual Flutter web app. You open it, see your sparks floating on quiet water, you tend to them, you close it.

> **Status:** Spec v2 locked (July 3, 2026) — adds communities, metric sparks, posts, discovery for the LSAT-studier wedge. Mockups and Flutter code still reflect v1 and are pending update. See [`CURRENT_STATUS.md`](CURRENT_STATUS.md) for the current state.

---

## What This Is

**Goal Isle** is a Flutter web app for tracking recurring habits as small social rituals. The core object is the **Isle Spark**:

- **Isle Spark** is a recurring commitment, represented by a main emoji (the "result" you want).
- **Dependencies** are the "ingredients" — 0, 1, 2, or more emojis that must appear in the spark's chat before it lights.
- **Completion is social and chat-driven:** you light a spark by typing its emoji-ingredients (or reacting to messages that have them).
- **Streaks** are a core motivator. A missed spark fades grey and sinks; completing cycles builds a streak (streak ≥ 2 shows a number badge).

The Flutter codebase is mid-migration — it still uses the old Isle/Goal/Sub-point/Mass model. The HTML/CSS mockups are the current source of truth for the design.

---

## Quick Start

### Run the Flutter App (old model)

```bash
cd /home/jasper/projects/goal_isle
flutter run -d chrome
# Or serve the existing build:
cd build/web && python3 -m http.server 8094
# Open: http://localhost:8094
```

> ⚠️ The Flutter app shows the **old design** (Isle/Goal/Sub-point/Mass). The new design is being iterated in the HTML mockups below.

### Run the Design Mockups (current)

```bash
cd /home/jasper/projects/goal_isle
python3 -m http.server 8095
# Then open in a browser:
# • sparks.html:  http://localhost:8095/docs/design/mockups/sparks.html
# • shape-lab.html: http://localhost:8095/docs/design/mockups/shape-lab.html
# • create-spark.html: http://localhost:8095/docs/design/mockups/create-spark.html
# • buttons.html:  http://localhost:8095/docs/design/mockups/buttons.html
```

See [`docs/design/MOCKUPS.md`](docs/design/MOCKUPS.md) for details.

### Build

```bash
flutter build web --no-tree-shake-icons
```

### Test

```bash
flutter test
```

---

## The Design

**Minimal. Literal. Clean/cool.** — three words that define everything.

- **Minimal:** one primary action per screen, no decoration.
- **Literal:** sparks float on water — each spark = one recurring ritual.
- **Clean / cool:** cool palette (slate water, white surfaces, blue accent), modern sans-serif, subtle depth.

The product was redesigned on July 1, 2026 (v1) and re-locked as **v2 on July 3, 2026** around a wedge (LSAT studiers). Read [`docs/design/ISLE_SPARKS_SPEC_v2.md`](docs/design/ISLE_SPARKS_SPEC_v2.md) for the governing spec (v1 retained as history).

---

## Documentation

### 📍 Start Here

| Doc | Purpose |
|---|---|
| [`docs/design/ISLE_SPARKS_SPEC_v2.md`](docs/design/ISLE_SPARKS_SPEC_v2.md) | 🔒 **THE governing spec — Isle Sparks v2.** Read this first. |
| [`docs/design/ISLE_SPARKS_SPEC.md`](docs/design/ISLE_SPARKS_SPEC.md) | v1 spec — historical, superseded by v2. |
| [`docs/design/MOCKUPS.md`](docs/design/MOCKUPS.md) | How to run the design mockups (sparks, shape-lab, create-spark, buttons). |
| [`CURRENT_STATUS.md`](CURRENT_STATUS.md) | What's working, what's broken, what's next. Single source of truth. |
| [`docs/AUDIT_2026_07_01.md`](docs/AUDIT_2026_07_01.md) | Whole-repo vestigial-information audit — what's outdated, what to fix. |
| [`docs/HISTORY.md`](docs/HISTORY.md) | Project timeline + Key Decisions table. |

### 🎨 Design

| Doc | Purpose |
|---|---|
| [`docs/design/README.md`](docs/design/README.md) | Design docs index. |
| [`docs/design/TOKENS.md`](docs/design/TOKENS.md) | Design tokens (colors, typography, spacing, motion). Layout section removed (orphaned). |
| [`docs/archive/VISION.md`](docs/archive/VISION.md) | Archived — the original vibe doc. Three Words still hold; most concrete examples are outdated. |

### 🛠 Development & History

| Doc | Purpose |
|---|---|
| [`FLUTTER_DEBUG_LOG.md`](FLUTTER_DEBUG_LOG.md) | Debugging history — why Flutter now renders. |
| [`docs/HISTORY.md`](docs/HISTORY.md) | Project timeline + Key Decisions table. |
| [`docs/archive/`](docs/archive/) | Outdated docs (VISION, SCREENS, ARCHITECTURE, DEVELOPMENT, UI_DEVELOPMENT_PLAN, old mockup). |

### 📦 Archive

Outdated or historical docs (debugging logs, mockup-focused guides, superseded plans) live in [`docs/archive/`](docs/archive/).

---

## Project Structure

```
goal_isle/
├── README.md                       # This file (root entry)
├── CURRENT_STATUS.md               # Project state, source of truth
├── FLUTTER_DEBUG_LOG.md            # Debugging history
├── docs/
│   ├── AUDIT_2026_07_01.md         # Vestigial-information audit
│   ├── HISTORY.md                  # Project timeline + Key Decisions
│   ├── archive/                    # Outdated docs
│   │   ├── README.md
│   │   ├── VISION.md
│   │   ├── SCREENS.md
│   │   ├── ARCHITECTURE.md
│   │   ├── DEVELOPMENT.md
│   │   ├── UI_DEVELOPMENT_PLAN.md
│   │   ├── goal_isle_working_mockup.html
│   │   └── BEACH_LINE.md           # Beach-line design (deferred)
│   └── design/                     # Design docs
│       ├── README.md
│       ├── ISLE_SPARKS_SPEC_v2.md  # 🔒 THE governing spec (v2)
│       ├── ISLE_SPARKS_SPEC.md     # v1 spec (historical)
│       ├── MOCKUPS.md
│       ├── TOKENS.md
│       └── mockups/                # HTML/CSS design mockups
│           ├── sparks.html
│           ├── shape-lab.html
│           ├── create-spark.html
│           └── buttons.html
├── lib/                            # Flutter source code (mid-migration)
│   ├── main.dart
│   ├── models/                     # Data models (old model)
│   ├── providers/                  # Riverpod state notifiers
│   ├── screens/                    # Screens (old model)
│   ├── services/                   # Disabled backend services
│   ├── widgets/                    # Reusable widgets (old model)
│   └── theme/                      # Design tokens (light mode)
├── test/
│   └── widget_test.dart
├── web/
│   └── index.html                  # Flutter web entry
└── pubspec.yaml                    # Dependencies
```

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.44.2 (web target) |
| Language | Dart 3.12.2 |
| State management | Riverpod 2.6.1 |
| Design | Material 3 (currently), will move to custom tokens |
| Backend | None — all data is mocked |
| Build | `flutter build web --no-tree-shake-icons` |
| Version control | Git on `main`, remote `git@github.com:JDeez0/goal-isle.git` |

---

## Contributing

This is a solo project. The single developer is JD (Jasper) — `jasperhdeen@gmail.com`.

If you want to suggest changes, open an issue on GitHub.

---

*Last updated: July 1, 2026.*