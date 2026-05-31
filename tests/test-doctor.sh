#!/bin/bash
# ForgeTeam integration test: forge doctor
# Tests the 5-check health diagnostic

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR=$(mktemp -d)
errors=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Use the forge script from this repo
export FORGE_HOME="$TEST_DIR/forge-home"
mkdir -p "$FORGE_HOME/skills"
mkdir -p "$FORGE_HOME/adapters"

# Copy skills and adapters for testing
cp -r "$PROJECT_ROOT/skills"/* "$FORGE_HOME/skills/"
cp -r "$PROJECT_ROOT/adapters"/* "$FORGE_HOME/adapters/"

# Create version.txt
echo "1.0.1" > "$FORGE_HOME/skills/version.txt"

FORGE="$PROJECT_ROOT/forge"

echo "ForgeTeam Integration Test: forge doctor"
echo "══════════════════════════════════════════"

# ─── Test 1: No .forgeteam directory (fail gracefully) ───
echo ""
echo "Test 1: Uninitialized project"
echo "─────────────────────────────"

mkdir -p "$TEST_DIR/test-no-init"
cd "$TEST_DIR/test-no-init"

output=$("$FORGE" doctor 2>&1 || true)
if echo "$output" | grep -q "config.yaml not found"; then
  echo "  PASS: Reports missing config"
else
  echo "  FAIL: Should report missing config.yaml"
  ((errors++))
fi

# ─── Test 2: Valid initialized project ───
echo ""
echo "Test 2: Healthy project"
echo "───────────────────────"

mkdir -p "$TEST_DIR/test-healthy"
cd "$TEST_DIR/test-healthy"
git init -q

mkdir -p .forgeteam/memory
mkdir -p .claude/commands

# Create valid config
cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-healthy"
  type: "web-app"
  language: "typescript"
  framework: "next"
routing:
  micro_threshold: 50
  standard_threshold: 500
verification:
  build_gate: true
  test_gate: true
  run_gate: true
  safety_gate: true
commands:
  build: "npm run build"
  test: "npm test"
  start: "npm start"
safety:
  level: "standard"
adapters:
  target: "claude"
EOF

# Create memory files
cat > .forgeteam/memory/project-map.md <<'EOF'
# Project Map
- Language: typescript
- Framework: Next.js
EOF
touch .forgeteam/memory/state.md

# Create platform files
cat > CLAUDE.md <<'EOF'
# ForgeTeam
This project uses ForgeTeam for AI-assisted development.
EOF
touch .claude/commands/forge-plan.md

output=$("$FORGE" doctor 2>&1)
if echo "$output" | grep -q "Everything looks good"; then
  echo "  PASS: Healthy project diagnosed correctly"
else
  echo "  FAIL: Should report healthy status"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Test 3: Missing skills ───
echo ""
echo "Test 3: Missing skills detection"
echo "────────────────────────────────"

# Remove a skill to test detection
rm -rf "$FORGE_HOME/skills/debug"

output=$("$FORGE" doctor 2>&1 || true)
if echo "$output" | grep -q "Missing skills.*debug"; then
  echo "  PASS: Detects missing skill"
else
  echo "  FAIL: Should detect missing debug skill"
  echo "  Output: $output"
  ((errors++))
fi

# Restore for next test
mkdir -p "$FORGE_HOME/skills/debug"
cp "$PROJECT_ROOT/skills/debug/SKILL.md" "$FORGE_HOME/skills/debug/"

# ─── Test 4: Platform mismatch ───
echo ""
echo "Test 4: Platform config mismatch"
echo "────────────────────────────────"

mkdir -p "$TEST_DIR/test-mismatch"
cd "$TEST_DIR/test-mismatch"
git init -q
mkdir -p .forgeteam/memory

cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-mismatch"
  type: "web-app"
  language: "typescript"
routing:
  micro_threshold: 50
verification:
  build_gate: true
commands:
  build: "npm run build"
safety:
  level: "standard"
adapters:
  target: "cursor"
EOF

cat > .forgeteam/memory/project-map.md <<'EOF'
# Project Map
EOF

# No .cursor/rules/ directory — should flag mismatch
output=$("$FORGE" doctor 2>&1 || true)
if echo "$output" | grep -q "not found.*cursor"; then
  echo "  PASS: Detects platform mismatch"
else
  echo "  FAIL: Should detect missing cursor config"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Test 5: Stale project-map ───
echo ""
echo "Test 5: Stale memory detection"
echo "──────────────────────────────"

mkdir -p "$TEST_DIR/test-stale"
cd "$TEST_DIR/test-stale"
git init -q
mkdir -p .forgeteam/memory .claude/commands

cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-stale"
  type: "web-app"
  language: "go"
routing:
  micro_threshold: 50
verification:
  build_gate: true
commands:
  build: "go build"
safety:
  level: "standard"
adapters:
  target: "claude"
EOF

cat > CLAUDE.md <<'EOF'
# ForgeTeam
EOF

# Create a project-map with old timestamp
cat > .forgeteam/memory/project-map.md <<'EOF'
# Project Map
EOF

# Touch with old date (60 days ago)
if [ "$(uname)" = "Darwin" ]; then
  touch -t "$(date -v-60d '+%Y%m%d%H%M.%S')" .forgeteam/memory/project-map.md
else
  touch -d "60 days ago" .forgeteam/memory/project-map.md
fi

output=$("$FORGE" doctor 2>&1 || true)
if echo "$output" | grep -q "days old"; then
  echo "  PASS: Detects stale project-map"
else
  echo "  FAIL: Should detect stale project-map"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Summary ───
echo ""
echo "══════════════════════════════════════════"
if [ $errors -eq 0 ]; then
  echo "All tests passed!"
  exit 0
else
  echo "$errors test(s) failed"
  exit 1
fi
