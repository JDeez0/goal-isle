# Quick Start Guide for Goal Isle Project

## How to Resume Work in 30 Seconds

### Step 1: Copy-Paste This to Any New AI Chat

```
I'm working on a Flutter web project at /home/jasper/projects/goal_isle/ called Goal Isle.

The app shows a blank white screen with "Null check operator used on a null value" error
during Flutter bootstrap. I've already disabled all Supabase references and created mock data.
The build succeeds but the app crashes during initialization.

There's a debugging summary at: /home/jasper/projects/goal_isle/DEBUGGING_SUMMARY.md

Can you help me continue debugging?
```

### Step 2: Show the Error

If the AI asks for more details, share the browser console error:
```
[PASTE THE ERROR FROM BROWSER CONSOLE HERE]
```

---

## Essential Commands (Keep These Handy)

### Check Project Status
```bash
cd /home/jasper/projects/goal_isle
cat DEBUGGING_SUMMARY.md  # Read full summary
```

### Rebuild the App
```bash
cd /home/jasper/projects/goal_isle
flutter build web --no-tree-shake-icons
```

### Start the Server
```bash
cd /home/jasper/projects/goal_isle/build/web
python3 -m http.server 8083
```

### Kill Old Servers
```bash
pkill -9 -f "python3.*http.server"
```

### Verify Supabase is Disabled
```bash
cd /home/jasper/projects/goal_isle
grep -rn "Supabase.instance" lib/ --include="*.dart" | grep -v "DISABLED\|//"
# Should return nothing
```

---

## Where Everything Is

| What | Location |
|------|----------|
| Project folder | `/home/jasper/projects/goal_isle/` |
| Debugging summary | `/home/jasper/projects/goal_isle/DEBUGGING_SUMMARY.md` |
| Flutter binary | `/home/jasper/flutter/bin/flutter` |
| Build output | `/home/jasper/projects/goal_isle/build/web/` |
| Main code | `/home/jasper/projects/goal_isle/lib/main.dart` |
| All providers | `/home/jasper/projects/goal_isle/lib/providers/` |

---

## Current State (At a Glance)

✅ **Working:**
- Project builds successfully
- All files saved on disk
- Mock data implemented
- Supabase completely disabled

❌ **Broken:**
- Blank white screen in browser
- Null check error during bootstrap
- App doesn't render anything

📍 **Server:** Port 8083 (if running)

---

## What to Tell the Next AI Agent

### Option A: Quick Version
```
Goal Isle Flutter web app at /home/jasper/projects/goal_isle/ shows blank screen with
null check error. I've disabled Supabase and added mocks. Build succeeds but crashes
during initialization. Help debug?
```

### Option B: Detailed Version
```
I'm debugging a Flutter web app called Goal Isle at /home/jasper/projects/goal_isle/.

PROBLEM: Blank white screen with "Null check operator used on a null value" error
during Flutter bootstrap initialization.

WHAT I'VE DONE:
- Disabled all Supabase references
- Created mock data for all providers
- Fixed model field issues
- Build succeeds: `flutter build web --no-tree-shake-icons`
- Server runs: `python3 -m http.server 8083`

STATUS: Code compiles but crashes at runtime during app loading

DOCUMENTATION: Full details in /home/jasper/projects/goal_isle/DEBUGGING_SUMMARY.md

Can you help identify what's causing the null check error during Flutter bootstrap?
```

---

## Key Files the AI Should Know About

1. **DEBUGGING_SUMMARY.md** - Complete debugging history
2. **lib/main.dart** - App entry point
3. **lib/providers/auth_provider.dart** - Had auto-init issue (now disabled)
4. **lib/providers/isle_provider.dart** - Mock data implementation
5. **web/index.html** - Flutter web bootstrap configuration

---

## Important Context Points

### Don't Let the AI Waste Time On:
- ❌ Re-enabling Supabase (already disabled)
- ❌ Checking for Supabase references (already verified none exist)
- ❌ Basic Flutter installation checks (already working)

### Do Let The AI Focus On:
- ✅ Null check operator locations
- ✅ Flutter bootstrap initialization
- ✅ Provider initialization timing
- ✅ Async initialization issues
- ✅ Web-specific Flutter configuration

---

## Troubleshooting the "Lost Progress" Fear

### Your Progress IS Safe Because:
1. All code changes are saved in files on disk
2. The project folder exists at `/home/jasper/projects/goal_isle/`
3. This summary file captures everything we did
4. Any new AI can read your files and see current state

### What's Lost When You Close Terminal:
- The conversation history (but code is saved!)
- My memory of what we tried (but this summary documents it!)
- The debugging context (but this summary provides it!)

### How to Never Lose Progress:
1. Always keep the project folder
2. Update this summary when major changes happen
3. Use git if you want version control (optional)
4. Your files ARE your progress - they don't disappear

---

## Example Resume Session

### You (in new terminal):
```
I'm working on Goal Isle Flutter project. Here's the summary:
[SHOW DEBUGGING_SUMMARY.md]

The error still happens. Can you help?
```

### AI (will):
1. Read the summary file
2. Examine your current code
3. Understand the problem context
4. Suggest next debugging steps

### Result:
You continue exactly where you left off, no progress lost!

---

## Quick Reference Card

### Problem
- Flutter web app shows blank screen
- Error: "Null check operator used on a null value"
- Happens during Flutter bootstrap

### Location
- `/home/jasper/projects/goal_isle/`

### Access
- Server: http://localhost:8083
- Summary: `cat /home/jasper/projects/goal_isle/DEBUGGING_SUMMARY.md`

### Commands
```bash
cd /home/jasper/projects/goal_isle
flutter build web --no-tree-shake-icons  # Build
cd build/web && python3 -m http.server 8083  # Run
```

### Status
- Build: ✅ Works
- Runtime: ❌ Crashes
- Supabase: ❌ Disabled
- Mock Data: ✅ Implemented

---

**Remember:** Your code is your progress. As long as the files exist on your computer, you can always resume work from exactly where you left off!

---

Created: June 18, 2026
For: Goal Isle Project Debugging
Purpose: Quick resume guide for new AI sessions