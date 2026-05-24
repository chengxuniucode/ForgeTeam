#!/bin/bash
# ForgeTeam — Cursor adapter
# Generates .cursor/rules/forgeteam.mdc
# Called via: source adapters/cursor.sh && generate_cursor

generate_cursor() {
  mkdir -p .cursor/rules

  cat > .cursor/rules/forgeteam.mdc <<'EOF'
---
description: ForgeTeam AI Development Framework
globs: ["**/*"]
alwaysApply: true
---

# ForgeTeam Rules for Cursor

## Session Start

Load context from:
- .forgeteam/memory/project-map.md — Project structure
- .forgeteam/memory/state.md — Current progress
- .forgeteam/memory/preferences.md — Team preferences
- .forgeteam/config.yaml — Configuration

## Route Detection

1. **Micro** (< 50 lines, <= 3 files, no API/DB change): execute → verify → done
2. **Standard** (50-500 lines, <= 10 files): plan → [html] → execute → review → verify → ship
3. **Full** (> 500 lines, multi-module): propose → [html] → plan → execute → review → verify → ship

Note: [html] = auto-insert html-prototype step when UI/page changes are involved

## Core Rules

1. Follow skill-specific instructions from ~/.forgeteam/skills/{name}/SKILL.md
2. Verify before shipping: Build → Test → Run → Safety
3. Update .forgeteam/memory/state.md after actions
4. Never skip verification gates
5. Pause after 3 failed fix attempts
6. Keep documentation in sync with code changes

## Available Skills

- propose — Feature proposal and option comparison
- html-prototype — Generate static HTML prototype for confirmation
- plan — Task breakdown and execution planning
- execute — Step-by-step code implementation
- review — Code review (security, performance, style)
- verify — Build → Test → Run → Safety gates
- ship — Commit, archive, and changelog
- debug — Fix verification failures
- checkpoint — Save session progress
- learn — Extract learnings to memory
- evolve — Evaluate ecosystem changes
- onboard — Scan project structure
- safety-guard — Safety checks before dangerous ops
- quality-gate — Phase transition quality enforcement

## Safety Rules

- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

## Key Files

- .forgeteam/config.yaml — Project configuration
- .forgeteam/memory/state.md — Current state
- specs/active/ — Active specifications
- specs/archived/ — Completed specs

EOF
}
