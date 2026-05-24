---
name: checkpoint
version: "1.0.0"
description: "会话保存与恢复，支持跨会话持续工作"
triggers:
  - auto: "session_end OR context_90_percent"
  - command: "/checkpoint"
route_level: [micro, standard, full]
inputs:
  - 当前会话状态
  - specs/active/{slug}/tasks.md
outputs:
  - .forgeteam/memory/state.md (更新)
  - checkpoint commit (可选)
next: null (会话结束) | resume (下次会话)
token_budget: 500
constraints:
  must:
    - "保存 state.md 记录当前进度"
  should:
    - "保存关键决策到 decisions.md"
---

# Checkpoint Skill

## 目标

在会话即将结束或上下文窗口接近容量时，保存当前进度。
下次会话可以从断点恢复，不丢失上下文。

## 触发时机

1. **手动触发**: 用户执行 `/checkpoint`
2. **上下文预警**: 当上下文使用超过 90% 时自动触发
3. **会话结束**: 用户要离开时触发
4. **长时间无响应**: 超过设定时间无输入时触发

## 执行步骤

### Step 1: 收集当前状态

```yaml
snapshot:
  timestamp: "{ISO datetime}"
  session_duration: "{minutes}"

  active_spec: "{slug or null}"
  route_level: "{micro|standard|full}"
  current_phase: "{propose|plan|execute|review|verify|ship}"

  progress:
    total_tasks: N
    completed_tasks: M
    current_task: "{task description}"
    current_task_status: "{not-started|in-progress|blocked}"

  context:
    last_action: "{what was just done}"
    next_action: "{what should happen next}"
    blockers: ["{any blocking issues}"]
    decisions_made: ["{key decisions this session}"]

  files_modified:
    - "{file path 1}"
    - "{file path 2}"

  uncommitted_changes: true|false
```

### Step 2: 更新 state.md

写入 `.forgeteam/memory/state.md`：

```markdown
# Current State

## 快照
- 时间: {timestamp}
- 会话时长: {duration}

## 任务进度
- Spec: {slug}
- 路由: {route_level}
- 阶段: {phase}
- 进度: {M}/{N} tasks
- 当前: {current task description}

## 上下文
- 上一步: {last_action}
- 下一步: {next_action}
- 阻塞: {blockers or "无"}

## 本次决策
{decisions made during this session}

## 未提交变更
{list of uncommitted files, or "无"}

## 恢复指令
1. 读取本文件了解上下文
2. 读取 specs/active/{slug}/tasks.md 了解完整任务
3. 从 Task {N} 继续执行
4. {specific instructions for next session}
```

### Step 3: 可选 WIP Commit

如果有未提交的变更且已通过编译：
```bash
git add -A
git commit -m "wip: checkpoint - {current task description}"
```

如果未通过编译则不 commit，只记录状态。

## 恢复流程

下次会话开始时（由 session-start hook 触发）：

```
1. 检测到 state.md 存在且有活跃任务
2. 输出恢复摘要给用户
3. 问用户："继续上次的任务？[Y/n]"
4. Y → 加载上下文，从断点继续
5. n → 清除 state.md，等待新指令
```

## 不做的事

- 不尝试序列化整个对话历史
- 不保存大段代码到 state.md（只引用文件路径）
- 不在每个操作后都写 checkpoint（只在关键节点）
