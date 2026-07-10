# Goal Isle — UX/UI Iteration Plan

## How to edit the app efficiently with zero wasted troubleshooting

---

## 🎯 The Core Principle

> **Flutter is the single source of truth. The web browser is our local test target. TestFlight is our iOS validation. Change only one thing at a time.**

---

## 🏎️ The Fastest Edit-to-TestFlight Cycle

```
  ┌─────────────┐
  │  Edit Dart   │  ← 30 seconds
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  flutter     │  ← 1 second (pre-push hook runs this automatically)
  │  analyze     │
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  flutter run │  ← 30 seconds (hot reloads in 2s after first build)
  │  -d chrome   │
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  Test in     │  ← 1 minute (click through the changed screens)
  │  browser     │
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  git push    │  ← 5 seconds
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  CI builds   │  ← 7 minutes (automatic, just watch)
  │  + validates │
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  Merge to    │  ← 5 seconds
  │  main        │
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  CI builds   │  ← 10 minutes (automatic)
  │  + TestFlight│
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  Test on     │  ← 2 minutes
  │  iPhone      │
  └─────────────┘

  Total: ~20 minutes per cycle (most of it automated)
```

---

## 📐 Decision Tree: Which Workflow Should I Use?

```
What are you changing?
│
├── Dart code only (existing screen) ───► Workflow A: Direct Flutter
│
├── Dart code only (new screen)      ───► Workflow B: Flutter scaffold first
│
├── Design exploration (visual only) ───► Workflow C: HTML mockup
│
├── Database schema                  ───► Workflow D: SQL migration
│
├── Native plugin or iOS config      ───► Workflow E: Feature branch + manual CI
│
└── Multiple things at once          ───► STOP. Do one thing at a time.
```

---

## Workflow A: Direct Flutter (Existing Screen)

**Use when:** Refining an existing screen, fixing a bug, tweaking layout/spacing/colors.

**Why this is the best workflow:** No context switching. Single codebase. Tests real business logic and Supabase integration. ~20 min to TestFlight.

### Step-by-step

```bash
# 1. Create a feature branch
git checkout main
git pull origin main
git checkout -b fix/home-spacing

# 2. Edit the Dart file(s)
#    lib/features/isles/presentation/home_screen.dart

# 3. Hot reload in browser (if flutter run is already running)
#    Press 'r' in the terminal (instant)

# 4. Test in browser:
#    - Does it look right?
#    - Can you still create isles/sparks?
#    - Can you still send chat messages?
#    - Does the auth flow still work?

# 5. Push. The pre-push hook runs flutter analyze automatically.
git add -A
git commit -m "fix: adjust home screen spark spacing"
git push -u origin fix/home-spacing

# 6. CI validates the build on macos-26 (~7 min)
#    Check: https://github.com/JDeez0/goal-isle/actions

# 7. If CI passes, merge to main
git checkout main
git merge fix/home-spacing
git push origin main

# 8. CI builds + uploads to TestFlight (~10 min)
#    Install on your iPhone and verify
```

### ⚡ Speed tips for Workflow A

- **Keep `flutter run -d chrome` running** in a terminal. Hot reload ('r') is instant.
- **Use `const` everywhere possible** — faster rebuilds.
- **Test the full flow, not just the screen** — create isle → create spark → chat → log metric. A spacing change shouldn't break business logic, but verify.
- **Commit small, commit often** — if a commit breaks something, `git revert` is easy.

---

## Workflow B: Flutter Scaffold First (New Screen)

**Use when:** Building a completely new screen from scratch.

**Why this workflow:** No dual work (mockup then port). Start with a bare-bones Flutter screen, get the routing and data flow working, then iterate visually.

### Step-by-step

```bash
# 1. Create a feature branch
git checkout -b feat/new-analytics-dashboard

# 2. Create the screen file
#    lib/features/analytics/presentation/analytics_screen.dart

# 3. Add the route in lib/app/router.dart
#    GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),

# 4. Build the MINIMAL VIABLE screen:
#    - Scaffold with AppBar and title
#    - Body with placeholder text
#    - That's it. No styling yet.

# 5. Test navigation in browser:
#    - Can you navigate to the screen?
#    - Does the back button work?
#    - Does the bottom nav still work?

# 6. If navigation + data flow works, COMMIT this as a checkpoint.
git commit -m "feat: analytics screen scaffold + route"

# 7. NOW iterate on the visual design:
#    - Add widgets, spacing, colors
#    - Hot reload in browser to see changes instantly
#    - Commit each visual milestone

# 8. When the screen is complete:
#    - flutter analyze (0 errors)
#    - Test the full app flow
#    - Push, PR, merge, TestFlight (same as Workflow A)
```

