#!/bin/bash
# ForgeTeam integration test: forge verify
# Tests the 4-gate verification pipeline

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR=$(mktemp -d)
errors=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

echo "ForgeTeam Integration Test: forge verify"
echo "══════════════════════════════════════════"

# ─── Test 1: All gates pass (library project, run gate skipped) ───
echo ""
echo "Test 1: All gates pass (library project)"
echo "─────────────────────────────────────────"

mkdir -p "$TEST_DIR/test-lib"
cd "$TEST_DIR/test-lib"
git init -q

# Create config
mkdir -p .forgeteam
cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-lib"
  type: "library"
  language: "javascript"
verification:
  build_gate: true
  test_gate: true
  run_gate: true
  safety_gate: true
commands:
  build: "echo build-ok"
  test: "echo test-ok"
  start: ""
EOF

# Run verify
output=$("$PROJECT_ROOT/forge" verify 2>&1) || true

if echo "$output" | grep -q "All gates passed"; then
  echo "  PASS: verify reports all gates passed"
else
  echo "  FAIL: expected 'All gates passed'"
  echo "  Output: $output"
  ((errors++))
fi

if echo "$output" | grep -q "SKIP.*library project"; then
  echo "  PASS: run gate correctly skipped for library"
else
  echo "  FAIL: expected run gate to be skipped for library"
  ((errors++))
fi

# ─── Test 2: Build failure → verify fails ───
echo ""
echo "Test 2: Build failure causes verify to fail"
echo "────────────────────────────────────────────"

mkdir -p "$TEST_DIR/test-fail"
cd "$TEST_DIR/test-fail"
git init -q

mkdir -p .forgeteam
cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-fail"
  type: "web-app"
  language: "javascript"
verification:
  build_gate: true
  test_gate: true
  run_gate: false
  safety_gate: true
commands:
  build: "exit 1"
  test: "echo test-ok"
  start: ""
EOF

if "$PROJECT_ROOT/forge" verify > /dev/null 2>&1; then
  echo "  FAIL: verify should have returned non-zero exit code"
  ((errors++))
else
  echo "  PASS: verify correctly returns exit 1 on build failure"
fi

# ─── Test 3: No config → error message ───
echo ""
echo "Test 3: Missing config shows error"
echo "───────────────────────────────────"

mkdir -p "$TEST_DIR/test-noconfig"
cd "$TEST_DIR/test-noconfig"
git init -q

output=$("$PROJECT_ROOT/forge" verify 2>&1) || true

if echo "$output" | grep -q "forge init"; then
  echo "  PASS: verify prompts user to run forge init"
else
  echo "  FAIL: expected prompt to run forge init"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Test 4: Safety gate catches .env in git ───
echo ""
echo "Test 4: Safety gate detects .env tracked by git"
echo "────────────────────────────────────────────────"

mkdir -p "$TEST_DIR/test-safety"
cd "$TEST_DIR/test-safety"
git init -q

mkdir -p .forgeteam
cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-safety"
  type: "web-app"
  language: "javascript"
verification:
  build_gate: false
  test_gate: false
  run_gate: false
  safety_gate: true
commands:
  build: ""
  test: ""
  start: ""
EOF

# Track .env in git
echo "SECRET_KEY=abc123" > .env
git add .env
git commit -q -m "add env"

output=$("$PROJECT_ROOT/forge" verify 2>&1) || true

if echo "$output" | grep -q "FAIL"; then
  echo "  PASS: safety gate detects .env tracked by git"
else
  echo "  FAIL: safety gate should detect .env in git"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Test 5: All gates skipped when disabled ───
echo ""
echo "Test 5: All gates skip when disabled"
echo "─────────────────────────────────────"

mkdir -p "$TEST_DIR/test-skip"
cd "$TEST_DIR/test-skip"
git init -q

mkdir -p .forgeteam
cat > .forgeteam/config.yaml <<'EOF'
version: "1.0"
project:
  name: "test-skip"
  type: "web-app"
  language: "javascript"
verification:
  build_gate: false
  test_gate: false
  run_gate: false
  safety_gate: false
commands:
  build: ""
  test: ""
  start: ""
EOF

output=$("$PROJECT_ROOT/forge" verify 2>&1) || true

if echo "$output" | grep -q "All gates passed"; then
  echo "  PASS: all gates skipped still counts as pass"
else
  echo "  FAIL: expected pass when all gates are disabled"
  echo "  Output: $output"
  ((errors++))
fi

# ─── Results ───
echo ""
echo "══════════════════════════════════════════"
if [ $errors -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  echo "FAILED: $errors error(s)"
  exit 1
fi
