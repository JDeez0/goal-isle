# Goal Isle — Current Status

**Last updated:** July 10, 2026 — ✅ **Black screen fixed, app renders on TestFlight**
**Project:** `/home/jasper/projects/goal_isle/`
**Repo:** `git@github.com:JDeez0/goal-isle.git` (branch: `main`)

---

## ✅ What Works Right Now

### 1. Flutter App — v2, fully ported (20 screens)
A complete rewrite of the v2 spec: 44 Dart files, 20 screens, all wired
to Supabase. Riverpod state management (manual StateNotifier — no codegen).
GoRouter with StatefulShellRoute (3 bottom-nav branches: Home / Notes / League).

- **Run it (web):** `flutter run -d chrome`
- **Run it (iOS):** install via **TestFlight** ✅ **RENDERS CORRECTLY**
- **Build:** `flutter build web --no-tree-shake-icons` ✅
- **iOS build:** signed IPA + TestFlight upload via GitHub Actions ✅

### 2. iOS on TestFlight 🎉 — WORKING END-TO-END, CONFIRMED ON DEVICE
The app opens, renders the auth screen, and is usable on a real iPhone.
Every push to `main` triggers `.github/workflows/ios-build.yml` on a
`macos-26` runner (Xcode 26 / iOS 26 SDK, required by Apple since April 2026).
The workflow:
1. Decrypts committed signing materials (`key.enc`, `cer.enc`, `profile.enc`)
2. Builds a SHA1-MAC PKCS12 (macOS-`security`-compatible) + imports to a
   dedicated keychain in the search list
3. Downloads the iOS 26 platform, selects Xcode 26
4. `flutter build ios --config-only` (compiles Dart, skips flaky signing check)
5. `xcodebuild -resolvePackageDependencies` (links SPM plugins)
6. `xcodebuild archive -sdk iphoneos` (builds unsigned xcarchive)
7. `xcodebuild -exportArchive` (signs with keychain → signed IPA)
8. Uploads the IPA as a GitHub artifact (always, even if TestFlight fails)
9. Uploads to TestFlight via `xcrun altool` (App Store Connect API key)

**Bundle ID:** `com.jasperdeen.goalisle` · **Team:** `3X37886R5C`
**Profile:** "GoalIsle Distribution" (App Store Connect type)
**Cert:** "Apple Distribution: JASPER HOLIMAN DEEN (3X37886R5C)"

### 3. Supabase Backend — Auth + Postgres + RLS
- **Auth:** email/password (real Supabase sessions, no mock IDs leak through)
- **Tables:** `isles`, `memberships`, `sparks`, `messages`, `posts`, `friends`,
  `profiles` — all with row-level security policies enabled
- **Metric logs:** stored as messages with `chat_id = 'thread-<spark_id>'`
  (reuses the messages table — no separate table needed)
- **Client:** `lib/core/repositories/supabase/supabase_client.dart`
  (URL: `https://mjnitlwhpqylivplkkxu.supabase.co`)
- **Hybrid providers:** optimistic local state + fire-and-forget Supabase
  writes (`lib/core/repositories/mock/mock_providers.dart`)
- **Schema:** `supabase_schema.sql` + `supabase_rls_fix.sql`

### 4. Local Git Repo
- Remote: `git@github.com:JDeez0/goal-isle.git`
- Branch: `main`
- Latest commit: `5f19908` (pushed)

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry, Supabase init, router
├── core/
│   ├── models/                  # Plain Dart (no freezed) — Isle, Spark,
│   │                            #   Post, Membership, Message, Friend...
│   ├── repositories/
│   │   ├── mock/mock_providers.dart      # Riverpod providers + Supabase
│   │   └── supabase/                     # supabase_client + repository
│   ├── theme/                   # Design tokens (parallelogram spark shape)
│   └── widgets/                 # Reusable widgets
└── features/
    ├── auth/                    # Sign in / sign up
    ├── isles/                   # Home, create isle, isle home, settings
    ├── sparks/                  # New spark, spark details, metric log,
    │                            #   spark thread, spark settings
    ├── chat/                    # Isle chat with recipe dropdown card
    ├── posts/                   # Post composer (image/text/emoji)
    ├── discover/                # Find public isles
    ├── friends/                 # Friend list
    ├── league/                  # League/leaderboard
    ├── notes/                   # Personal notes
    └── profile/                 # Profile, edit profile, app settings
