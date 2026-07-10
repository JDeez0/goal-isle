#!/usr/bin/env bash
# ============================================================
# goal — one-command Goal Isle helper
# Install: source this in your .bashrc, or use as bash goal.sh
# Usage:  goal <command>
# ============================================================
set -e

GOAL_DIR="/home/jasper/projects/goal_isle"
FLUTTER_BIN="/home/jasper/flutter/bin"

# Ensure flutter is on PATH
if ! command -v flutter &> /dev/null && [ -d "$FLUTTER_BIN" ]; then
  export PATH="$FLUTTER_BIN:$PATH"
fi

# Load GitHub token for CI status (if available)
if [ -f "$HOME/.goal_token" ]; then
  source "$HOME/.goal_token" 2>/dev/null || true
fi

case "${1:-help}" in
  # ── Quick checks ──────────────────────────────────────────────────────
  check)
    if [ "$2" = "docs" ]; then
      cd "$GOAL_DIR"
      echo "=== Documentation freshness check ==="
      echo ""
      DOCS=("CURRENT_STATUS.md" "PROJECT_KNOWLEDGE.md" "README.md" "UX_UI_ITERATION_PLAN.md" "DEVELOPMENT_WORKFLOW.md" "DEVELOPMENT_GUIDE.md")
      CURRENT=$(date +%s)
      for doc in "${DOCS[@]}"; do
        if [ -f "$doc" ]; then
          MODIFIED=$(stat -c %Y "$doc" 2>/dev/null || echo "$CURRENT")
          DAYS_OLD=$(( (CURRENT - MODIFIED) / 86400 ))
          if [ "$DAYS_OLD" -gt 14 ]; then
            echo "  ⚠️  $doc — $DAYS_OLD days since last update"
          else
            echo "  ✅ $doc — $DAYS_OLD days ago"
          fi
        fi
      done
      return
    fi
    echo "=== Goal Isle Pre-Push Check ==="
    cd "$GOAL_DIR"
    flutter analyze 2>&1 | tail -1
    echo "git status:"
    git status --short
    echo ""
    echo "Protected files changed:"
    for f in ios/Runner.xcodeproj/project.pbxproj ios/Runner/Info.plist .github/workflows/ios-build.yml; do
      if git diff --name-only | grep -q "^$f$"; then
        echo "  ⚠️  $f"
      fi
    done
    ;;

  # ── Web proxy ─────────────────────────────────────────────────────────
  web)
    echo "Starting web build..."
    cd "$GOAL_DIR"
    flutter run -d chrome
    ;;

  # ── Smoke test (after flutter run is running, press 'r' to hot-reload) ──
  test)
    echo "=== Quick smoke test checklist ==="
    echo "  1. Does the app render without errors? (check terminal)"
    echo "  2. Can you navigate between tabs? (Home / Notes / League)"
    echo "  3. Tap an isle → does it load?"
    echo "  4. Create a spark → does it appear?"
    echo "  5. Send a chat → does it show?"
    echo "  6. Go back to Home → is everything still there?"
    ;;

  # ── Push (with pre-push hook) ─────────────────────────────────────────
  push)
    cd "$GOAL_DIR"
    git push "$@"
    ;;

  # ── Feature branch ────────────────────────────────────────────────────
  branch)
    if [ -z "$2" ]; then
      echo "Usage: goal branch <name>"
      echo "  feat/  — new feature"
      echo "  fix/   — bug fix"
      echo "  chore/ — maintenance"
      echo "  exp/   — experiment"
      echo ""
      echo "Current branch: $(cd "$GOAL_DIR" && git branch --show-current)"
      return
    fi
    cd "$GOAL_DIR"
    git checkout main
    git pull origin main
    git checkout -b "$2"
    echo "On branch: $2"
    ;;

  # ── Merge to main ─────────────────────────────────────────────────────
  ship)
    cd "$GOAL_DIR"
    CURRENT=$(git branch --show-current)
    if [ "$CURRENT" = "main" ]; then
      echo "Already on main. Use 'goal push' to push."
      exit 1
    fi
    # Check if docs were updated
    DOCS_UPDATED=$(git diff --name-only main..."$CURRENT" 2>/dev/null | grep -c -E "\.md$" || true)
    echo "Merging $CURRENT → main..."
    echo ""
    if [ "$DOCS_UPDATED" -eq 0 ]; then
      echo -e "${YELLOW}📝 Docs reminder:${NC} No documentation changes detected in this branch."
      echo "  If this adds/changes functionality, update:"
      echo "    • CURRENT_STATUS.md   — app state, next steps"
      echo "    • PROJECT_KNOWLEDGE.md — architecture, bugs, schema"
      echo "  Press Ctrl+C to abort, or wait 5s to continue..."
      sleep 5
    fi
    git checkout main
    git pull origin main
    git merge "$CURRENT"
    git push origin main
    echo "✅ Merged. CI will now build + upload to TestFlight."
    git branch -d "$CURRENT"
    ;;

  # ── CI status ─────────────────────────────────────────────────────────
  ci)
    curl -s "https://api.github.com/repos/JDeez0/goal-isle/actions/runs?per_page=3" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for r in d.get('workflow_runs', [])[:3]:
        c = r['conclusion'] or 'running'
        print(f\"  {r['head_sha'][:7]} - {c} - {r['created_at'][:19]}\")
except: print('  (could not fetch)')
" 2>/dev/null || echo "  (no token set)"
    ;;

  # ── Docs freshness ────────────────────────────────────────────────────
  docs)
    cd "$GOAL_DIR"
    echo "=== Documentation freshness check ==="
    echo ""
    DOCS=("CURRENT_STATUS.md" "PROJECT_KNOWLEDGE.md" "README.md" "UX_UI_ITERATION_PLAN.md" "DEVELOPMENT_WORKFLOW.md" "DEVELOPMENT_GUIDE.md")
    CURRENT=$(date +%s)
    STALE=0
    for doc in "${DOCS[@]}"; do
      if [ -f "$doc" ]; then
        MODIFIED=$(stat -c %Y "$doc" 2>/dev/null || echo "$CURRENT")
        DAYS_OLD=$(( (CURRENT - MODIFIED) / 86400 ))
        if [ "$DAYS_OLD" -gt 14 ]; then
          echo "  ⚠️  $doc — $DAYS_OLD days old (stale)"
          STALE=1
        else
          echo "  ✅ $doc — $DAYS_OLD days old"
        fi
      fi
    done
    if [ "$STALE" -eq 1 ]; then
      echo ""
      echo "  Some docs are stale. Update before shipping new features."
    fi
    ;;

  # ── Help ──────────────────────────────────────────────────────────────
  *)
    echo "goal — Goal Isle development helper"
    echo ""
    echo "Commands:"
    echo "  goal check        Run flutter analyze + git status"
    echo "  goal check docs   Check if docs are up to date"
    echo "  goal docs         Check documentation freshness"
    echo "  goal web          Launch web proxy (flutter run -d chrome)"
    echo "  goal test         Show smoke test checklist"
    echo "  goal push         Push (pre-push hook runs automatically)"
    echo "  goal branch <n>   Create feature branch from latest main"
    echo "  goal ship         Merge current branch → main → push"
    echo "  goal ci           Check latest CI runs"
    echo ""
    echo "Quick workflow:"
    echo "  goal branch feat/new-thing     # start"
    echo "  # edit code..."
    echo "  goal check                     # verify"
    echo "  goal web                       # visual test"
    echo "  # test in browser..."
    echo "  git add -A && git commit -m '...'"
    echo "  goal push -u origin feat/new-thing"
    echo "  # wait for CI..."
    echo "  goal docs                      # check docs freshness"
    echo "  goal ship                      # deploy (checks docs too)"
    ;;
esac