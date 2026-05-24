#!/bin/bash
# ForgeTeam 项目结构验证脚本
# 验证所有必须的文件和目录是否存在且格式正确

set -euo pipefail

errors=0
warnings=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
  if [ ! -f "$1" ]; then
    echo -e "  ${RED}MISSING${NC}: $1"
    ((errors++))
  else
    echo -e "  ${GREEN}✓${NC} $1"
  fi
}

check_dir() {
  if [ ! -d "$1" ]; then
    echo -e "  ${RED}MISSING${NC}: $1/"
    ((errors++))
  else
    echo -e "  ${GREEN}✓${NC} $1/"
  fi
}

echo "ForgeTeam Structure Validation"
echo "══════════════════════════════════"
echo ""

# ─── Core Files ───
echo "Core Files:"
check_file "forge"
check_file "install.sh"
check_file "README.md"
check_file "LICENSE"
echo ""

# ─── Check forge is executable ───
echo "Permissions:"
if [ -f "forge" ] && [ -x "forge" ]; then
  echo -e "  ${GREEN}✓${NC} forge is executable"
else
  echo -e "  ${YELLOW}WARN${NC}: forge is not executable"
  ((warnings++))
fi
if [ -f "install.sh" ] && [ -x "install.sh" ]; then
  echo -e "  ${GREEN}✓${NC} install.sh is executable"
else
  echo -e "  ${YELLOW}WARN${NC}: install.sh is not executable"
  ((warnings++))
fi
echo ""

# ─── Skills ───
echo "Skills (14 required):"
required_skills=(
  "propose"
  "html-prototype"
  "onboard"
  "plan"
  "execute"
  "review"
  "verify"
  "ship"
  "debug"
  "checkpoint"
  "learn"
  "evolve"
  "safety-guard"
  "quality-gate"
)

for skill in "${required_skills[@]}"; do
  check_file "skills/${skill}/SKILL.md"
done
echo ""

# ─── Skill Format Validation ───
echo "Skill Format:"
for skill_file in skills/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Check frontmatter exists
  if ! head -1 "$skill_file" | grep -q "^---"; then
    echo -e "  ${RED}INVALID${NC}: $skill_file missing frontmatter"
    ((errors++))
    continue
  fi

  # Check required fields
  if ! grep -q "^name:" "$skill_file"; then
    echo -e "  ${RED}INVALID${NC}: $skill_file missing 'name' field"
    ((errors++))
  elif ! grep -q "^description:" "$skill_file"; then
    echo -e "  ${RED}INVALID${NC}: $skill_file missing 'description' field"
    ((errors++))
  else
    echo -e "  ${GREEN}✓${NC} $skill_name: valid format"
  fi
done
echo ""

# ─── Templates ───
echo "Templates:"
check_file "templates/config.yaml"
check_file "templates/memory/project-map.md"
check_file "templates/memory/decisions.md"
check_file "templates/memory/known-issues.md"
check_file "templates/memory/preferences.md"
check_file "templates/memory/state.md"
echo ""

# ─── Adapters ───
echo "Adapters:"
check_file "adapters/claude.sh"
check_file "adapters/cursor.sh"
check_file "adapters/codex.sh"
check_file "adapters/opencode.sh"
echo ""

# ─── Hooks ───
echo "Hooks:"
check_file "hooks/session-start.md"
check_file "hooks/pre-tool-safety.md"
echo ""

# ─── Extensions ───
echo "Extension Examples:"
check_file "extensions/auth/sso/SKILL.md"
check_file "extensions/auth/rbac/SKILL.md"
check_file "extensions/ui/theme/SKILL.md"
echo ""

# ─── Documentation ───
echo "Documentation:"
check_file "USAGE.md"
check_file "ROADMAP.md"
check_file "CONTRIBUTING.md"
echo ""

# ─── Evolution ───
echo "Evolution:"
check_file "evolution/EP-000-template.md"
echo ""

# ─── Version ───
echo "Version:"
check_file "skills/version.txt"
echo ""

# ─── Summary ───
echo "══════════════════════════════════"
if [ $errors -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed${NC} ($warnings warnings)"
  exit 0
else
  echo -e "${RED}✗ $errors errors found${NC} ($warnings warnings)"
  exit 1
fi