```

**Key conventions:**
- **No codegen.** Dart 3.12's analyzer breaks `freezed`/`json_serializable`,
  so all models are hand-written `fromJson`/`toJson`/`copyWith`.
- **No real-time yet.** Reads are pull-based; writes are fire-and-forget.
- **Sign-out resets all providers** (prevents data leak between users).

---

## 🔑 Code Signing Materials (committed, encrypted)

These live in the repo root, AES-256-CBC encrypted with password "goalisle"
(stored as GitHub secret `CERT_PASSWORD`):

| File | Contains |
|---|---|
| `key.enc` | Raw RSA private key (distribution cert) |
| `cer.enc` | `distribution.cer` (DER) |
| `profile.enc` | `GoalIsle_Distribution.mobileprovision` |

The P12 is **rebuilt on the macOS runner** (not committed) because
macOS-`security` requires SHA1 MAC PKCS12, which OpenSSL 3.6.2 doesn't
produce by default.

**Sensitive files (gitignored):** `*.p8`, `*.cer`, `*.p12`, `*.key`,
`*.mobileprovision`, `*.csr`, `*.pem`. The App Store Connect API key
(`AuthKey_8N59492275.p8`) is gitignored and stored as GitHub secret
`APP_STORE_CONNECT_PRIVATE_KEY`.

---

## 📚 Documentation

| Doc | Purpose |
|---|---|
| `README.md` | Project root, entry point |
| `CURRENT_STATUS.md` | **This file** — current state, source of truth |
| **`docs/design/ISLE_SPARKS_SPEC_v2.md`** | **🔒 THE governing spec** |
| `docs/HISTORY.md` | Project timeline + key decisions |
| `docs/AUDIT_2026_07_01.md` | Vestigial-information audit |
| `SUPABASE_STATUS.md` | Supabase schema + RLS details |
| `.github/workflows/ios-build.yml` | iOS build + TestFlight pipeline |

---

## 📝 iOS Build — Lessons Learned

The iOS pipeline took ~20 commits to get fully working. Each failure taught
something worth recording:

1. **Cert name:** Apple renamed "iPhone Distribution" → "Apple Distribution"
   years ago. Hardcode the new name, not the old one.
2. **pbxproj targets:** Signing settings must go in the **Runner app target**
   configs (Debug/Release/Profile), not just RunnerTests. Flutter's default
   template has no signing settings on the Runner target.
3. **Dedicated keychain + search list:** Don't use `login.keychain` on CI —
   create a dedicated keychain AND add it to the search list with
   `security list-keychains -d user -s`. Re-establish the list in the build
   step (it can reset between steps on macOS 26).
4. **PKCS12 MAC:** OpenSSL 3.x defaults to SHA256 MAC; macOS `security` needs
   SHA1. Use `-certpbe PBE-SHA1-3DES -keypbe PBE-SHA1-3DES -macalg sha1`.
5. **iOS 26 SDK (April 2026 requirement):** Use `macos-26` runner (Xcode 26).
   Run `xcodebuild -downloadPlatform iOS` — the SDK ships with Xcode but the
   platform package must be downloaded separately. This also fixes ibtool
   ("iOS 26.0 Platform Not Installed") which previously blocked storyboard
   compilation.
6. **NEVER remove Main.storyboard:** `FlutterSceneDelegate` (Flutter 3.38+)
   REQUIRES `UISceneStoryboardFile=Main` in the scene config to instantiate
   `FlutterViewController`. Removing it causes a permanent black screen on
   physical devices ([flutter/flutter#186572](https://github.com/flutter/flutter/issues/186572)).
   The app uses `SceneDelegate.swift` (FlutterSceneDelegate) + the standard
   `Main.storyboard` with a single `FlutterViewController` scene.
7. **Flutter signing pre-validation is flaky:** `flutter build ipa` does its
   own signing check that fails ~50% of the time on macos-26 (false negative
   — cert IS in keychain but Flutter's destination resolution breaks). The fix:
   two-phase build: `flutter build ios --config-only` + `xcodebuild archive
   -sdk iphoneos CODE_SIGNING_ALLOWED=NO` + `xcodebuild -exportArchive`.
8. **Swift Package Manager, not CocoaPods:** This project uses
   `FlutterGeneratedPluginSwiftPackage` (SPM), not CocoaPods. Do NOT add a
   Podfile. Use `xcodebuild -resolvePackageDependencies` to link plugins.
   Note: `supabase_flutter` is pure Dart (no native plugin) — the 4 native
   plugins are `app_links`, `image_picker_ios`, `shared_preferences_foundation`,
   `url_launcher_ios`.
9. **Deployment target:** Must be iOS 14+ for the scene-based launch
   (`FlutterSceneDelegate`). Set to 15.0 for broad compatibility.
10. **iPad multitasking:** Apple rejects builds without a launch storyboard
    if `UIRequiresFullScreen` isn't set. Add `UIRequiresFullScreen=true` to
    Info.plist (Goal Isle is phone-first).
11. **Encryption compliance:** Add `ITSAppUsesNonExemptEncryption=false` to
    Info.plist to permanently bypass the export compliance question.
12. **Build numbers:** Apple rejects uploads with duplicate build numbers.
    Use `GITHUB_RUN_NUMBER` as the build number (`--build-number=$GITHUB_RUN_NUMBER`).
13. **altool validation:** `altool --validate-app` can print errors but return
    exit 0. Capture output and grep for `VERIFY FAILED` / `UPLOAD FAILED` /
    `Validation failed` to detect real failures.

### Final working pipeline

```
┌─ Increment build number (GITHUB_RUN_NUMBER)
├─ Set up Xcode 26 + downloadPlatform iOS
├─ Set up code signing (decrypt → SHA1 P12 → keychain → search list)
├─ flutter build ios --config-only --build-number=$BUILD_NUMBER
├─ xcodebuild -resolvePackageDependencies (SPM plugins)
├─ xcodebuild archive -sdk iphoneos CODE_SIGNING_ALLOWED=NO
├─ xcodebuild -exportArchive (signs with keychain + exportOptions.plist)
├─ Upload IPA artifact (always — fallback if TestFlight fails)
└─ Upload to TestFlight (altool validate + upload)
```

---

## 🚀 What to Do Next

### ✅ Milestone achieved — app renders on TestFlight (black screen fixed)

### Bugs fixed (all done ✅)
- ✅ RLS re-enabled on `isles` + `memberships` (policies were correct all along)
- ✅ Friends table: unique constraint, bidirectional delete, accept updates original
- ✅ Metric-log thread persistence (reuses messages table via `chat_id='thread-<spark_id>'`)
- ✅ **Black screen on TestFlight** (restored Main.storyboard for FlutterSceneDelegate)
- ✅ Mock UUID leak (real auth UUIDs flow through all write paths)
- ✅ Sign-out data leak (all providers reset before signOut)
- ✅ Code audit: 27 critical/high issues fixed (router, stream leak, null safety, error handling)

### Infrastructure built (all done ✅)
- ✅ Pre-push hook (`flutter analyze` gate + protected files warning)
- ✅ `goal` helper command (check, web, branch, ship, ci)
- ✅ Flutter on PATH permanently
- ✅ CI: PR builds (validate only), manual dispatch (any branch), TestFlight only on main push
- ✅ DEVELOPMENT_WORKFLOW.md + DEVELOPMENT_GUIDE.md + PROJECT_KNOWLEDGE.md + UX_UI_ITERATION_PLAN.md

### Immediate — polish for beta
1. **Run through full TestFlight test:** sign up, create isle, create spark, send
   chat, log metric, close+reopen (data persists?). Verify auth, isle creation,
   spark creation, chat, and posts work end-to-end.
2. **App icon:** the current icon is the default Flutter template. Design a
   Goal Isle icon (add to `ios/Runner/Assets.xcassets/AppIcon.appiconset`).
3. **Privacy manifest:** Add `PrivacyInfo.xcprivacy` before App Store review.
4. **App Store Connect metadata:** description, keywords, screenshots,
   support URL, privacy policy URL — needed for external testing/review.

### Short term
5. **Real-time chat subscription:** chat requires pull-to-refresh; add a
   Supabase real-time subscription so messages appear live.
6. **Invite beta testers** via TestFlight External Testing.

### Long term
7. **Push notifications** (spark reminders, chat, friend activity).
8. **Offline queue** for writes when offline (currently fire-and-forget fails
   silently if offline).
9. **Moderation** (report + creator-removes) for public Isles.
10. **Cross-platform:** Android build via GitHub Actions (same pattern as iOS).

---

*Source of truth. Update this file whenever project state changes.*

---

*Source of truth. Update this file whenever project state changes.*
