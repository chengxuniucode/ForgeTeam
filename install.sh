#!/bin/bash
# ForgeTeam 一键安装脚本

set -euo pipefail

FORGE_REPO="https://github.com/chengxuninu/ForgeTeam.git"
FORGE_HOME="${FORGE_HOME:-$HOME/.forgeteam}"
FORGE_BIN="/usr/local/bin/forge"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║     ForgeTeam Installer               ║"
echo "║     One person, full team delivery.   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# 1. 检查依赖
echo "Checking dependencies..."
command -v git >/dev/null 2>&1 || { echo "git required"; exit 1; }
command -v bash >/dev/null 2>&1 || { echo "bash required"; exit 1; }
echo -e "  ${GREEN}✓${NC} git, bash available"

# 2. 克隆/更新仓库
if [ -d "$FORGE_HOME" ]; then
  echo "Updating existing installation..."
  git -C "$FORGE_HOME" pull --ff-only 2>/dev/null || true
else
  echo "Installing to $FORGE_HOME..."
  git clone --depth 1 "$FORGE_REPO" "$FORGE_HOME"
fi
echo -e "  ${GREEN}✓${NC} Repository ready"

# 3. 安装 CLI
echo "Installing CLI..."
if [ -w "/usr/local/bin" ]; then
  ln -sf "$FORGE_HOME/forge" "$FORGE_BIN"
else
  sudo ln -sf "$FORGE_HOME/forge" "$FORGE_BIN"
fi
chmod +x "$FORGE_HOME/forge"
echo -e "  ${GREEN}✓${NC} forge command available"

# 4. 验证安装
echo ""
echo "Verifying installation..."
"$FORGE_BIN" version
echo ""

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Quick start:"
echo "  cd your-project"
echo "  forge init"
echo ""
echo "Documentation: https://github.com/chengxuninu/ForgeTeam"
