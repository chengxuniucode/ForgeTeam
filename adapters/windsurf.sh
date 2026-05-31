#!/bin/bash
# ForgeTeam — Windsurf adapter
# Generates .windsurf/rules/forgeteam.md
# Called via: source adapters/windsurf.sh && generate_windsurf

generate_windsurf() {
  mkdir -p .windsurf/rules

  cat > .windsurf/rules/forgeteam.md <<'EOF'
# ForgeTeam Rules for Windsurf

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
7. When tasks.md has `parallel:` blocks, execute those tasks concurrently

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
