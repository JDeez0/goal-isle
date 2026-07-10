# Goal Isle — Development Guide

**How to edit UX/UI and functionality safely without breaking the iOS build.**

---

## 🚨 The Golden Rules

1. **NEVER edit `project.pbxproj` signing settings** (team ID, CODE_SIGN_IDENTITY, CODE_SIGN_STYLE, PROVISIONING_PROFILE_SPECIFIER, PRODUCT_BUNDLE_IDENTIFIER)
2. **NEVER remove `Main.storyboard` or `LaunchScreen.storyboard`** — FlutterSceneDelegate needs them
3. **NEVER edit `Info.plist` scene manifest** (UIApplicationSceneManifest, UISceneStoryboardFile)
4. **NEVER remove `cer.enc`, `key.enc`, `profile.enc`** from the repo — CI needs them
5. **NEVER add a CocoaPods-only plugin** to pubspec.yaml — this project uses Swift Package Manager
6. **ALWAYS test with `flutter run -d chrome`** before pushing — web is our local proxy for iOS
7. **ALWAYS run `flutter analyze`** before pushing — 0 errors required

---

## 📁 File Safety Guide

### DO NOT TOUCH (would break the build)

| File / Setting | Why |
|---|---|
| `project.pbxproj` signing block | Team `3X37886R5C`, cert `Apple Distribution`, profile `GoalIsle Distribution` |
| `project.pbxproj` shell-script phases | Flutter build hooks (`xcode_backend.sh`) |
| `project.pbxproj` SPM package reference | `FlutterGeneratedPluginSwiftPackage` links native plugins |
| `Info.plist` → `UIApplicationSceneManifest` | Scene-based launch config for FlutterSceneDelegate |
| `Info.plist` → `UIMainStoryboardFile` / `UILaunchStoryboardName` | Storyboard references |
| `Info.plist` → `UIRequiresFullScreen` | iPad multitasking validation |
| `Info.plist` → `ITSAppUsesNonExemptEncryption` | Export compliance bypass |
| `Info.plist` → `NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription` | App Store required (image_picker) |
| `Main.storyboard` / `LaunchScreen.storyboard` | FlutterSceneDelegate + launch screen |
| `.github/workflows/ios-build.yml` core steps | Signing, two-phase build, TestFlight upload |
| `cer.enc` / `key.enc` / `profile.enc` | Encrypted signing materials (CI decrypts these) |
| `pubspec.lock` | CI determinism |
| `IPHONEOS_DEPLOYMENT_TARGET` | Must be ≥15.0 (scene-based launch needs 14+) |

### SAFE TO EDIT

| File / Setting | What you can do |
|---|---|
| **All `lib/` Dart files** | Edit freely — this is the app logic/UI. Cannot break signing. |
| `pubspec.yaml` pure-Dart deps | Add/remove Dart-only packages freely |
| `pubspec.yaml` native deps | ⚠️ Must be SPM-compatible (not CocoaPods-only). May need Info.plist usage strings. |
| `Info.plist` orientations | Add/remove `UISupportedInterfaceOrientations` |
| `Info.plist` display name | Change `CFBundleDisplayName` |
| `project.pbxproj` warning flags | `CLANG_WARN_*`, `GCC_WARN_*` — cosmetic |
| `project.pbxproj` Swift version | Can bump (currently 5.0) |
| `ios/Runner/Assets.xcassets` | Add app icon, launch image, colors |

---

## 🔄 Safe Development Workflow

### When editing UI/UX (Dart code only)

1. **Edit** the Dart file(s) in `lib/`
2. **Test locally:** `flutter run -d chrome`
3. **Analyze:** `flutter analyze` (0 errors required)
4. **Push:** `git push origin main`
5. CI auto-builds + uploads to TestFlight (~10 min)

This is 100% safe — Dart-only changes cannot affect signing, storyboards, or the build pipeline.

### When adding a new screen

1. Create the screen file in `lib/features/<feature>/presentation/`
2. Add the route in `lib/app/router.dart` (in the routes list)
3. Test in web, analyze, push

### When adding a new Flutter package

1. **Check if it's pure Dart** (no native iOS code):
   - Pure Dart: `flutter_riverpod`, `go_router`, `http` → **safe**, just add to pubspec
   - Native plugin: `image_picker`, `camera`, `geolocator` → **risky**, see below
2. For native plugins:
   - Verify it supports **Swift Package Manager** (not CocoaPods-only)
   - Check if it needs an Info.plist permission string (e.g. `NSLocationWhenInUseUsageDescription`)
   - Test that the build still works by pushing and watching CI
   - If CI fails at `-resolvePackageDependencies`, the plugin is likely CocoaPods-only

### When changing the app icon

1. Generate icons at https://appicon.co or similar
2. Replace files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
3. Do NOT change `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` in pbxproj
4. Push — CI rebuilds with the new icon

### When bumping Flutter or dependencies

1. Test locally first: `flutter upgrade && flutter pub get && flutter run -d chrome`
2. Run `flutter analyze` — fix any new warnings
3. Push and watch CI closely — Flutter version changes can affect:
   - `xcode_backend.sh` (the Flutter build hook)
   - SPM plugin generation
   - SceneDelegate template
4. If the build breaks after a Flutter upgrade, the most likely cause is the two-phase build (`--config-only` + `xcodebuild archive`) needing adjustment for new Flutter internals

---

## 🛡️ What Protects the Build

1. **`if: always()` on artifact upload** — even if TestFlight upload fails, you always get a downloadable IPA
2. **`--validate-app` before upload** — catches invalid IPAs before wasting a TestFlight slot
3. **Incrementing build numbers** — `GITHUB_RUN_NUMBER` prevents Apple's "duplicate build" rejection
4. **Encrypted signing materials** — `key.enc`/`cer.enc`/`profile.enc` are AES-256-CBC encrypted, safe in git
5. **`flutter analyze` locally** — catches Dart errors before they reach CI
6. **Web proxy testing** — `flutter run -d chrome` validates logic/UI without needing iOS

---

## ⚠️ Known Fragilities

| Risk | Mitigation |
|---|---|
| `macos-26` runner image changes | Monitor GitHub Actions release notes; pin if unstable |
| `flutter stable` unpinned in CI | Consider pinning to a specific Flutter version |
| `xcrun altool` deprecation | May need migration to `notarytool` or App Store Connect API in 1-2 Xcode versions |
| iOS 26 SDK platform download | `xcodebuild -downloadPlatform iOS` handles this; check if it fails |
| Two-phase build depends on Flutter internals | If `--config-only` behavior changes in a Flutter update, adjust |
