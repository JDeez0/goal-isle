# Goal Isle — Development Workflow

## Robust iterative development for a project without a Mac

---

## 📐 Core Philosophy

> **The web is our iOS simulator. CI is our Mac. Every push is a TestFlight build.**

This workflow is designed around one hard constraint: **you cannot test iOS locally**.
Everything else flows from that. We compensate with:
1. **Web-as-proxy** for fast UI/UX iteration
2. **CI-as-gate** for iOS validation
3. **Defensive conventions** that prevent iOS-breaking changes from reaching main
4. **Feature flags** that let you ship incomplete features safely

---

## 🔀 Branching Strategy

### The model: `main` is always shippable

```
main ──────────────────────────────────────────────► (always deploys to TestFlight)
  │
  ├── feat/spark-editor ──────► merge only when Dart-analyze-clean
  │
  ├── fix/chat-scroll ────────► merge only when Dart-analyze-clean
  │
  └── exp/notifier-migration ─► never merge to main (throwaway experiment)
```

### Rules

| Rule | Why |
|------|-----|
| `main` is **always shippable** | Every push to main triggers a TestFlight build. If main is broken, TestFlight is broken. |
| All work happens in **feature branches** | `feat/*`, `fix/*`, `chore/*` — never commit directly to main |
| `flutter analyze` must pass **with 0 errors** before merge | Analyzer errors that slip into main = CI build failure |
| `flutter run -d chrome` must work before merge | If the app doesn't render in web, it won't render on iOS |
| Rebase, don't merge-commit | Clean linear history on main — easier to bisect if a build breaks |
| `exp/*` branches are throwaway | Mark experimental branches — never merge them |

### Feature branch workflow

```bash
# 1. Create branch from latest main
git checkout main
git pull origin main
git checkout -b feat/my-feature

# 2. Iterate locally (fast feedback loop)
# edit Dart files → flutter run -d chrome → test → repeat

# 3. Before pushing for the first time:
flutter analyze                          # must be 0 errors
flutter run -d chrome                    # must render correctly

# 4. Push and open a PR
git push -u origin feat/my-feature
# Review diff thoroughly before merging

# 5. After merge, CI auto-builds and uploads to TestFlight
# Check the CI run → check TestFlight on your iPhone
```

### When to trigger a TestFlight build

| Trigger | How |
|---------|-----|
| Every merge to `main` | Automatic (push trigger) |
| "I want to test this branch on my iPhone" | Manually run the workflow on your branch |
| "I need a build for someone else to test" | Merge to main, or run workflow manually |

---

## 🔄 Local Development Loop

### The 3-minute cycle

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Edit Dart   │──►  │  flutter run │──►  │  Test in     │──►  │  git push    │
│  in lib/     │     │  -d chrome   │     │  browser     │     │  (if ready)  │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

### Web proxy testing — what works and what doesn't

| ✅ Works perfectly in web | ⚠️ Works differently in web | ❌ Won't work in web |
|---|---|---|
| All Riverpod state logic | Image picker (uses web file picker) | Camera |
| GoRouter navigation | Scroll behavior (slightly different) | Push notifications |
| Supabase auth (email/password) | Auth sessions (web uses localStorage) | Native deep links |
| Chat messages (send/receive) | Form factor (mouse vs touch) | iOS-specific widgets |
| Isle/spark CRUD | Font rendering (tiny differences) | | 
| Metric log persistence | Keyboard behavior | |
| Friends flows | | |

**Rule:** If a feature involves native plugins (camera, image picker, etc.), test the core logic in web, but **always verify on TestFlight** before shipping. The web can test the data flow, state machine, and UI layout — it just can't test the native integration.

### Common scenarios and how to test them

| Scenario | Web test | TestFlight test |
|----------|----------|-----------------|
| New screen | ✅ `flutter run -d chrome` | Wait for CI build |
| Fixed a bug in state logic | ✅ Test in browser | Wait for CI build |
| Changed Supabase query | ✅ Test in browser | Wait for CI build |
| Added a new native plugin | ⚠️ Test logic in web | **Must test on TestFlight** |
| Changed storyboard or Info.plist | ❌ Can't test in web | **Must test on TestFlight** |
| Changed signing config | ❌ Can't test in web | **Must test on TestFlight** |

---

## 🛡️ Defensive Conventions

### 1. The `flutter analyze` gate

**Before every push, run:**

