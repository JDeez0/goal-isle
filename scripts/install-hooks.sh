#!/usr/bin/env bash
# ============================================================
# Goal Isle — Install Git Hooks
# Run once: bash scripts/install-hooks.sh
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/../.git/hooks"

echo "Installing Goal Isle git hooks..."

# Pre-push hook
cp "$SCRIPT_DIR/pre-push-check.sh" "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"
echo "  ✓ pre-push (flutter analyze + protected files check)"

echo ""
echo "Hooks installed. They will run automatically on every git push."
echo "To skip hooks temporarily: git push --no-verify"