# Goal Isle — Project Knowledge Base

**Single source of truth. Everything you need to know about this project.**

**Last updated:** July 10, 2026
**Project root:** `/home/jasper/projects/goal_isle/`
**Repository:** `git@github.com:JDeez0/goal-isle.git` (branch: `main`)

---

## 1. What Goal Isle Is

A calm ritual/social app for small communities. Users create "Isles" (communities),
add "Sparks" (recurring commitments) with emoji dependencies, light them by typing
the right emojis in chat, and stay accountable with streaks.

**Target wedge:** College grads studying for the LSAT (v2 spec).

**Visual signature:** Sparks float as soft-aura parallelograms on quiet water.
Lit sparks rise; greyed sparks sink. No square/rounded-square outlines on emojis ever.

---

## 2. Technology Stack

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
| Framework | Flutter | 3.44.2 (stable) | At `/home/jasper/flutter/bin/` |
| Language | Dart | 3.12.2 | No codegen (freezed/json_serializable broken by analyzer 7.x) |
| State | Riverpod | 2.6.1 | Manual `StateNotifier` — no `Notifier` migration yet |
| Routing | GoRouter | 14.8.1 | `StatefulShellRoute.indexedStack` with 3 branches |
| Backend | Supabase | 2.16.0 | Auth + Postgres + RLS |
| iOS build | GitHub Actions | macos-26 runner | Xcode 26 / iOS 26 SDK |
| Package mgr | Swift Package Manager | — | NOT CocoaPods (no Podfile) |
| Signing | Apple Distribution cert | Team: `3X37886R5C` | Bundle: `com.jasperdeen.goalisle` |

---

## 3. Architecture

### 3.1 Directory Structure

```
lib/
├── main.dart                          # Entry: Supabase init → runApp
├── app/
│   ├── app.dart                       # MaterialApp.router wrapper
│   ├── router.dart                    # GoRouter (redirect, routes, auth listenable)
│   ├── bottom_nav.dart                # Bottom nav bar widget
│   └── widgets/
│       └── placeholder_screen.dart    # Dead code (no routes reference it)
├── core/
│   ├── models/                        # Plain Dart (no freezed)
│   │   ├── enums.dart                 # IsleVisibility, SparkMode, SparkScope, SparkState, TimerMode, MetricTemplate
│   │   ├── user.dart                  # User (id, name, handle, avatar, bio)
│   │   ├── isle.dart                  # Isle (id, name, emoji, purpose, color, visibility, createdBy, sparks)
│   │   ├── spark.dart                 # Spark (id, isleId, emoji, title, mode, scope, shape, state, streak, timerMode, metric, dependencies, thread)
│   │   ├── dependency.dart            # Dependency (id, sparkId, emoji, label, satisfied)
│   │   ├── message.dart               # Message (id, chatId, senderId, content, big, contentType, reactions, imageUrl)
│   │   ├── post.dart                  # Post (id, authorId, text, emoji, imageUrl, audience)
│   │   ├── membership.dart            # Membership (isleId, userId, userName, role)
│   │   ├── friend.dart                # Friend (id, friendId, friendName, status)
│   │   ├── metric.dart                # Metric (template, target, unit, currentValue, previousValue, trend)
│   │   └── spark_shape.dart           # SparkShape (tl, tr, br, bl — parallelogram corners)
│   ├── repositories/
│   │   ├── supabase/
│   │   │   ├── supabase_client.dart   # SupabaseConfig (URL + anon key + initialize)
│   │   │   ├── supabase_repository.dart # All DB queries (fetchIsles, createIsle, sendMessage, etc.)
│   │   │   └── supabase_auth.dart     # Dead code — unused auth provider (use mock_providers instead)
│   │   └── mock/
│   │       ├── mock_providers.dart    # All Riverpod providers + notifiers + Supabase write-through
│   │       └── mock_data.dart         # Seed data (mock users, isles, sparks, friends)
│   ├── theme/
│   │   ├── app_theme.dart             # createAppTheme() — light theme only
│   │   └── tokens.dart                # TokenColors (accent, text, border, etc.) — mostly unused
│   └── widgets/
│       └── (shared widgets go here)
└── features/
    ├── auth/
    │   └── presentation/auth_screen.dart
    ├── isles/
    │   └── presentation/
    │       ├── home_screen.dart        # Floating sparks on water (seeded RNG layout)
    │       ├── isles_index_screen.dart # List of all isles
    │       ├── create_isle_screen.dart
    │       ├── isle_home_screen.dart   # Isle detail (sparks, members, keys)
    │       └── isle_settings_screen.dart
    ├── sparks/
    │   └── presentation/
    │       ├── new_spark_screen.dart   # Create spark (emoji picker, deps, kind)
    │       ├── spark_details_screen.dart
    │       ├── spark_settings_screen.dart
    │       ├── spark_thread_screen.dart # Chat log for a spark
    │       └── metric_log_sheet.dart   # Log a value for metric sparks
    ├── chat/
    │   └── presentation/isle_chat_screen.dart
    ├── posts/
    │   └── presentation/post_composer_screen.dart
    ├── discover/
    │   └── presentation/discover_screen.dart
    ├── friends/
    │   └── presentation/friends_screen.dart
    ├── league/
    │   └── presentation/league_screen.dart
    ├── notes/
    │   └── presentation/notes_screen.dart
    └── profile/
        └── presentation/
            ├── profile_screen.dart
            ├── edit_profile_sheet.dart
            └── app_settings_screen.dart
```

