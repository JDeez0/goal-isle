# Goal Isle

A calm, minimal goal-tracking Flutter web app. You open it, see your isles floating on quiet water, tend to them, close it.

> **Status:** UI design phase. Flutter web app renders in browser. Design tokens, widget library, and screen-by-screen build-out are next.

---

## What This Is

**Goal Isle** is a Flutter web app for tracking goals with an "isle" metaphor:

- **Isles** are major life goals (fitness, learning, saving).
- **Goals** are peaks on each isle (specific objectives).
- **Sub-points** are paths or terrain features (daily/weekly tasks).
- **Mass** is the visual indicator of progress on an isle.

The current codebase is **fully functional** but uses **mock data** (no backend). The design is being built from scratch in Flutter with hot reload.

---

## Quick Start

### Run the Flutter App (current build)

```bash
cd /home/jasper/projects/goal_isle
flutter run -d chrome
# Or serve the existing build:
cd build/web && python3 -m http.server 8094
# Open: http://localhost:8094
```

### Run the Archived HTML Mockup

```bash
cd /home/jasper/projects/goal_isle
python3 -m http.server 9999
# Open: http://localhost:9999/goal_isle_working_mockup.html
```

### Build

```bash
/home/jasper/flutter/bin/flutter build web --no-tree-shake-icons
```

### Test

```bash
/home/jasper/flutter/bin/flutter test
```

---

## The Design

**Minimal. Literal. Clean/cool.** — three words that define everything.

- **Minimal:** one primary action per screen, no decoration, no gamification noise.
- **Literal:** isles are visible as floating land masses on a calm water-like background.
- **Clean / cool:** cool color palette (slate water, white surfaces, blue accent), modern sans-serif typography, subtle depth.

Read [`docs/design/VISION.md`](docs/design/VISION.md) for the full vibe.

---

## Documentation

### 📍 Start Here

| Doc | Purpose |
|---|---|
| [`CURRENT_STATUS.md`](CURRENT_STATUS.md) | What's working, what's broken, what's next. Single source of truth for project state. |
| [`UI_DEVELOPMENT_PLAN.md`](UI_DEVELOPMENT_PLAN.md) | The 7-phase plan for building the UI. |
| [`FLUTTER_DEBUG_LOG.md`](FLUTTER_DEBUG_LOG.md) | The full debugging history that got Flutter rendering. |

### 🎨 Design

| Doc | Purpose |
|---|---|
| [`docs/design/README.md`](docs/design/README.md) | Index for design docs. |
| [`docs/design/VISION.md`](docs/design/VISION.md) | The vibe, personality, core metaphor. |
| [`docs/design/SCREENS.md`](docs/design/SCREENS.md) | The screen inventory. |
| [`docs/design/TOKENS.md`](docs/design/TOKENS.md) | Design tokens (colors, typography, spacing, motion). |

### 🛠 Development

| Doc | Purpose |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Current code architecture (Flutter app, providers, screens). |
| [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) | How to set up, build, test, and develop. |
| [`docs/HISTORY.md`](docs/HISTORY.md) | Project timeline — every significant decision and event. |

### 📦 Archive

Outdated or historical docs (debugging logs, mockup-focused guides, superseded plans) live in [`docs/archive/`](docs/archive/).

---

## Project Structure

```
goal_isle/
├── README.md                       # This file (root entry)
├── CURRENT_STATUS.md               # Project state, source of truth
├── UI_DEVELOPMENT_PLAN.md          # 7-phase plan for UI work
├── FLUTTER_DEBUG_LOG.md            # Why Flutter now renders
├── docs/
│   ├── ARCHITECTURE.md             # Code architecture
│   ├── DEVELOPMENT.md              # How to develop
│   ├── HISTORY.md                  # Project timeline
│   ├── design/                     # Design intent
│   │   ├── README.md
│   │   ├── VISION.md
│   │   ├── SCREENS.md
│   │   └── TOKENS.md
│   └── archive/                    # Outdated docs
├── lib/                            # Flutter source code
│   ├── main.dart
│   ├── models/                     # Data models
│   ├── providers/                  # Riverpod state notifiers
│   ├── screens/                    # Screens by feature
│   ├── services/                   # (Disabled) backend services
│   ├── widgets/                    # Reusable widgets
│   └── theme/                      # Design tokens (Phase 2)
├── test/
│   └── widget_test.dart
├── web/
│   └── index.html                  # Flutter web entry
├── pubspec.yaml                    # Dependencies
└── goal_isle_working_mockup.html   # Archived HTML mockup
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

*Last updated: June 22, 2026.*