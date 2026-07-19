#!/bin/bash
# ForgeTeam — OpenCode adapter
# Generates AGENTS.md
# Called via: source adapters/opencode.sh && generate_opencode

generate_opencode() {
  cat > AGENTS.md <<'EOF'
# ForgeTeam

## Context

- Config: .forgeteam/config.yaml
- State: .forgeteam/memory/state.md
- Memory: .forgeteam/memory/
- Specs: specs/active/

## Route Detection

- Micro (< 50 lines): execute → verify → done
- Standard (50-500 lines): plan → [html] → execute → review → verify → ship
- Full (> 500 lines): propose → [html] → plan → execute → review → verify → ship

Note: [html] = auto-insert html step when UI/page changes are involved

## Verification Gates

1. Build Gate: compile/transpile must succeed
2. Test Gate: all tests pass, coverage >= threshold
3. Run Gate: service starts and responds (skip for libraries)
4. Safety Gate: no secrets, no dangerous ops

## Available Skills

- propose, html, plan, execute, review, verify, ship
- debug, memory, evolve, onboard

Skills located at: ~/.forgeteam/skills/{name}/SKILL.md

## Doc-Code Sync

Keep documentation in specs/ aligned with code at all times.
Review skill checks consistency; ship skill blocks if not in sync.

## Circuit Breaker

- Single task: max 3 fix attempts, then pause for human
- Cross-task: 2 consecutive failures → full stop
- Safety gate failure → immediate stop, report to user

## Safety Rules

- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

EOF
}