### 3.2 State Management Pattern

**Hybrid optimistic-local + fire-and-forget Supabase writes:**

```dart
// Pattern (used in every notifier):
void updateIsle(Isle isle) {
  // 1. Update local state IMMEDIATELY (optimistic)
  state = [for (final i in state) if (i.id == isle.id) isle else i];
  // 2. Fire Supabase write (fire-and-forget)
  SupabaseRepository.updateIsle(isle)
      .then((_) {}).catchError((e, s) { debugPrint("..."); });
}
```

**Providers:**
- `currentUserProvider` → `UserNotifier` — current user (syncs from Supabase auth)
- `islesProvider` → `IslesNotifier` — list of all isles with full data
- `membershipsProvider` → `MemberhipsNotifier` — Map<isleId, List<Membership>>
- `friendsProvider` → `FriendsNotifier` — list of friends
- `activeIsleIdProvider` / `activeSparkIdProvider` — navigation state (UI-only)

**Key helpers:**
- `currentAuthId()` — returns `Supabase.instance.client.auth.currentUser?.id` (real UUID)
- `SupabaseConfig.client` — the Supabase client instance

### 3.3 Router Structure

```
/                          → HomeScreen (bottom nav, tab 1)
/notes                     → NotesScreen (tab 0)
/league                    → LeagueScreen (tab 2)
/auth                      → AuthScreen (no bottom nav, pre-login gate)
/isles                     → IslesIndexScreen (drill-in)
/isle                      → IsleHomeScreen (drill-in)
/spark                     → SparkDetailsScreen (drill-in)
/sparkthread               → SparkThreadScreen (drill-in)
/sparksettings             → SparkSettingsScreen (drill-in)
/chat                      → IsleChatScreen (drill-in)
/create                    → NewSparkScreen (drill-in)
/create-isle               → CreateIsleScreen (drill-in)
/post                      → PostComposerScreen (drill-in)
/discover                  → DiscoverScreen (drill-in)
/isle-settings             → IsleSettingsScreen (drill-in)
/friends                   → FriendsScreen (drill-in)
/profile                   → ProfileScreen (drill-in)
/appsettings               → AppSettingsScreen (drill-in)
```

**Auth redirect:** `!signedIn && !goingToAuth` → `/auth`. `signedIn && goingToAuth` → `/` (with data reload).

### 3.4 Database Schema

8 tables in Supabase, all with RLS enabled:

| Table | Purpose | Key RLS rule |
|-------|---------|-------------|
| `profiles` | User profiles (extends auth.users) | Read all, update own |
| `isles` | Communities | Read if public or member, write by creator |
| `memberships` | User ↔ Isle join table | Read if member, insert by creator or self |
| `sparks` | Recurring commitments | Read if member, write by isle creator |
| `dependencies` | Emoji ingredients for sparks | Same as sparks (through parent) |
| `messages` | Chat + thread messages | Read if sender or member of isle/thread |
| `posts` | Broadcasts to isles | Read if authored or in audience |
| `friends` | Friend relationships | Read both directions, write by owner |

**Critical RLS helper:** `is_isle_creator(isle_id)` — SECURITY DEFINER function that bypasses `isles_read` RLS. This solves the chicken-and-egg problem where the creator isn't yet a member when creating an isle. **Never replace this with inline subqueries.**

---

## 4. iOS Build Pipeline

### 4.1 Final Working Pipeline

```
┌─ Increment build number (GITHUB_RUN_NUMBER)
├─ Set up Xcode 26 + downloadPlatform iOS
├─ Set up code signing:
│   ├─ Decrypt key.enc + cer.enc + profile.enc (AES-256-CBC, password "goalisle")
│   ├─ Build SHA1-MAC P12 (OpenSSL 3.6.2 needs -macalg sha1 + 3DES)
│   ├─ Create dedicated keychain + add to search list
│   └─ Import cert + set partition list
├─ flutter build ios --config-only --no-codesign --build-number=$BUILD_NUMBER
├─ xcodebuild -resolvePackageDependencies (SPM plugins)
├─ xcodebuild archive -sdk iphoneos CODE_SIGNING_ALLOWED=NO
├─ xcodebuild -exportArchive (signs with keychain + exportOptions.plist)
├─ Upload IPA artifact (always — even if TestFlight fails)
└─ Upload to TestFlight (only on push to main, not PRs)
```

