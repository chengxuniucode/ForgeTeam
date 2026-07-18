#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cd "$tmp"; git init -q; git config user.email a@b.c; git config user.name test
mkdir -p .forgeteam/memory specs/active/change extension
printf '%s\n' '# Current State' '- 状态: planned' > .forgeteam/memory/state.md
printf '%s\n' 'version: "1"' > .forgeteam/config.yaml
git add .forgeteam && git commit -qm initial
"$root/forge" analytics event execute completed pass >/dev/null
test -s .forgeteam/analytics/events.jsonl
"$root/forge" state transition running >/dev/null
grep -q 'running' .forgeteam/memory/state.md
"$root/forge" state approve >/dev/null
"$root/forge" index rebuild >/dev/null
test -f .forgeteam/memory/index.md
mkdir repo-root
"$root/forge" workspace add repo-root >/dev/null
"$root/forge" workspace list | grep -q repo-root
"$root/forge" memory record decision "use local events" >/dev/null
grep -q 'use local events' .forgeteam/memory/decisions.md
"$root/forge" state transition running >/dev/null; grep -q 'running' .forgeteam/memory/state.md
printf '%s\n' '测试先行: failure test' > specs/active/change/tasks.md
"$root/forge" tdd check specs/active/change/tasks.md >/dev/null
printf '%s\n' '## ADDED' > specs/active/change/delta.md
"$root/forge" spec archive change >/dev/null; test -f specs/current/CHANGELOG.md
printf '%s\n' '---' 'name: e' '---' > extension/SKILL.md
printf '%s\n' 'name: e' 'platforms: [claude]' > extension/manifest.yaml
"$root/forge" bundle export extension exported.tar.gz >/dev/null; test -f exported.tar.gz
"$root/forge" worktree create isolated >/dev/null; test -d .forgeteam/workspaces/isolated
"$root/forge" worktree remove isolated >/dev/null
printf 'checkpoint\n' > checkpoint.txt
"$root/forge" checkpoint "evolution test" >/dev/null
git log -1 --pretty=%s | grep -q 'wip: checkpoint - evolution test'
"$root/forge" evolve report >/dev/null
test -f "evolution/evolution-report-$(date '+%Y-%m-%d').md"
echo "evolution tests passed"
