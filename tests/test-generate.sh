#!/bin/bash
# ForgeTeam integration test: forge generate
# Tests that each target adapter generates correct output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR=$(mktemp -d)
errors=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

assert_file_exists() {
  if [ ! -f "$1" ]; then
    echo "FAIL: expected file $1"
    ((errors++))
  fi
}

assert_contains() {
  local file="$1" pattern="$2"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    echo "FAIL: $file does not contain '$pattern'"
    ((errors++))
  fi
}

echo "ForgeTeam Integration Test: forge generate"
echo "══════════════════════════════════════════"

# Setup
export FORGE_HOME="$TEST_DIR/forgeteam-home"
mkdir -p "$FORGE_HOME/skills/propose"
mkdir -p "$FORGE_HOME/skills/plan"
mkdir -p "$FORGE_HOME/adapters"
cp "$PROJECT_ROOT/forge" "$FORGE_HOME/forge"
cp "$PROJECT_ROOT/adapters"/* "$FORGE_HOME/adapters/"

# Create minimal skill files for testing
echo -e "---\nname: propose\n---\n# Propose" > "$FORGE_HOME/skills/propose/SKILL.md"
echo -e "---\nname: plan\n---\n# Plan" > "$FORGE_HOME/skills/plan/SKILL.md"

cd "$TEST_DIR"
mkdir test-project && cd test-project
git init -q
mkdir -p .forgeteam

# ─── Test: Claude ───
echo ""
echo "Testing target: claude"
bash "$FORGE_HOME/forge" generate --target claude > /dev/null 2>&1
assert_file_exists "CLAUDE.md"
assert_contains "CLAUDE.md" "ForgeTeam"
assert_contains "CLAUDE.md" "html-prototype"
assert_contains "CLAUDE.md" "[html]"
assert_contains "CLAUDE.md" "documentation in sync"
assert_file_exists ".claude/commands/forge-propose.md"
assert_file_exists ".claude/commands/forge-plan.md"
echo "  claude: OK"

# ─── Test: Cursor ───
echo "Testing target: cursor"
bash "$FORGE_HOME/forge" generate --target cursor > /dev/null 2>&1
assert_file_exists ".cursor/rules/forgeteam.mdc"
assert_contains ".cursor/rules/forgeteam.mdc" "html-prototype"
assert_contains ".cursor/rules/forgeteam.mdc" "[html]"
assert_contains ".cursor/rules/forgeteam.mdc" "memory"
echo "  cursor: OK"

# ─── Test: Codex ───
echo "Testing target: codex"
bash "$FORGE_HOME/forge" generate --target codex > /dev/null 2>&1
assert_file_exists "codex.md"
assert_contains "codex.md" "html-prototype"
assert_contains "codex.md" "[html]"
assert_contains "codex.md" "documentation in sync"
echo "  codex: OK"

# ─── Test: OpenCode ───
echo "Testing target: opencode"
bash "$FORGE_HOME/forge" generate --target opencode > /dev/null 2>&1
assert_file_exists "AGENTS.md"
assert_contains "AGENTS.md" "html-prototype"
assert_contains "AGENTS.md" "[html]"
assert_contains "AGENTS.md" "Doc-Code Sync"
echo "  opencode: OK"

# ─── Test: Invalid target ───
echo "Testing invalid target..."
if bash "$FORGE_HOME/forge" generate --target invalid 2>/dev/null; then
  echo "FAIL: should have failed on invalid target"
  ((errors++))
else
  echo "  invalid target: correctly rejected"
fi

echo ""
echo "══════════════════════════════════════════"
if [ $errors -eq 0 ]; then
  echo "✓ All generate tests passed"
  exit 0
else
  echo "✗ $errors test(s) failed"
  exit 1
fi
