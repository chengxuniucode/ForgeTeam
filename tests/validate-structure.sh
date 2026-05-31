#!/bin/bash
# ForgeTeam 项目结构验证脚本
# 验证所有必须的文件和目录是否存在且格式正确

set -euo pipefail

errors=0
warnings=0

# Color support
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' NC=''
fi

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

# Validate SKILL.md frontmatter fields
check_skill_format() {
  local skill_file="$1"
  local skill_name
  skill_name=$(basename "$(dirname "$skill_file")")
  local has_error=false

  if ! head -1 "$skill_file" | grep -q "^---"; then
    echo -e "  ${RED}INVALID${NC}: $skill_file missing frontmatter"
    ((errors++))
    return
  fi

  for field in name version description triggers; do
    if ! grep -q "^${field}:" "$skill_file"; then
      echo -e "  ${RED}INVALID${NC}: $skill_name missing '${field}' field"
      ((errors++))
      has_error=true
    fi
  done

  if [ "$has_error" = false ]; then
    echo -e "  ${GREEN}✓${NC} $skill_name: valid format"
  fi
}

# Validate extension SKILL.md (requires additional 'type' field)
check_extension_format() {
  local skill_file="$1"
  local ext_path
  ext_path=$(echo "$skill_file" | sed 's|extensions/||;s|/SKILL.md||')
  local has_error=false

  if ! head -1 "$skill_file" | grep -q "^---"; then
    echo -e "  ${RED}INVALID${NC}: $skill_file missing frontmatter"
    ((errors++))
    return
  fi

  for field in name version description type triggers; do
    if ! grep -q "^${field}:" "$skill_file"; then
      echo -e "  ${RED}INVALID${NC}: ${ext_path} missing '${field}' field"
      ((errors++))
      has_error=true
    fi
  done

  # Check type is 'extension'
  if grep -q "^type:" "$skill_file" && ! grep -q 'type: extension' "$skill_file"; then
    echo -e "  ${YELLOW}WARN${NC}: ${ext_path} type is not 'extension'"
    ((warnings++))
  fi

  if [ "$has_error" = false ]; then
    echo -e "  ${GREEN}✓${NC} ${ext_path}: valid format"
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
echo "Skills (10 required):"
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
  "memory"
  "evolve"
)

for skill in "${required_skills[@]}"; do
  check_file "skills/${skill}/SKILL.md"
done
echo ""

# ─── Skill Format Validation ───
echo "Skill Format:"
for skill_file in skills/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  check_skill_format "$skill_file"
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
check_file "adapters/windsurf.sh"
echo ""

# ─── Registry ───
echo "Registry:"
check_file "registry/official.yaml"
echo ""

# ─── Hooks ───
echo "Hooks:"
check_file "hooks/session-start.md"
check_file "hooks/pre-tool-safety.md"
echo ""

# ─── Extensions ───
echo "Extensions:"
required_extensions=(
  "extensions/auth/sso/SKILL.md"
  "extensions/auth/rbac/SKILL.md"
  "extensions/ui/theme/SKILL.md"
  "extensions/deploy/k8s/SKILL.md"
  "extensions/data/migration/SKILL.md"
  "extensions/integration/mq/SKILL.md"
  "extensions/monitoring/logging/SKILL.md"
  "extensions/testing/e2e/SKILL.md"
)

for ext in "${required_extensions[@]}"; do
  check_file "$ext"
done
echo ""

# ─── Extension Format Validation ───
echo "Extension Format:"
for ext_file in extensions/*/*/SKILL.md; do
  [ -f "$ext_file" ] || continue
  check_extension_format "$ext_file"
done
echo ""

# ─── Tests ───
echo "Tests:"
check_file "tests/validate-structure.sh"
check_file "tests/test-init.sh"
check_file "tests/test-verify.sh"
check_file "tests/test-generate.sh"
check_file "tests/test-doctor.sh"
echo ""

# ─── Documentation ───
echo "Documentation:"
check_file "docs/USAGE.md"
check_file "docs/ROADMAP.md"
check_file "docs/CONTRIBUTING.md"
echo ""

# ─── Evolution ───
echo "Evolution:"
check_file "evolution/EP-000-template.md"
echo ""

# ─── Version ───
echo "Version:"
check_file "skills/version.txt"
echo ""

# ─── Syntax Check ───
echo "Syntax:"
if bash -n forge 2>/dev/null; then
  echo -e "  ${GREEN}✓${NC} forge: valid bash syntax"
else
  echo -e "  ${RED}INVALID${NC}: forge has syntax errors"
  ((errors++))
fi
if bash -n install.sh 2>/dev/null; then
  echo -e "  ${GREEN}✓${NC} install.sh: valid bash syntax"
else
  echo -e "  ${RED}INVALID${NC}: install.sh has syntax errors"
  ((errors++))
fi
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