### Why start with zero styling

The biggest time-waster is spending 2 hours on beautiful padding and colors, then discovering the navigation or data flow is broken. Start with **functionality first, styling second.** A working ugly screen is better than a beautiful blank one.

---

## Workflow C: HTML Mockup (Design Exploration)

**Use when:** Exploring a radically different visual design, trying multiple layouts quickly, or when you're not sure what you want yet.

**Why this workflow:** HTML mockups have instant feedback (save → refresh browser). No Flutter compile step. Perfect for the "I'll know it when I see it" phase of design.

### When to use HTML vs Flutter

| Use HTML when... | Use Flutter when... |
|---|---|
| Trying 3+ layout variations quickly | Refining an existing screen |
| Exploring a completely new visual language | The data flow is already clear |
| Need to share designs with non-developers | You need to test real Supabase data |
| "I'm not sure what I want yet" | "I know what I want, just need to build it" |
| Rapid color/typography/spacing experiments | Testing interaction (taps, swipes, scroll) |

### Step-by-step

```bash
# 1. Create the mockup
#    docs/design/mockups/new-feature.html

# 2. Serve and iterate:
cd /home/jasper/projects/goal_isle
python3 -m http.server 8095
# Open: http://localhost:8095/docs/design/mockups/new-feature.html

# 3. When the design is locked, port to Flutter:
#    - Create the screen (Workflow B)
#    - Copy colors, spacing, typography from the mockup
#    - Test in browser
#    - Push, PR, merge, TestFlight

# 4. Archive the mockup (don't delete it):
#    mv docs/design/mockups/new-feature.html docs/design/mockups/archive/
```

### ⚡ Speed tips for Workflow C

- **Use inline styles** in the HTML — no CSS files, no build tools. `<div style="padding: 16px; background: #F7F8FA">`
- **Use emoji for icons** — `🎯` instead of finding an SVG.
- **Use hardcoded fake data** — copy from mock_data.dart if needed.
- **Keep mockups in `docs/design/mockups/`** — they're part of the project history.
- **Archive, don't delete** — old mockups are useful reference.

---

## Workflow D: Database Schema Change

**Use when:** Adding/removing a column, creating a new table, changing RLS policies.

**Why this workflow:** Schema changes are the riskiest type of change — they can break the app for ALL users, not just the person making the change. Follow this exactly.

### Step-by-step

```bash
# 1. Write the migration SQL (do NOT modify supabase_schema.sql yet)
#    supabase_migration_003.sql

# 2. Run the migration in Supabase SQL Editor FIRST (before changing Dart code!)
#    - Must be backward-compatible (old code still works with new schema)
#    - E.g., ADD COLUMN with a DEFAULT value, never DROP COLUMN

# 3. If the migration is backward-compatible:
#    Update the Dart code to use the new column
#    Test in browser
#    Push, PR, merge, TestFlight

# 4. Once the new Dart code is deployed and working:
#    Update supabase_schema.sql to reflect the final state
#    Commit with a note: "post-migration schema update"
```

### Rules for safe schema changes

| ✅ Safe | ❌ Dangerous |
|--------|-------------|
| `ALTER TABLE ... ADD COLUMN ... DEFAULT ...` | `ALTER TABLE ... DROP COLUMN` |
| `CREATE TABLE ...` (new table) | `DROP TABLE` |
| `CREATE POLICY ...` (new policy) | Changing an existing policy's logic |
| `ALTER TABLE ... ALTER COLUMN ... SET DEFAULT` | `ALTER TABLE ... ALTER COLUMN ... TYPE` (unless nullable) |
| Adding a new index | Removing an index |

**Golden rule:** Old code must work with the new schema. New code must work with the old schema (during deployment). Only break backward compatibility when you're 100% sure the old code is gone.

---

## Workflow E: Native Plugin or iOS Config

**Use when:** Adding a plugin with native iOS code, changing Info.plist, changing project.pbxproj.

**Why this workflow:** iOS config changes can break the build silently (the app compiles but crashes at launch). You MUST test on TestFlight before merging to main.

### Step-by-step

