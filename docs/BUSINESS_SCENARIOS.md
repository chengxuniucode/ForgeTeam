---
version: "0.1.0"
status: draft
created: 2026-07-19
updated: 2026-07-19
owner: ForgeTeam maintainers
---

# 业务研发使用场景指南

本指南面向使用 ForgeTeam 交付业务系统的开发者。`forge ...` 在终端执行；`/forge-*` 在已初始化项目的 AI 工具会话中执行。命令完整含义见 [Skill 命令详解](USAGE.md)。

## 场景索引

| 场景 | 适用条件 | 起点 |
|------|----------|------|
| [首次使用](#1-首次使用) | 第一次在某个业务项目使用 ForgeTeam | `forge init` |
| [功能迭代](#2-功能迭代) | 已有项目新增或调整业务能力 | 在 AI 会话中描述需求 |
| [原型评审后调整需求或交互](#3-原型评审后调整需求或交互) | 已生成 HTML 原型，评审后有反馈 | `/forge-html-prototype` |
| [线上 Bug](#4-线上-bug) | 生产环境出现告警、错误或业务异常 | 影响、日志与近期变更 |
| [历史项目 Bug 修复](#5-历史项目-bug-修复) | 遗留系统出现已知缺陷 | `forge onboard` + 复现信息 |
| [历史项目功能迭代](#6-历史项目功能迭代) | 遗留系统新增或调整功能 | `forge onboard` + 业务需求 |
| [测试验收](#7-测试验收) | 为关键流程实现或维护 E2E 等自动化测试 | 测试范围与关键用户流程 |

每个场景均应补充相关测试，并在交付前执行 `/forge-verify` 或 `forge verify`。`/forge-debug` 仅用于验证门禁失败后的分析与修复循环。

## 1. 首次使用

### 适用条件

第一次在一个业务项目中使用 ForgeTeam，目标是完成边界清晰的首个需求，并建立项目上下文。

### 需要提供的信息

业务目标、使用角色、功能范围、验收标准及兼容性或上线约束。

### 命令流程

```text
终端：forge init → forge onboard
  → AI 会话：描述首个业务需求
  → 方案不清：/forge-propose
  → 涉及页面或交互：/forge-html-prototype → 用户确认
  → 小改动：/forge-execute → /forge-verify → /forge-ship
  → 中大型改动：/forge-plan → /forge-execute → /forge-review
                → /forge-verify → /forge-ship
```

### 完成标准

- [ ] 已生成项目画像，首个需求具备明确验收标准。
- [ ] 相关测试与 `/forge-verify` 通过。
- [ ] 需要提交时已执行 `/forge-ship`。

### 后续指引

后续常规需求使用 [功能迭代](#2-功能迭代)；遇到遗留系统约束时使用 [历史项目功能迭代](#6-历史项目功能迭代)。

## 2. 功能迭代

### 适用条件

已有业务项目新增、调整或优化业务功能、字段、流程或规则。

### 需要提供的信息

业务目标、使用角色、涉及模块、业务规则、验收标准，以及兼容性、性能和上线约束。

### 命令流程

```text
AI 会话：描述业务需求 → ForgeTeam 自动路由
  → 小改动：/forge-execute → /forge-verify → /forge-ship
  → 中大型改动：/forge-plan → /forge-execute → /forge-review
                → /forge-verify → /forge-ship
  → 方案不明确或范围大：/forge-propose → 用户确认 → /forge-plan
  → 涉及页面或交互：/forge-html-prototype → 用户确认 → /forge-plan
```

### 完成标准

- [ ] 新增功能满足验收标准，原有行为未回归。
- [ ] 必要的测试已补充，`/forge-verify` 或 `forge verify` 通过。
- [ ] 需要提交时已执行 `/forge-ship`；该命令只提交，不推送。

### 后续指引

原型评审出现新的需求或交互反馈时，转入 [原型评审后调整需求或交互](#3-原型评审后调整需求或交互)。

## 3. 原型评审后调整需求或交互

### 适用条件

用户已查看 `prototype/{feature}/index.html`，又提出布局、字段、功能或流程反馈。

### 需要提供的信息

具体修改点、修改原因、涉及页面，以及是否改变原有业务规则或目标用户。

### 命令流程

```text
AI 会话：提交原型反馈
  → 布局或样式调整：/forge-html-prototype → 用户再次确认
  → 功能或交互变更：更新 specs/active/{slug}/proposal.md
                    → /forge-html-prototype → 用户再次确认
  → 目标、用户或核心流程重大变化：/forge-propose → 用户确认 → /forge-plan
```

### 完成标准

- [ ] 用户已确认新的原型。
- [ ] 功能或流程变更已同步到 `proposal.md` 并记录评审来源。

### 后续指引

确认后进入 `/forge-plan`，不要直接进入 `/forge-execute`。连续三轮仍未确认时，回到 `/forge-propose` 重新收敛范围。

## 4. 线上 Bug

### 适用条件

生产环境出现用户影响、核心流程不可用、数据异常或告警升级。

### 需要提供的信息

影响范围、开始时间、告警或日志摘要、请求 ID、复现条件，以及近期发布或配置变更。提供给 AI 的日志必须脱敏，不得包含密钥、凭据或完整隐私数据。

### 命令流程

```text
企业发布/运维平台：确认影响范围与等级
  → 止损：开关、回滚、限流或降级（负责人确认）
企业监控/APM/日志平台：导出时间窗口、请求 ID、错误摘要
  → AI 会话：提供脱敏证据
  → 原因不明或范围大：/forge-propose → /forge-plan
  → 有 tasks.md 时：forge tdd check specs/active/{slug}/tasks.md
  → 定位与最小修复：/forge-execute
  → 修复评审：/forge-review
     评审不通过：/forge-execute → /forge-review
  → 完整验证：/forge-verify 或 forge verify
  → 复盘沉淀：/forge-memory
     或 forge memory record issue "{问题模式、影响与解法}"
```

### 完成标准

- [ ] 业务已恢复，止损和恢复操作均有记录。
- [ ] 修复已通过 `/forge-review` 与完整验证，且补充了回归测试。
- [ ] 可复用的问题模式和解法已记录；正式事故复盘遵循团队流程。

### 后续指引

ForgeTeam 不提供通用的生产回滚、限流或日志查询命令，也不会自动执行这些高风险动作。验证门禁失败时使用 `/forge-debug`；同一问题最多三轮后等待人工决策。

## 5. 历史项目 Bug 修复

### 适用条件

维护时间较长、文档不全或上下文陌生的遗留系统出现已知缺陷。

### 需要提供的信息

复现步骤、当前结果、期望结果、相关日志、报错位置，以及兼容性约束。

### 命令流程

```text
终端：forge init → forge onboard
  → AI 会话：提交复现、当前结果、期望结果和约束
  → 范围不清：/forge-plan；复杂问题：/forge-propose
  → 有 tasks.md 时：forge tdd check specs/active/{slug}/tasks.md
  → /forge-execute：读取调用链、补充回归测试、最小修复
  → /forge-verify 或 forge verify
  → 验证失败：/forge-debug
  → 问题沉淀：/forge-memory
     或 forge memory record issue "{错误模式与解法}"
```

### 完成标准

- [ ] 问题可复现且已消除，原有行为未回归。
- [ ] 相关测试和完整验证通过。
- [ ] 非显而易见的错误模式和解法已记录到项目记忆。

### 后续指引

`forge onboard` 用于生成或刷新项目画像。代码阅读、测试编写和最小修复由 `/forge-execute` 按项目实际结构完成；若修复暴露更大的业务改造需求，转入 [历史项目功能迭代](#6-历史项目功能迭代)。

## 6. 历史项目功能迭代

### 适用条件

在遗留系统中新增业务功能，或调整既有业务流程。

### 需要提供的信息

新功能目标、既有接口/数据/权限约束、兼容性要求，以及已有测试位置。

### 命令流程

```text
终端：forge init → forge onboard
  → AI 会话：描述新功能与既有约束
  → 小范围明确需求：/forge-plan → /forge-execute → /forge-verify
  → 多模块、接口或数据变更：/forge-propose → 用户确认 → /forge-plan
                            → /forge-execute → /forge-review → /forge-verify
  → 涉及页面或交互：/forge-html-prototype → 用户确认 → /forge-plan
  → 提交：/forge-ship
```

### 完成标准

- [ ] 原有接口、数据格式和权限规则保持兼容，或已有明确迁移方案。
- [ ] 新增路径与原有路径均完成回归验证。
- [ ] `forge verify` 或 `/forge-verify` 通过，必要时已执行 `/forge-ship`。

### 后续指引

页面或交互评审反馈转入 [原型评审后调整需求或交互](#3-原型评审后调整需求或交互)。项目结构、依赖或构建方式发生明显变化时，再执行 `forge onboard` 刷新项目画像。

## 7. 测试验收

### 适用条件

测试人员需要为关键业务流程实现或维护 E2E 等自动化测试能力，并补充相应的测试资产。

### 需要提供的信息

关键用户流程、测试范围与优先级、测试环境地址、测试账号和数据准备方式、预期结果，以及需要 Mock 的外部依赖。

### 命令流程

```text
前置：项目维护者已注册 testing/e2e 扩展并生成 AI 工具配置
AI 会话：/e2e
  → 提供关键用户流程、测试数据和预期结果
  → 选择并配置 Playwright、Cypress 或 API 模式测试框架
  → 生成或完善 Page Object、E2E 用例、测试数据工厂和公共 fixture
  → 可选：生成 CI 配置及失败截图/视频留存配置
  → 使用项目生成的 E2E 运行命令执行用例并查看结果
```

`/e2e` 用于测试功能实现，具体执行方式由项目采用的 Playwright、Cypress 等测试框架决定。

### 完成标准

- [ ] 关键业务流程已覆盖为可维护的 E2E 用例，或已记录明确豁免原因。
- [ ] 测试数据、fixture 和外部依赖 Mock 可重复使用。
- [ ] 用例可由项目采用的测试框架执行；需要时已配置 CI 和失败证据留存。

### 后续指引

测试发现的产品缺陷由开发人员处理；测试范围或关键交互变化时，反馈产品和开发团队，并按 [原型评审后调整需求或交互](#3-原型评审后调整需求或交互) 重新评估。

## 持续完善本指南

新增业务场景时，在本页追加编号章节并更新顶部索引。每个场景必须使用相同的五个小节：**适用条件、需要提供的信息、命令流程、完成标准、后续指引**；命令细节统一链接到 [USAGE.md](USAGE.md)。
