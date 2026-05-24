#!/bin/bash
# ForgeTeam — Codex adapter
# Generates codex.md
# Called via: source adapters/codex.sh && generate_codex

generate_codex() {
  cat > codex.md <<'EOF'
# ForgeTeam

## Instructions

This project uses ForgeTeam workflow. Follow these rules:

1. Read .forgeteam/config.yaml for project settings
2. Read .forgeteam/memory/state.md for current progress
3. Auto-detect route level based on change scope:
   - Micro (< 50 lines): execute → verify → done
   - Standard (50-500 lines): plan → [html] → execute → review → verify → ship
   - Full (> 500 lines): propose → [html] → plan → execute → review → verify → ship
4. Execute skills in order following the detected route
5. Never skip verification (build + test + run + safety)
6. Update state.md after significant actions
7. Pause after 3 failed fix attempts
8. Keep documentation in sync with code changes

Note: [html] = auto-insert html-prototype step when UI/page changes are involved

## Context Files

Load before working:
- .forgeteam/config.yaml
- .forgeteam/memory/project-map.md
- .forgeteam/memory/state.md
- .forgeteam/memory/decisions.md
- .forgeteam/memory/known-issues.md
- specs/active/ (if exists)

## Available Skills

- propose — Feature proposal and option comparison
- html-prototype — Generate static HTML prototype for confirmation
- plan — Task breakdown and execution planning
- execute — Step-by-step code implementation
- review — Code review (security, performance, style)
- verify — Safety guard + phase gate + Build → Test → Run → Safety pipeline
- ship — Commit, archive, and changelog
- debug — Fix verification failures
- memory — Save progress and extract learnings
- evolve — Evaluate ecosystem changes
- onboard — Scan project structure

## Skill Locations

Skills are in ~/.forgeteam/skills/{name}/SKILL.md

## Safety Rules

- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

EOF
}