```bash
cd /home/jasper/projects/goal_isle
export PATH="/home/jasper/flutter/bin:$PATH"
flutter analyze
```

**Required:** 0 errors. Warnings and info are acceptable but should be minimized.

**Why:** `flutter analyze` catches:
- Null safety violations (potential crashes)
- Unused imports (dead code)
- Missing overrides (broken inheritance)
- Type mismatches (runtime errors)
- Missing required parameters

### 2. Protected files — never edit in a feature branch

These files are **load-bearing for the iOS build**. If you need to change them,
do it in a dedicated `chore/ios-*` branch and test with a manual CI run first.

| File | What it does | Why it's protected |
|------|-------------|-------------------|
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode build config | Signing, team ID, bundle ID |
| `ios/Runner/Info.plist` | iOS app metadata | Scene manifest, storyboard refs, permissions |
| `ios/Runner/Base.lproj/*.storyboard` | Flutter view controller | SceneDelegate needs this |
| `.github/workflows/ios-build.yml` | CI pipeline | Signing, archiving, TestFlight upload |
| `cer.enc` / `key.enc` / `profile.enc` | Encrypted signing materials | CI needs these to sign |

### 3. Safe files — edit freely

| Location | What's there | Safe? |
|----------|-------------|-------|
| `lib/` | All Dart code | ✅ 100% safe — cannot break iOS build |
| `pubspec.yaml` | Dependencies | ✅ Safe for pure Dart deps; ⚠️ risky for native plugins |
| `ios/Runner/Assets.xcassets/` | App icon, images | ✅ Safe |
| `supabase_*.sql` | SQL scripts | ✅ Safe (run in Supabase editor, not in CI) |

### 4. Feature flags for incomplete features

If you're building a feature that takes multiple commits to finish, use a
**feature flag** so incomplete code never reaches the TestFlight user:

```dart
// In lib/core/app_config.dart
class AppConfig {
  /// Flip this to true when the feature is complete.
  static const bool enableNewSparkEditor = false;
}

// In the UI:
if (AppConfig.enableNewSparkEditor) {
  return const NewSparkEditorScreen();
} else {
  return const NewSparkScreen(); // old, stable
}
```

This way you can merge to main, ship to TestFlight, and the incomplete feature
is invisible to testers. When it's ready, flip the flag to `true` and push.

### 5. Supabase schema changes

**Never modify the schema while people are testing.** If you need to add a column
or change a table:

1. Create the migration SQL in a new file (`supabase_migration_N.sql`)
2. Run it in the Supabase SQL Editor
3. Update `supabase_schema.sql` to reflect the new state
4. If the change is backward-incompatible, deploy the Dart code first (with
   the old query), then run the migration, then update the Dart code in a
   second commit

---

## 🧪 Testing Strategy

### What to test before every push

```
✓ flutter analyze (0 errors)
✓ flutter run -d chrome (app renders, auth screen loads)
✓ Sign in (email/password)
✓ Create an isle (appears on home screen)
✓ Create a spark (appears in the isle)
✓ Send a chat message (appears in isle chat)
✓ Navigate between tabs (Home, Notes, League)
```

### What to test on TestFlight (weekly or per-feature)

```
✓ Fresh install + sign up (new account)
✓ Close and reopen app (data persists)
✓ Create isle → create spark → close app → reopen (isle/spark still there)
✓ Send chat message → close app → reopen (message still there)
✓ Log metric → close app → reopen → check thread screen (log persists)
✓ Friend request flow (send → accept → decline)
✓ Sign out → sign back in (data reloads correctly)
```

### What to test before a major release

```
✓ All of the above
✓ Image picker (post composer)
✓ Multiple isles with multiple sparks
✓ Long chat conversations (scrolling)
✓ Network offline behavior (airplane mode → open app)
✓ Fresh install on a device that's never had the app
```

---

## 🔧 Handling the macos-26 Runner Flakiness

### The problem

The GitHub Actions `macos-26` runner has an intermittent issue where
`xcodebuild archive -sdk iphoneos` fails with:
```
Found no destinations for the scheme 'Runner' and action archive.
```

This happens ~25-30% of the time. It's a known runner-side issue
(the iOS 26 platform sometimes isn't fully registered despite
`xcodebuild -downloadPlatform iOS` succeeding).

### The mitigation

