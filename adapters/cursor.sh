#!/bin/bash
# ForgeTeam — Cursor 适配器
# 从 skills/ 源文件生成 .cursor/ 配置

set -euo pipefail

FORGE_HOME="${FORGE_HOME:-$HOME/.forgeteam}"

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

Load these files for context:
- .forgeteam/memory/project-map.md — Project structure
- .forgeteam/memory/state.md — Current progress
- .forgeteam/memory/preferences.md — Team preferences
- .forgeteam/config.yaml — Configuration

## Workflow

### Route Detection
1. **Micro** (< 50 lines, ≤ 3 files, no API/DB change): execute → verify → done
2. **Standard** (50-500 lines, ≤ 10 files): plan → execute → review → verify → ship
3. **Full** (> 500 lines, multi-module): propose → plan → execute → review → verify → ship

### Core Rules
- Follow skill-specific instructions in ~/.forgeteam/skills/{name}/SKILL.md
- Verify before shipping: Build → Test → Run → Safety
- Update .forgeteam/memory/state.md after significant actions
- Never skip verification gates
- Pause after 3 failed fix attempts and ask for human input

### Safety
- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

## Key Files
- .forgeteam/config.yaml — Project configuration
- .forgeteam/memory/state.md — Current state
- specs/active/ — Active specifications
- specs/archived/ — Completed specs

## Skills
Skills are located at ~/.forgeteam/skills/{name}/SKILL.md:
- propose: Requirement clarification and solution selection
- plan: Task decomposition and execution planning
- execute: Step-by-step code implementation
- review: Automated code review
- verify: Build → Test → Run → Safety verification
- ship: Git commit and spec archival
- debug: Automatic fix loop for verification failures
- checkpoint: Save progress for cross-session resume
- learn: Extract learnings to memory
- onboard: Project scanning and map generation
- safety-guard: Runtime safety protection
- quality-gate: Phase transition checks

EOF

  echo "✓ Cursor configuration generated"
}

generate_cursor
