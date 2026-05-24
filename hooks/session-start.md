# ForgeTeam Session Start Hook

## 触发时机

每次 AI 会话开始时自动执行。

## 执行内容

```bash
#!/bin/bash
# ForgeTeam Session Start Hook

echo "=== ForgeTeam Session Start ==="

# 1. 加载记忆
if [ -d ".forgeteam/memory" ]; then
  echo "[Memory] Loading project context..."
  cat .forgeteam/memory/project-map.md 2>/dev/null
  cat .forgeteam/memory/state.md 2>/dev/null
  cat .forgeteam/memory/preferences.md 2>/dev/null
fi

# 2. 检查活跃 spec
if [ -d "specs/active" ]; then
  ACTIVE=$(ls specs/active/ 2>/dev/null | head -5)
  if [ -n "$ACTIVE" ]; then
    echo "[Specs] Active specs found:"
    echo "$ACTIVE"
  fi
fi

# 3. 加载配置
if [ -f ".forgeteam/config.yaml" ]; then
  echo "[Config] Project configuration loaded"
fi

# 4. 检测项目类型
if [ -f "package.json" ]; then
  echo "[Detect] Node.js project"
elif [ -f "pom.xml" ]; then
  echo "[Detect] Java/Maven project"
elif [ -f "go.mod" ]; then
  echo "[Detect] Go project"
elif [ -f "Cargo.toml" ]; then
  echo "[Detect] Rust project"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "[Detect] Python project"
fi

echo "=== Ready ==="
```

## 恢复检测

如果 state.md 中有活跃任务：
1. 输出恢复摘要
2. 提示用户是否继续上次的工作
3. 加载相关 spec 文件
