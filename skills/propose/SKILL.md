---
name: propose
version: "1.0.0"
description: "需求澄清与方案选型，生成 proposal.md"
triggers:
  - auto: "route_level == full"
  - command: "/propose"
route_level: [full]
inputs:
  - user_request
  - memory/project-map.md
  - memory/decisions.md
outputs:
  - specs/active/{slug}/proposal.md
next: plan
token_budget: 2000
constraints:
  must:
    - "生成 proposal.md"
    - "等待用户确认后再进入 plan"
  should:
    - "加载 decisions.md 了解历史决策"
---

# Propose Skill

## 目标

将用户的模糊需求转化为清晰的 proposal，确认方向后再进入 plan 阶段。
避免"没想清楚就开始写代码"的常见浪费。

## 执行步骤

### Step 1: 需求澄清

分析用户请求，提取：
- **What**: 用户想要什么功能/变更
- **Why**: 业务背景和动机
- **Who**: 影响哪些用户/系统
- **Scope**: 边界在哪里（做什么、不做什么）

如果信息不足，向用户提问（最多 3 个关键问题）。

### Step 2: 上下文加载

读取以下文件获取项目背景：
- `.forgeteam/memory/project-map.md` — 了解项目结构
- `.forgeteam/memory/decisions.md` — 了解历史决策
- `.forgeteam/memory/known-issues.md` — 避免重蹈覆辙

### Step 3: 方案选型

列出 2-3 个可行方案，每个方案说明：
- 实现方式概述
- 优点
- 缺点/风险
- 预估工作量（S/M/L/XL）

推荐一个方案并说明理由。

### Step 4: 生成 Proposal

创建 `specs/active/{slug}/proposal.md`：

```markdown
# Proposal: {title}

## 需求描述
{what + why + who}

## 范围
### In Scope
- ...

### Out of Scope
- ...

## 方案选型

### 方案 A: {名称}
{描述、优缺点}

### 方案 B: {名称}
{描述、优缺点}

## 推荐方案
方案 {X}，理由：{...}

## 预估
- 工作量: {S/M/L/XL}
- 影响文件数: {N}
- 风险等级: {Low/Medium/High}

## 待确认
- [ ] {需要用户确认的点}
```

### Step 5: 等待确认

将 proposal 呈现给用户，等待确认或调整。
用户确认后，自动触发 `plan` skill。

## 断路器

- 如果用户连续 3 次说"不对"或"重来"，暂停并直接问："请告诉我你具体想要什么"
- 不要在 propose 阶段写任何代码

## 跳过条件

- `route_level == micro` → 跳过，直接 execute
- `route_level == standard` → 跳过，直接 plan
- 用户显式说"直接开始"或"不用讨论" → 跳过