### 4.2 Signing Materials

| File | Purpose | Storage |
|------|---------|---------|
| `key.enc` | RSA private key (encrypted) | Committed to git |
| `cer.enc` | Distribution certificate (encrypted) | Committed to git |
| `profile.enc` | Provisioning profile (encrypted) | Committed to git |
| `CERT_PASSWORD` | Decryption password ("goalisle") | GitHub secret |
| `APP_STORE_CONNECT_*` | API key for TestFlight upload | GitHub secrets |

### 4.3 Known CI Flakiness

**macos-26 runner intermittent issue** (~25% of runs):
```
xcodebuild: error: Found no destinations for the scheme 'Runner' and action archive.
```
**Fix:** Retry. Push an empty commit. The next run almost always succeeds. This is a GitHub runner issue, not a code issue.

### 4.4 Protected Files (DO NOT TOUCH in feature branches)

| File | Why |
|------|-----|
| `ios/Runner.xcodeproj/project.pbxproj` | Signing, team ID, bundle ID |
| `ios/Runner/Info.plist` | Scene manifest, storyboard refs, permissions |
| `ios/Runner/Base.lproj/*.storyboard` | FlutterSceneDelegate needs these |
| `.github/workflows/ios-build.yml` | CI pipeline |
| `cer.enc` / `key.enc` / `profile.enc` | Signing materials |

---

## 5. Bugs Fixed (Complete History)

| # | Bug | Root Cause | Fix | Commit |
|---|-----|-----------|-----|--------|
| 1 | Mock UUID leak | `currentUserProvider` kept mock ID `u-jasper` | `_syncFromAuth()` sets real UUID; `currentAuthId()` helper | — |
| 2 | addMember duplicate | `createIsle` already inserts membership | Removed redundant call | — |
| 3 | Sign-out data leak | Providers kept previous user's data | `reset()` on all providers before signOut | — |
| 4 | "No valid code signing certificates" | Cert named "Apple Distribution", workflow said "iPhone Distribution" | Use correct name everywhere | — |
| 5 | pbxproj patch hit wrong target | `CODE_SIGN_STYLE = Automatic` only in RunnerTests | Commit signing settings to Runner target | — |
| 6 | Keychain flakiness | `login.keychain` password unreliable | Dedicated `build.keychain-db` | — |
| 7 | iOS 26 SDK required | macos-15 had Xcode 16.4 | Switch to `macos-26` + `downloadPlatform iOS` | — |
| 8 | PKCS12 MAC failure | OpenSSL 3.6.2 uses SHA256; macOS security needs SHA1 | `-macalg sha1` + `-certpbe/-keypbe PBE-SHA1-3DES` | — |
| 9 | Keychain search list | codesign searches list, not default | `security list-keychains -d user -s` | — |
| 10 | Flutter signing pre-check flaky | `flutter build ipa` false negative on macos-26 | Two-phase: `--config-only` + `xcodebuild archive` | — |
| 11 | iPad multitasking rejection | `UILaunchScreen` empty dict not enough | `UIRequiresFullScreen=true` | — |
| 12 | Encryption compliance | Every upload asked the question | `ITSAppUsesNonExemptEncryption=false` | — |
| 13 | Duplicate build numbers | Apple rejects same version | `GITHUB_RUN_NUMBER` as build number | — |
| 14 | altool silent failures | altool returns 0 even on validation error | Grep for `VERIFY FAILED` / `UPLOAD FAILED` | — |
| 15 | **Black screen on TestFlight** | Removed `Main.storyboard` → FlutterSceneDelegate had no FlutterViewController | Restored storyboards | `1ce74e3` |
| 16 | **No Podfile** | This project uses SPM, not CocoaPods | `xcodebuild -resolvePackageDependencies` | `d5c1198` |
| 17 | **Deployment target 13.0** | Scene-based launch needs iOS 14+ | Raised to 15.0 | `98cdc57` |
| 18 | **Friends duplicates** | No unique constraint | `UNIQUE(user_id, friend_id)` + upsert | `605a4e3` |
| 19 | **Friends accept doesn't propagate** | Inserted second row instead of updating | UPDATE original row | `605a4e3` |
| 20 | **Friends can't decline** | RLS blocked deleting incoming rows | Bidirectional delete + RLS update | `605a4e3` |
| 21 | **Metric logs not persistent** | No table, no persistence, thread wiped to [] | Reuse messages table via `chat_id='thread-<spark_id>'` | `da39570` |
| 22 | **Router redirect fires loads every time** | Side effects in redirect | Load data once per session | `fbc4fa5` |
| 23 | **Auth stream leak** | `StreamSubscription` never cancelled | `dispose()` cancels subscription | `fbc4fa5` |
| 24 | **DepDraft controller leak** | `labelCtrl` never disposed | Dispose in `dispose()` and `_reset()` | `fbc4fa5` |
| 25 | **_uid! null crash risk** | Force-unwrapped nullable `_uid` | Null-guard with early return | `fbc4fa5` |
| 26 | **TimerMode default mismatch** | `instant` in one path, `daily` in another | Unified to `daily` | `fbc4fa5` |
| 27 | **Silent catch blocks** | `catch (_) {}` swallowing errors | `debugPrint` on all catch blocks | `fbc4fa5` |
| 28 | **Chat reactions use mock ID** | `currentUserProvider.id` instead of `currentAuthId()` | Use `currentAuthId()` | `fbc4fa5` |
| 29 | **Stale local files** | 6 P12 variants, cert.pem, key.pem, decoy exportOptions | Removed all stale files | `fbc4fa5` |
| 30 | **Abandoned codemagic.yaml** | Two CI configs, conflicting signing | Removed, GitHub Actions only | `fbc4fa5` |

