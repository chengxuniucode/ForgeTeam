#!/bin/bash
# ForgeTeam — OpenCode 适配器
# 生成 AGENTS.md 配置

set -euo pipefail

generate_opencode() {
  cat > AGENTS.md <<'EOF'
# ForgeTeam

## Context

- Config: .forgeteam/config.yaml
- State: .forgeteam/memory/state.md
- Memory: .forgeteam/memory/
- Specs: specs/active/

## Workflow

Auto-detect route level based on change scope, then execute skills in order:

### Micro Route (< 50 lines, ≤ 3 files)
execute → verify → done

### Standard Route (50-500 lines, ≤ 10 files)
plan → execute → review → verify → ship

### Full Route (> 500 lines, multi-module)
propose → plan → execute → review → verify → ship

## Verification Gates

All changes must pass these gates before shipping:

1. **Build Gate**: compile/transpile must succeed
2. **Test Gate**: all tests pass, coverage >= threshold
3. **Run Gate**: service starts and responds (skipped for libraries)
4. **Safety Gate**: no secrets, no dangerous operations

## Safety Rules

- Never force push to protected branches
- Never commit .env or credential files
- Always run verification before committing
- Pause after 3 failed fix attempts — ask human for guidance

## Skills

Skills are defined in ~/.forgeteam/skills/{name}/SKILL.md and provide
detailed instructions for each workflow phase.

## Circuit Breaker

If the same error persists after 3 fix attempts:
1. Stop attempting fixes
2. Report: what failed, what was tried, suggested directions
3. Wait for human input before continuing

EOF

  echo "✓ OpenCode configuration generated"
}

generate_opencode
