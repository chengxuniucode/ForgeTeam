#!/bin/bash
# ForgeTeam — Claude Code 适配器
# 从 skills/ 源文件生成 .claude/ 配置

set -euo pipefail

FORGE_HOME="${FORGE_HOME:-$HOME/.forgeteam}"

generate_claude() {
  mkdir -p .claude/commands

  generate_claude_md
  generate_claude_commands
  generate_claude_hooks

  echo "✓ Claude Code configuration generated"
}

generate_claude_md() {
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
- /forge-plan — Create execution plan
- /forge-execute — Run task execution
- /forge-review — Code review
- /forge-verify — Quality verification
- /forge-ship — Commit and archive
- /forge-debug — Fix verification failures
- /forge-checkpoint — Save progress
- /forge-status — Show current state

## Workflow Rules

1. Auto-detect route level (micro/standard/full) based on change scope
2. Follow skill instructions exactly
3. Update state.md after each significant action
4. Never skip verification gates
5. Pause and ask human after 3 failed fix attempts

## Route Detection

- Micro (< 50 lines, <= 3 files, no API/DB change): execute → verify → done
- Standard (50-500 lines, <= 10 files): plan → execute → review → verify → ship
- Full (> 500 lines, multi-module): propose → plan → execute → review → verify → ship

## Safety Rules

- Never force push to main/master
- Never commit .env or secret files
- Never rm -rf without confirmation
- Always run verification before shipping

EOF
}

generate_claude_commands() {
  local skills_dir="$FORGE_HOME/skills"

  for skill_dir in "$skills_dir"/*/; do
    [ ! -d "$skill_dir" ] && continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    [ "$skill_name" = "version.txt" ] && continue

    local skill_file="$skill_dir/SKILL.md"
    [ ! -f "$skill_file" ] && continue

    local cmd_file=".claude/commands/forge-${skill_name}.md"

    cat > "$cmd_file" <<EOF
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
EOF
  done

  # Handle extension skills
  if [ -d ".forgeteam/extensions/skills" ]; then
    for ext_skill in .forgeteam/extensions/skills/*/; do
      [ ! -d "$ext_skill" ] && continue
      local ext_name
      ext_name=$(basename "$ext_skill")
      local ext_file="$ext_skill/SKILL.md"
      [ ! -f "$ext_file" ] && continue

      local cmd_file=".claude/commands/forge-${ext_name}.md"
      cat > "$cmd_file" <<EOF
# forge ${ext_name} (extension)

Execute the ForgeTeam ${ext_name} extension skill.

## Instructions

$(cat "$ext_file")

## Context

Load before execution:
- .forgeteam/config.yaml
- .forgeteam/memory/state.md
- .forgeteam/memory/project-map.md
EOF
    done
  fi
}

generate_claude_hooks() {
  cat > .claude/settings.json <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "command": "cat .forgeteam/memory/state.md 2>/dev/null || true",
        "description": "Load ForgeTeam state on session start"
      }
    ]
  }
}
EOF
}

generate_claude