---

## 6. Development Infrastructure

### 6.1 Pre-push Hook

Runs on every `git push`:
```bash
✓ flutter analyze (0 errors required — aborts push if any found)
✓ Protected files check (warns if project.pbxproj, Info.plist, storyboards, etc. changed)
✓ Dependency changes warning (reminds about SPM compatibility)
```

Install: `bash scripts/install-hooks.sh`
Skip: `git push --no-verify`

### 6.2 CI Triggers

| Trigger | Builds? | Uploads to TestFlight? |
|---------|---------|----------------------|
| Push to `main` | ✅ | ✅ |
| PR to `main` | ✅ (validates build) | ❌ |
| Manual dispatch (any branch) | ✅ (tests branch) | ❌ |

### 6.3 Documentation Map

| Doc | What it's for |
|-----|--------------|
| `README.md` | Entry point, quick start |
| **`CURRENT_STATUS.md`** | **Source of truth — current state, next steps** |
| **`DEVELOPMENT_WORKFLOW.md`** | **Full iterative workflow: branching, testing, emergencies** |
| `DEVELOPMENT_GUIDE.md` | Quick reference: safe/dangerous files, dependency rules |
| `docs/design/ISLE_SPARKS_SPEC_v2.md` | The governing spec |
| `docs/HISTORY.md` | Project timeline |
| `SUPABASE_STATUS.md` | Schema + RLS details |
| `supabase_schema.sql` | Full database schema |
| `supabase_enable_rls.sql` | Re-enable RLS on isles + memberships |
| `supabase_friends_fix.sql` | Friends table unique constraint + RLS update |
| `supabase_metric_logs_fix.sql` | Messages RLS for thread reads |

---

## 7. Known Limitations & Future Work

### 7.1 Architecture limitations

| Limitation | Impact | Mitigation |
|-----------|--------|-----------|
| No real-time chat | Messages require pull-to-refresh | Supabase realtime subscription exists but is unused |
| No codegen | Models are hand-written (verbose) | Dart 3.12 analyzer breaks freezed; wait for Flutter upgrade |
| StateNotifier (not Notifier) | Deprecated in Riverpod 3.x | Migration would be a major refactor with no user benefit |
| Optimistic writes with no rollback | UI shows changes that may fail silently | Acceptable for now; add retry/toast feedback in future |
| N+1 queries in fetchIsles | Slow for users with many isles | Add parallel `Future.wait` or a Supabase Edge Function |
| `isleColor` duplicated 9 times | Adding a new color requires 9 edits | Extract to `TokenColors.isle()` helper |
| Theme tokens unused | Hardcoded hex colors everywhere | Use `TokenColors` consistently |

### 7.2 Missing features

| Feature | Priority | Effort |
|---------|----------|--------|
| App icon | High | Low (design + asset replacement) |
| PrivacyInfo.xcprivacy | High (App Store) | Low (XML file) |
| App Store Connect metadata | High (external testing) | Low (text + screenshots) |
| Real-time chat | Medium | Medium (wire up existing subscription) |
| Push notifications | Medium | High (APNs + Supabase Edge Functions) |
| Offline queue | Low | High (local storage + sync) |
| Dark mode | Low | Low (theme toggle is already in UI, just needs implementation) |
| Android build | Low | Medium (same pipeline pattern as iOS) |

---

*This is the single source of truth. Update it whenever project state changes.*