```bash
# 1. Create a feature branch
git checkout -b feat/add-camera-plugin

# 2. Add the plugin to pubspec.yaml
# 3. Add any required Info.plist permission strings
# 4. flutter pub get
# 5. Test in browser (Dart logic only — native won't work in web)

# 6. Push to the feature branch
git push -u origin feat/add-camera-plugin

# 7. Manually trigger the CI workflow on this branch:
#    Go to: https://github.com/JDeez0/goal-isle/actions/workflows/ios-build.yml
#    Click "Run workflow" → select "feat/add-camera-plugin" → "Run workflow"

# 8. Wait for CI to complete (~10 min)

# 9. If CI SUCCEEDS:
#    - Download the IPA artifact
#    - Wait for the app to process in TestFlight (if you uploaded it)
#    - Test on your iPhone
#    - If it works, merge to main

# 10. If CI FAILS:
#     - Check the error in the CI log
#     - Common failures:
#       - Plugin is CocoaPods-only (SPM resolve fails)
#       - Missing Info.plist permission string
#       - Plugin doesn't support iOS 15.0 deployment target
#     - Fix and retry
```

### Pre-push hook behavior

The pre-push hook will **warn** you (but not block) when you change:
- `ios/Runner.xcodeproj/project.pbxproj` — requires confirmation to proceed
- `pubspec.yaml` — reminds you about SPM compatibility

---

## 🧪 The Test Matrix

### What to test for each change type

| Change type | Test in browser | Test on TestFlight |
|------------|----------------|-------------------|
| Spacing/layout tweak | ✅ Visual check | Optional |
| Color change | ✅ Visual check | Optional |
| New screen (Dart only) | ✅ Navigation + data flow | ✅ Visual on real device |
| Bug fix in state logic | ✅ Reproduce + verify fix | ✅ Reproduce + verify fix |
| Supabase query change | ✅ Data CRUD | ✅ Data CRUD + persistence |
| New native plugin | ⚠️ Dart logic only | ✅ **Required** |
| iOS config change | ❌ Can't test | ✅ **Required** |
| Database migration | ✅ After migration runs | ✅ Full flow |

---

## 🚫 Anti-Patterns: What NOT to Do

### ❌ DON'T: Commit directly to main

```bash
# WRONG:
git checkout main
# edit files...
git commit -m "fix something"
git push origin main   # ← This triggers a TestFlight build immediately!
```

If the change breaks something, TestFlight is broken until you fix it. Always use feature branches.

### ❌ DON'T: Change multiple unrelated things in one commit

```bash
# WRONG:
git commit -m "fix home spacing + change auth flow + update database schema"
```

If one of these breaks, you can't isolate which one. One commit = one logical change.

### ❌ DON'T: Change protected files in a feature branch

```bash
# WRONG (in any feature branch):
# editing ios/Runner.xcodeproj/project.pbxproj
# editing ios/Runner/Info.plist
```

These files need special care. Use a dedicated `chore/ios-*` branch and test with a manual CI run.

### ❌ DON'T: Edit Flutter code while CI is running

```bash
# WRONG:
# 1. Push to main (triggers CI)
# 2. Edit more files and push again (triggers ANOTHER CI run)
# 3. Edit more files and push again (triggers YET ANOTHER CI run)
```

Each push to main triggers a full CI build + TestFlight upload. Wait for CI to finish before pushing again. If you need to iterate quickly, use a feature branch.

### ❌ DON'T: Skip the pre-push hook

```bash
# WRONG:
git push --no-verify   # ← Skipping flutter analyze
```

The only time to use `--no-verify` is when the hook itself is broken. If `flutter analyze` finds errors, FIX them — don't skip them.

---

## 📋 Daily Workflow Checklist

Before starting your work session:

```
□ git pull origin main (get latest code + TestFlight build)
□ flutter clean && flutter pub get (fresh state)
□ flutter run -d chrome (start the web version, leave it running)
□ Open http://localhost:PORT in browser
```

When you're ready to ship:

```
□ flutter analyze (0 errors)
□ flutter run -d chrome (app renders, auth works, core flows work)
□ No protected files changed (or if yes, tested on a manual CI run)
□ Committed with a descriptive message
□ Pushed to a feature branch (not main)
□ CI passed on the feature branch (or PR)
□ Merged to main
□ Checked the CI run for the merge
□ Installed the TestFlight build on your iPhone
```

---

## 📊 Recommended Edit Cadence

| Frequency | What to do |
|-----------|-----------|
| **Every 5-10 minutes** | Edit Dart → hot reload in browser → check visually |
| **Every 30 minutes** | Commit a checkpoint (even if not done yet) |
| **Every 1-2 hours** | Push to feature branch, check CI |
| **End of work session** | Merge to main, wait for TestFlight build |
| **Next morning** | Test last night's build on iPhone |
| **Weekly** | Full TestFlight regression test (all core flows) |

---

*This plan is designed for your specific constraints: web-only local testing, iOS via TestFlight, protected files that can break the build. Follow it and you'll spend zero time troubleshooting.*