---
name: learn
version: "1.0.0"
description: "从执行过程中提取经验，更新 memory"
triggers:
  - auto: "after ship"
  - auto: "after debug (if new issue solved)"
  - command: "/learn"
route_level: [standard, full]
inputs:
  - 本次执行过程
  - debug 记录 (if any)
  - 用户反馈 (if any)
outputs:
  - memory/decisions.md (追加)
  - memory/known-issues.md (追加)
  - memory/preferences.md (更新)
next: null
token_budget: 800
---

# Learn Skill

## 目标

从每次成功交付中提取可复用的经验，写入 memory 系统。
让 ForgeTeam 越用越"聪明"，避免重复犯错。

## 学习来源

### 1. 决策学习

当 plan 或 execute 阶段做了非显而易见的技术决策时：
- 选择了某个库而非另一个
- 采用了某种架构模式
- 规避了某个已知坑

→ 写入 `decisions.md`

### 2. 问题学习

当 debug 阶段解决了新问题时：
- 记录错误模式
- 记录解法
- 记录适用范围

→ 写入 `known-issues.md`

### 3. 偏好学习

当用户对输出表达了偏好时：
- "不要用 var，用 const"
- "commit message 用中文"
- "缩进用 2 空格"

→ 写入 `preferences.md`

## 执行步骤

### Step 1: 回顾本次执行

分析本次完整流程：
- 遇到了什么问题？怎么解决的？
- 做了什么决策？为什么？
- 用户有什么反馈？

### Step 2: 提取知识

判断是否有值得记录的内容：
- **新问题 + 解法** → known-issues.md
- **技术决策** → decisions.md
- **用户偏好** → preferences.md

如果本次执行完全顺利且无新知识 → 跳过，不写空内容。

### Step 3: 写入 Memory

追加格式（不覆盖已有内容）：

**decisions.md 追加**:
```markdown
---

## {date}: {决策标题}

**背景**: {context}
**选项**: {alternatives}
**决策**: {chosen approach}
**原因**: {rationale}
```

**known-issues.md 追加**:
```markdown
---

## {问题标题}

**现象**: {error pattern}
**根因**: {root cause}
**解法**: {solution}
**适用**: {when this applies}
**发现于**: {date}, {spec slug}
```

**preferences.md 更新**:
```markdown
# Team Preferences

## 代码风格
- {preference 1}
- {preference 2}

## 提交规范
- {preference}

## 工具偏好
- {preference}

## 项目特定
- {preference}
```

## 去重

写入前检查是否已存在相同/相似记录：
- known-issues: 按错误模式匹配
- decisions: 按主题匹配
- preferences: 按类别匹配

如果已存在 → 更新而非重复添加。

## 不做的事

- 不记录显而易见的事情（如"需要先 npm install"）
- 不记录过于具体的一次性问题
- 不记录与项目无关的通用知识
- 不修改 project-map.md（那是 onboard 的事）
