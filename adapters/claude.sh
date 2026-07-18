#!/bin/bash
# ForgeTeam — Claude Code adapter
# Generates CLAUDE.md, .claude/commands/, and .claude/settings.json
# Called via: source adapters/claude.sh && generate_claude

generate_claude() {
  local forge_home="${FORGE_HOME:-$HOME/.forgeteam}"

  mkdir -p .claude/commands

  _claude_backup
  _claude_generate_md
  _claude_generate_commands "$forge_home"
  _claude_generate_hooks
}

_claude_backup() {
  if [ -f "CLAUDE.md" ]; then
    if ! grep -Fq "This project uses ForgeTeam" CLAUDE.md 2>/dev/null; then
      cp CLAUDE.md "CLAUDE.md.backup.$(date '+%Y%m%d%H%M%S')"
      echo "  NOTE: Existing CLAUDE.md backed up (had custom content)"
    fi
  fi
}

_claude_generate_md() {
  cat > CLAUDE.md <<'EOF'
# ForgeTeam

This project uses ForgeTeam for AI-assisted development.

## Auto-Loaded Context

On session start, read:
- .forgeteam/memory/project-map.md
- .forgeteam/memory/state.md
- .forgeteam/memory/preferences.md
- .forgeteam/config.yaml

## Available Commands

- /forge-propose — Start a new feature proposal
- /forge-html-prototype — Generate HTML prototype for visual confirmation
- /forge-plan — Create execution plan
- /forge-execute — Run task execution
- /forge-review — Code review
- /forge-verify — Quality verification (safety + phase gate + 4-gate pipeline)
- /forge-ship — Commit and archive
- /forge-debug — Fix verification failures
- /forge-memory — Save progress and extract learnings
- /forge-evolve — Evaluate ecosystem changes and evolution
- /forge-onboard — Rescan project structure

## Workflow Rules

1. Auto-detect route level (micro/standard/full) based on change scope
2. Follow skill instructions exactly
3. Update state.md after each significant action
4. Never skip verification gates
5. Pause and ask human after 3 failed fix attempts
6. Keep documentation in sync with code changes
7. When tasks.md has `parallel:` blocks, execute those tasks concurrently using multi-file editing

## Route Detection

- Micro (< 50 lines, <= 3 files, no API/DB change): execute → verify → done
- Standard (50-500 lines, <= 10 files): plan → [html] → execute → review → verify → ship
- Full (> 500 lines, multi-module): propose → [html] → plan → execute → review → verify → ship

Note: [html] = auto-insert html-prototype step when UI/page changes are involved

## Safety Rules

- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

EOF
}

_claude_generate_commands() {
  local forge_home="$1"
  local skills_dir="$forge_home/skills"

  # Generate commands from installed skills
  if [ -d "$skills_dir" ]; then
    for skill_dir in "$skills_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name
      skill_name=$(basename "$skill_dir")
      [ "$skill_name" = "version.txt" ] && continue

      local skill_file="$skill_dir/SKILL.md"
      [ -f "$skill_file" ] || continue

      cat > ".claude/commands/forge-${skill_name}.md" <<CMDEOF
# forge ${skill_name}

Execute the ForgeTeam ${skill_name} skill.

## Instructions

$(cat "$skill_file")

## Context

Load before execution:
- .forgeteam/config.yaml
- .forgeteam/memory/state.md
- .forgeteam/memory/project-map.md
- .forgeteam/memory/preferences.md
- specs/active/ (if exists)
CMDEOF
    done
  fi

  # Handle extension skills
  if [ -d ".forgeteam/extensions/skills" ]; then
    for ext_skill in .forgeteam/extensions/skills/*/; do
      [ -d "$ext_skill" ] || continue
      local ext_name
      ext_name=$(basename "$ext_skill")
      local ext_file="$ext_skill/SKILL.md"
      [ -f "$ext_file" ] || continue

      cat > ".claude/commands/forge-${ext_name}.md" <<CMDEOF
# forge ${ext_name} (extension)

Execute the ForgeTeam ${ext_name} extension skill.

## Instructions

$(cat "$ext_file")

## Context

Load before execution:
- .forgeteam/config.yaml
- .forgeteam/memory/state.md
- .forgeteam/memory/project-map.md
- specs/active/ (if exists)
CMDEOF
    done
  fi
}

_claude_generate_hooks() {
  if [ -f ".claude/settings.json" ]; then
    if ! grep -Fq "ForgeTeam" .claude/settings.json 2>/dev/null; then
      return 0
    fi
  fi

  cat > .claude/settings.json <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "command": "cat .forgeteam/memory/state.md .forgeteam/memory/decisions.md .forgeteam/memory/known-issues.md 2>/dev/null || true",
        "description": "Load ForgeTeam state and evidence-backed memory on session start"
      }
    ]
  }
}
EOF
}
