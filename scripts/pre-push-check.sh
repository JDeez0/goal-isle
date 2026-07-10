#!/usr/bin/env bash
# ============================================================
# Goal Isle — Pre-Push Safety Check
# Installed as .git/hooks/pre-push (run scripts/install-hooks.sh)
#
# This runs before every git push. It catches issues before
# they reach CI, saving you 10 minutes of waiting for a failed
# build. If any check fails, the push is aborted.
# ============================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Goal Isle Pre-Push Check ===${NC}"

# ---- 1. Flutter analyze ----
echo -n "flutter analyze ... "
if ! command -v flutter &> /dev/null; then
    export PATH="$HOME/flutter/bin:$PATH"
fi

ANALYZE_OUTPUT=$(flutter analyze 2>&1)
ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c " • error •" || true)

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "${RED}FAILED${NC}"
    echo ""
    echo "$ANALYZE_OUTPUT" | grep " • error •"
    echo ""
    echo -e "${RED}Push aborted: $ERROR_COUNT analyzer error(s) found.${NC}"
    echo "Fix them with 'flutter analyze' before pushing."
    exit 1
fi
echo -e "${GREEN}PASSED${NC} (0 errors)"

# ---- 2. Protected files check ----
echo -n "Protected files ... "
PROTECTED=(
    "ios/Runner.xcodeproj/project.pbxproj"
    "ios/Runner/Info.plist"
    "ios/Runner/Base.lproj/Main.storyboard"
    "ios/Runner/Base.lproj/LaunchScreen.storyboard"
    ".github/workflows/ios-build.yml"
    "cer.enc"
    "key.enc"
    "profile.enc"
)

CHANGED_PROTECTED=""
for file in "${PROTECTED[@]}"; do
    if git diff --cached --name-only | grep -q "^$file$"; then
        CHANGED_PROTECTED="$CHANGED_PROTECTED  $file\n"
    fi
done

if [ -n "$CHANGED_PROTECTED" ]; then
    echo -e "${YELLOW}WARNING${NC}"
    echo ""
    echo -e "The following PROTECTED files are staged for commit:"
    echo -e "$CHANGED_PROTECTED"
    echo -e "${YELLOW}These files can break the iOS build.${NC}"
    echo "Are you sure you want to continue? (y/N)"
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        echo "Push aborted."
        exit 1
    fi
else
    echo -e "${GREEN}PASSED${NC} (no protected files changed)"
fi

# ---- 3. pubspec dependency check ----
echo -n "Dependency changes ... "
if git diff --cached --name-only | grep -q "^pubspec.yaml$"; then
    echo -e "${YELLOW}WARNING${NC} (pubspec.yaml changed — verify dependencies are SPM-compatible)"
    echo "  If you added a native plugin, test on a manual CI run before merging to main."
else
    echo -e "${GREEN}PASSED${NC} (no pubspec changes)"
fi

echo ""
echo -e "${GREEN}=== All checks passed — pushing ===${NC}"