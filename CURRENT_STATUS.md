# Goal Isle — Current Status

**Last updated:** July 9, 2026
**Project:** `/home/jasper/projects/goal_isle/`
**Repo:** `git@github.com:JDeez0/goal-isle.git` (branch: `main`)

---

## ✅ What Works Right Now

### 1. Flutter App — v2, fully ported (20 screens)
A complete rewrite of the v2 spec: 44 Dart files, 20 screens, all wired
to Supabase. Riverpod state management (manual StateNotifier — no codegen).
GoRouter with StatefulShellRoute (3 bottom-nav branches: Home / Notes / League).

- **Run it (web):** `flutter run -d chrome`
- **Run it (iOS):** install via **TestFlight** (see below)
- **Build:** `flutter build web --no-tree-shake-icons` ✅
- **iOS build:** signed IPA + TestFlight upload via GitHub Actions ✅

### 2. iOS on TestFlight 🎉
Every push to `main` triggers `.github/workflows/ios-build.yml` on a
`macos-26` runner (Xcode 26 / iOS 26 SDK, required by Apple since April 2026).
The workflow:
1. Decrypts committed signing materials (`key.enc`, `cer.enc`, `profile.enc`)
2. Builds a SHA1-MAC PKCS12 (macOS-`security`-compatible) + imports to a
   dedicated keychain in the search list
3. Downloads the iOS 26 platform, selects Xcode 26
4. `flutter build ipa --release` → signed IPA
5. Uploads the IPA as a GitHub artifact (always, even if TestFlight fails)
6. Uploads to TestFlight via `xcrun altool` (App Store Connect API key)

**Bundle ID:** `com.jasperdeen.goalisle` · **Team:** `3X37886R5C`
**Profile:** "GoalIsle Distribution" (App Store Connect type)
**Cert:** "Apple Distribution: JASPER HOLIMAN DEEN (3X37886R5C)"

### 3. Supabase Backend — Auth + Postgres + RLS
- **Auth:** email/password (real Supabase sessions, no mock IDs leak through)
- **Tables:** `isles`, `memberships`, `sparks`, `messages`, `posts`, `friends`,
  `metric_logs`, `profiles` — with row-level security policies
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
   platform package must be downloaded separately.
6. **No storyboards:** Removed `Main.storyboard` + `LaunchScreen.storyboard`
   entirely. The app uses `SceneDelegate.swift` (FlutterSceneDelegate) for a
   programmatic launch, avoiding ibtool platform issues. `UILaunchScreen`
   (empty dict) replaces the launch storyboard in Info.plist.
7. **Flutter signing pre-validation is flaky:** `flutter build ipa` does its
   own signing check that fails ~50% of the time on macos-26 (false negative
   — cert IS in keychain but Flutter's destination resolution breaks). The fix:
   two-phase build: `flutter build ios --config-only` + `xcodebuild archive
   -sdk iphoneos CODE_SIGNING_ALLOWED=NO` + `xcodebuild -exportArchive`.
8. **iPad multitasking:** Apple rejects builds without a launch storyboard
   if `UIRequiresFullScreen` isn't set. Add `UIRequiresFullScreen=true` to
   Info.plist (Goal Isle is phone-first).
9. **Encryption compliance:** Add `ITSAppUsesNonExemptEncryption=false` to
   Info.plist to permanently bypass the export compliance question.
10. **Build numbers:** Apple rejects uploads with duplicate build numbers.
    Use `GITHUB_RUN_NUMBER` as the build number (`--build-number=$GITHUB_RUN_NUMBER`).
11. **altool validation:** `altool --validate-app` can print errors but return
    exit 0. Capture output and grep for `VERIFY FAILED` / `UPLOAD FAILED` /
    `Validation failed` to detect real failures.

### Final working pipeline

```
┌─ Increment build number (GITHUB_RUN_NUMBER)
├─ Set up Xcode 26 + downloadPlatform iOS
├─ Set up code signing (decrypt → SHA1 P12 → keychain → search list)
├─ flutter build ios --config-only --build-number=$BUILD_NUMBER
├─ xcodebuild archive -sdk iphoneos CODE_SIGNING_ALLOWED=NO
├─ xcodebuild -exportArchive (signs with keychain)
├─ Upload IPA artifact (always)
└─ Upload to TestFlight (altool validate + upload)
```

---

## 🚀 What to Do Next

### Immediate — harden + ship a usable beta
1. **Re-enable RLS on `isles` + `memberships`.** RLS is currently disabled on
   those two tables. Run `supabase_enable_rls.sql` in the Supabase SQL Editor.
   (The original policies in `supabase_schema.sql` are correct — the persistence
   bug was caused by mock UUIDs leaking, which is now fixed in Flutter.)
2. **Test the TestFlight build on a real device.** Verify auth, isle creation,
   spark creation, chat, and posts work end-to-end.
3. **Add test notes + screenshots** to the TestFlight build for internal testers.

### Short term — fix known bugs
4. **Metric-log thread persistence (Bug #5):** metric logs don't persist to
   Supabase yet (local-only).
5. **Friends table unique constraint (Bugs #8, #9, #10):** add
   `UNIQUE(user_id, friend_id)` to prevent duplicate friend rows.
6. **Real-time chat subscription:** chat requires pull-to-refresh; add a
   Supabase real-time subscription so messages appear live.

### Medium term — polish + release
7. **App icon:** the current icon is the default Flutter template. Design a
   Goal Isle icon.
8. **Privacy manifest:** Apple may require `PrivacyInfo.xcprivacy` for
   App Store review. Add it before submitting for review.
9. **App Store Connect metadata:** description, keywords, screenshots,
   support URL, privacy policy URL — all needed for external testing/review.

### Long term
11. **Push notifications** (spark reminders, chat, friend activity).
12. **Offline queue** for writes when offline (currently fire-and-forget fails
    silently if offline).
13. **Moderation** (report + creator-removes) for public Isles.
14. **Cross-platform:** Android build via GitHub Actions (same pattern as iOS).

---

*Source of truth. Update this file whenever project state changes.*
