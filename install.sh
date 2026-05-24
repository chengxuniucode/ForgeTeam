#!/bin/bash
# ForgeTeam 一键安装脚本

set -euo pipefail

FORGE_REPO="https://github.com/chengxuninu/ForgeTeam.git"
FORGE_HOME="${FORGE_HOME:-$HOME/.forgeteam}"
FORGE_BIN="/usr/local/bin/forge"

# Color support
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# Cleanup on failure
cleanup() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo ""
    echo -e "${RED}Installation failed.${NC}"
    if [ -d "$FORGE_HOME" ] && [ ! -f "$FORGE_HOME/forge" ]; then
      echo "Cleaning up partial installation..."
      rm -rf "$FORGE_HOME"
    fi
  fi
}
trap cleanup EXIT

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║     ForgeTeam Installer               ║"
echo "║     One person, full team delivery.   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# 1. 检查依赖
echo "Checking dependencies..."
command -v git >/dev/null 2>&1 || { echo -e "${RED}Error: git is required but not installed.${NC}"; exit 1; }
command -v bash >/dev/null 2>&1 || { echo -e "${RED}Error: bash is required.${NC}"; exit 1; }
echo -e "  ${GREEN}✓${NC} git, bash available"

# 2. 克隆/更新仓库
if [ -d "$FORGE_HOME" ]; then
  echo "Updating existing installation..."
  if ! git -C "$FORGE_HOME" pull --ff-only 2>/dev/null; then
    echo -e "${YELLOW}Warning: Could not fast-forward. Backing up and reinstalling...${NC}"
    mv "$FORGE_HOME" "${FORGE_HOME}.backup.$(date '+%Y%m%d%H%M%S')"
    git clone --depth 1 "$FORGE_REPO" "$FORGE_HOME"
  fi
else
  echo "Installing to $FORGE_HOME..."
  git clone --depth 1 "$FORGE_REPO" "$FORGE_HOME"
fi
echo -e "  ${GREEN}✓${NC} Repository ready"

# 3. 安装 CLI
echo "Installing CLI..."
chmod +x "$FORGE_HOME/forge"

if [ -w "/usr/local/bin" ]; then
  ln -sf "$FORGE_HOME/forge" "$FORGE_BIN"
else
  echo ""
  echo -e "${YELLOW}Note: /usr/local/bin is not writable.${NC}"
  echo "ForgeTeam needs to create a symlink: $FORGE_BIN → $FORGE_HOME/forge"
  read -p "Allow sudo to create symlink? [Y/n] " confirm
  confirm="${confirm:-Y}"
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    sudo ln -sf "$FORGE_HOME/forge" "$FORGE_BIN"
  else
    echo ""
    echo "Skipped. You can manually add to PATH instead:"
    echo "  export PATH=\"$FORGE_HOME:\$PATH\""
    echo ""
    echo "Or create the symlink later:"
    echo "  sudo ln -sf $FORGE_HOME/forge $FORGE_BIN"
  fi
fi
echo -e "  ${GREEN}✓${NC} forge command available"

# 4. 验证安装
echo ""
echo "Verifying installation..."
if command -v forge >/dev/null 2>&1; then
  forge version
else
  "$FORGE_HOME/forge" version
fi
echo ""

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Quick start:"
echo "  cd your-project"
echo "  forge init"
echo ""
echo "Documentation: https://github.com/chengxuninu/ForgeTeam"
