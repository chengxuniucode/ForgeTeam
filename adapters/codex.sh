#!/bin/bash
# ForgeTeam — Codex 适配器
# 生成 codex.md 配置

set -euo pipefail

generate_codex() {
  cat > codex.md <<'EOF'
# ForgeTeam

## Instructions

This project uses ForgeTeam workflow. Follow these rules:

1. Read .forgeteam/config.yaml for project settings
2. Read .forgeteam/memory/state.md for current progress
3. Auto-detect route level based on change scope:
   - Micro (< 50 lines): execute → verify → done
   - Standard (50-500 lines): plan → execute → review → verify → ship
   - Full (> 500 lines): propose → plan → execute → review → verify → ship
4. Execute skills in order following the detected route
5. Never skip verification (build + test + run + safety)
6. Update .forgeteam/memory/state.md after significant actions
7. Pause after 3 failed fix attempts

## Skill Locations

Skills are in ~/.forgeteam/skills/{name}/SKILL.md:
- propose — Requirement clarification
- plan — Task decomposition
- execute — Code implementation
- review — Code review
- verify — Quality verification (Build/Test/Run/Safety gates)
- ship — Git commit and archive
- debug — Fix verification failures
- checkpoint — Save progress
- learn — Extract learnings

## Safety Rules

- Never force push to main/master
- Never commit secrets or .env files
- Always verify before shipping
- Pause and ask human on repeated failures

## Context Files

- .forgeteam/config.yaml — Configuration
- .forgeteam/memory/project-map.md — Project structure
- .forgeteam/memory/state.md — Current task state
- .forgeteam/memory/decisions.md — Past decisions
- .forgeteam/memory/known-issues.md — Known issues and solutions
- specs/active/ — Active task specifications

EOF

  echo "✓ Codex configuration generated"
}

generate_codex
