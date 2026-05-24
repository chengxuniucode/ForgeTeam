---
name: memory
version: "1.0.0"
description: "跨会话记忆管理：保存进度 + 提取经验"
triggers:
  - auto: "session_end OR context_90_percent"
  - auto: "after ship"
  - auto: "after debug (if new issue solved)"
  - command: "/memory"
route_level: [micro, standard, full]
inputs:
  - 当前会话状态
  - specs/active/{slug}/tasks.md
  - 本次执行过程
  - debug 记录 (if any)
  - 用户反馈 (if any)
outputs:
  - .forgeteam/memory/state.md (更新)
  - memory/decisions.md (追加)
  - memory/known-issues.md (追加)
  - memory/preferences.md (更新)
  - checkpoint commit (可选)
next: null
token_budget: 800
constraints:
  must:
    - "保存 state.md 记录当前进度"
    - "去重检查后再写入 memory"
  should:
    - "提取非显而易见的经验"
    - "不记录通用常识"
---

# Memory Skill

## 目标

统一管理跨会话记忆：保存当前进度（以便下次恢复）+ 提取可复用经验（让框架越用越聪明）。

## 触发时机

1. **会话结束** — 保存进度快照
2. **ship 之后** — 提取本次交付的经验
3. **debug 解决新问题后** — 记录错误模式和解法
4. **用户手动** — `/memory`

## Part 1: 进度保存（原 checkpoint）

### 收集当前状态

```yaml
snapshot:
  timestamp: "{ISO datetime}"
  active_spec: "{slug or null}"
  route_level: "{micro|standard|full}"
  current_phase: "{propose|plan|execute|review|verify|ship}"
  progress:
    total_tasks: N
    completed_tasks: M
    current_task: "{task description}"
  context:
    last_action: "{what was just done}"
    next_action: "{what should happen next}"
    blockers: ["{any blocking issues}"]
  files_modified: ["{file paths}"]
  uncommitted_changes: true|false
```

### 写入 state.md

```markdown
# Current State

## 快照
- 时间: {timestamp}
- Spec: {slug}
- 路由: {route_level}
- 阶段: {phase}
- 进度: {M}/{N} tasks
- 当前: {current task}

## 上下文
- 上一步: {last_action}
- 下一步: {next_action}
- 阻塞: {blockers or "无"}

## 恢复指令
1. 读取本文件了解上下文
2. 读取 specs/active/{slug}/tasks.md 了解完整任务
3. 从 Task {N} 继续执行
```

### 可选 WIP Commit

如果有未提交的变更且已通过编译：
```bash
git add -A
git commit -m "wip: checkpoint - {current task description}"
```

## Part 2: 经验提取（原 learn）

### 学习来源

1. **决策学习** — 非显而易见的技术决策 → `decisions.md`
2. **问题学习** — debug 解决的新问题 → `known-issues.md`
3. **偏好学习** — 用户表达的风格偏好 → `preferences.md`

### 写入格式

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
按类别（代码风格/提交规范/工具偏好/项目特定）组织。

### 去重规则

写入前检查是否已存在相同/相似记录：
- known-issues: 按错误模式匹配
- decisions: 按主题匹配
- preferences: 按类别匹配

如果已存在 → 更新而非重复添加。

## 不做的事

- 不序列化整个对话历史
- 不保存大段代码到 state.md（只引用文件路径）
- 不记录显而易见的事情（如"需要先 npm install"）
- 不记录过于具体的一次性问题
- 不修改 project-map.md（那是 onboard 的事）

## 恢复流程

下次会话开始时（由 session-start hook 触发）：
1. 检测到 state.md 存在且有活跃任务
2. 输出恢复摘要给用户
3. 问用户："继续上次的任务？[Y/n]"
4. Y → 加载上下文，从断点继续
5. n → 清除 state.md，等待新指令