1. **Retry is the fix.** The next run almost always succeeds with zero
   code changes. Just push an empty commit:
   ```bash
   git commit --allow-empty -m "ci: retry (runner flakiness)"
   git push origin main
   ```

2. **Don't spend time debugging it.** This is a GitHub runner issue,
   not a code issue. If the build fails with "Found no destinations"
   and the signing step succeeded, it's the runner — retry.

3. **Monitor the pattern.** If it starts happening more than 50% of the
   time, we may need to pin a specific runner image version or add a
   retry loop to the workflow.

### How to tell if it's runner flakiness vs a real build error

| Symptom | Is it runner flakiness? |
|---------|------------------------|
| "Found no destinations for the scheme 'Runner'" | ✅ Yes — retry |
| "No valid code signing certificates" | ❌ No — real signing issue |
| "SDK version issue" / "Validation failed" | ❌ No — real upload issue |
| "Storyboard" or "ibtool" error | ❌ No — real platform/SDK issue |
| "ARCHIVE SUCCEEDED" then fails later | ❌ No — real export/upload issue |

---

## 📦 Adding New Dependencies

### Safe (pure Dart)

```yaml
# These are always safe — no native code, no iOS build impact
dependencies:
  intl: ^0.19.0          # ✅ safe
  http: ^1.2.0           # ✅ safe
  freezed_annotation: ... # ✅ safe (but no codegen!)
```

### Risky (native plugins)

```yaml
# These have native iOS code — test on TestFlight before shipping
dependencies:
  camera: ^0.11.0        # ⚠️ must test on TestFlight
  geolocator: ^12.0.0    # ⚠️ must test on TestFlight
  # ⚠️ Must be SPM-compatible (not CocoaPods-only)
  # ⚠️ May need Info.plist permission strings
  # ⚠️ Verify the build passes in CI before merging
```

### Process for adding a native plugin

1. Add to `pubspec.yaml`
2. `flutter pub get`
3. `flutter analyze` — ensure no new errors
4. Push to a feature branch
5. **Manually trigger the CI workflow on that branch** (don't merge to main yet)
6. If CI passes → test on TestFlight → merge to main
7. If CI fails → check if plugin is SPM-compatible. If CocoaPods-only, find an alternative.

---

## 🚨 Emergency Procedures

### "The TestFlight build is broken and I need to ship NOW"

1. **Check which commit broke it.** Look at the CI history — the last green
   commit is the last known-good build.
2. **Revert to the last green commit:**
   ```bash
   git log --oneline -5  # find the last green commit
   git revert <broken-commit>
   git push origin main
   ```
3. CI builds the reverted code → TestFlight gets the last-known-good version.

### "I accidentally edited a protected file"

1. **Check what changed:**
   ```bash
   git diff HEAD~1 -- ios/Runner.xcodeproj/project.pbxproj
   git diff HEAD~1 -- ios/Runner/Info.plist
   ```
2. **If the changes are cosmetic:** It might be fine. Push and watch CI.
3. **If the changes touch signing or storyboard references:** Revert immediately:
   ```bash
   git checkout HEAD~1 -- ios/Runner.xcodeproj/project.pbxproj
   git checkout HEAD~1 -- ios/Runner/Info.plist
   git commit -m "fix: revert accidental protected file changes"
   git push origin main
   ```

### "The CI is down entirely (GitHub outage)"

1. The last successful IPA is still downloadable as a GitHub artifact.
2. Go to the Actions tab → click the last green run → scroll to Artifacts
   → download "GoalIsle-iOS".
3. Upload manually via Transporter or `xcrun altool` if you have Mac access.

---

## 📋 Pre-Push Checklist

Copy this and check it off before every push:

```
□ flutter analyze (0 errors)
□ flutter run -d chrome (app renders correctly)
□ No changes to project.pbxproj, Info.plist, or storyboards
□ No changes to .github/workflows/ios-build.yml
□ No new native plugins (or if yes, tested on a separate CI run)
□ Feature branch is rebased on latest main
□ Commit messages are descriptive
```

---

## 🔄 Pre-Merge Checklist

Before merging a feature branch to main:

```
□ All commits squashed or cleanly rebased
□ flutter analyze (0 errors) on the branch
□ Tested on web (flutter run -d chrome)
□ Reviewed the diff (git diff main...feature-branch)
□ No protected files touched
□ Feature flag is OFF if feature is incomplete
□ If native plugin added: CI passed on the branch
```

---

*This workflow is a living document. Update it as the project evolves.*