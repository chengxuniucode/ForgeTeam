# ForgeTeam Roadmap

> 核心理念：**ForgeTeam 是一个自进化系统。** 不依赖对特定项目的跟踪，而是持续感知 AI 编码生态的技术方向，主动学习、吸收、融合，使自身不断演进。

---

## 进化哲学

### ForgeTeam 不是静态框架

传统开源项目的迭代模式是"维护者追踪上游 → 手动搬运功能"。ForgeTeam 拒绝这种模式。

ForgeTeam 的进化是**内生的**——它通过自己的 `learn` skill 积累经验，通过 `evolve` 机制感知生态变化，通过社区反馈驱动架构演进。

```
┌────────────────────────────────────────────────────────────┐
│                   ForgeTeam 自进化循环                       │
│                                                            │
│     感知 (Sense)                                           │
│       ├── AI 编码工具新范式（agent / workflow / context）    │
│       ├── 开发者工作流新趋势（spec-driven / test-first）    │
│       ├── 基础设施新方向（MCP / A2A / tool-use 协议）       │
│       └── 社区实践反馈（哪些 skill 常跳过？哪些断路器常触发？）│
│                    │                                       │
│                    ▼                                       │
│     评估 (Evaluate)                                        │
│       ├── 这解决了什么真实痛点？                             │
│       ├── ForgeTeam 当前是否有此短板？                       │
│       ├── 融合代价（复杂度 vs 收益）可接受？                  │
│       └── 是否符合"纯 Markdown + Shell"的架构约束？          │
│                    │                                       │
│                    ▼                                       │
│     融合 (Absorb)                                          │
│       ├── 思想级 → 转化为 ForgeTeam 原生 skill 表达         │
│       ├── 模式级 → 新 extension / 新 template / 新 hook     │
│       ├── 协议级 → adapter 升级 / 新平台支持                │
│       └── 架构级 → core skill 演进（慎重，需 RFC）          │
│                    │                                       │
│                    ▼                                       │
│     验证 (Validate)                                        │
│       ├── 是否让用户更快交付？                              │
│       ├── 是否降低了认知负担？                              │
│       ├── 是否保持了"one person, full team"的承诺？         │
│       └── 是否向后兼容？                                   │
│                    │                                       │
│                    ▼                                       │
│     沉淀 (Codify)                                          │
│       ├── 写入 skills/ 或 extensions/                      │
│       ├── 更新 skills/ 和 templates/                       │
│       ├── 发布新版本                                       │
│       └── 回到感知阶段 ↺                                   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 进化雷达

ForgeTeam 持续关注以下**技术方向**（不是特定项目），当任何方向出现突破性进展时，触发进化评估。

### 方向一：AI Agent 编排

| 信号 | 含义 | 融合方式 |
|------|------|---------|
| 多 Agent 协作成为主流 | 单 agent 不够，需要分工 | 升级 routing 支持多 skill 并行 |
| Agent-to-Agent 协议成熟 | 工具间可互操作 | 新增 A2A adapter |
| 自主执行能力增强 | AI 可完成更长链路 | 扩大 micro/standard 路由边界 |
| 人类监督模式演进 | 断路器不再是唯一方式 | 升级 verify safety guard 策略 |

### 方向二：开发者工作流

| 信号 | 含义 | 融合方式 |
|------|------|---------|
| Spec-driven 成为标准 | 先定义再实现 | spec 格式标准化 |
| 自动验收测试生成 | spec → test 直接转化 | verify skill 增强 |
| 增量式开发范式 | 小步验证成为共识 | Wave 粒度自适应 |
| 全栈脚手架自动化 | 零配置启动项目 | scaffold extension |

### 方向三：上下文与记忆

| 信号 | 含义 | 融合方式 |
|------|------|---------|
| 长上下文窗口突破 | 可放入更多项目背景 | onboard skill 升级 |
| 持久化记忆方案成熟 | 跨会话不再丢失 | memory 系统增强 |
| 语义检索成主流 | 精准找到相关历史 | memory search |
| 多模态输入 | 图片/设计稿可理解 | propose skill 支持视觉输入 |

### 方向四：质量与安全

| 信号 | 含义 | 融合方式 |
|------|------|---------|
| AI 生成代码漏洞率数据 | 行业有可量化标准 | verify safety gate 校准 |
| 形式化验证工具普及 | 可做数学级证明 | 新 gate 或 extension |
| 供应链安全自动化 | 依赖审计可 AI 化 | verify safety guard 增强 |
| 代码审计 AI 成熟 | 超越 lint 级别检查 | review skill 增强 |

### 方向五：协议与基础设施

| 信号 | 含义 | 融合方式 |
|------|------|---------|
| MCP 协议版本升级 | 工具调用能力增强 | mcp.json 格式升级 |
| 新 AI 编码工具出现 | 市场出现有力工具 | 新增 adapter |
| IDE 原生 AI 集成深化 | 不再需要外挂 | adapter 策略调整 |
| 开发环境容器化 | dev container 成标准 | execute 沙箱模式 |

---

## 自进化机制

### 机制一：`forge evolve` 命令（已实现）

```bash
forge evolve
# 本地收集:
#   1. 版本与上游缓存状态
#   2. active / archived spec、扩展和 EP 状态
#   3. safety / gates 日志与本地 analytics 事件
# 输出:
#   - evolution/evolution-report-<日期>.md
#   - 无样本时的明确采集引导

# 将报告结论转为人工评审的 EP（不自动修改代码）
forge evolve --create-ep <title>
```

> 外部生态扫描由 `/forge-evolve` skill 在人工会话中完成；CLI 保持离线、只处理本地可复核信号。

### 机制二：Learn → Evolve 闭环

```
用户日常使用 ForgeTeam
        │
        ├── memory skill 记录决策和问题
        ├── debug 记录修复模式
        ├── memory 记录中断原因
        └── 用户 feedback (GitHub Issues)
        │
        ▼
积累数据 → 发现模式
        │
        ├── "80% 用户跳过 propose" → propose 流程需简化
        ├── "Java 项目 debug 频率 3x 于 TS" → Java verify 需增强
        ├── "deploy 扩展请求最多" → deploy 类目优先扩展
        └── "新 AI 工具 X 社区呼声高" → 评估新 adapter
        │
        ▼
进化决策 → 版本迭代
```

### 机制三：社区驱动进化

```
进化提案 (Evolution Proposal)
        │
        ▼
模板: evolution/EP-{NNN}-{title}.md
        │
        ├── 触发信号: 什么外部变化触发了这个提案
        ├── 当前短板: ForgeTeam 缺什么
        ├── 融合方案: 怎么做，落在哪
        ├── 验证标准: 怎么证明成功
        └── 兼容影响: 对现有用户的影响
```

---

## 进化红线

进化不是无限制的扩张。以下是 ForgeTeam 的**不变量**：

1. **纯文本架构** — 永远是 Shell + Markdown，不引入编译依赖
2. **一个人能用** — 不要求团队配合才能跑起来
3. **3 分钟上手** — 核心流程对新人透明
4. **离线可用** — 不强制依赖云服务
5. **平台无关** — 不绑定任何一个 AI 工具
6. **人类最终决策** — 断路器永远存在，自主不代表失控

任何进化提案违反以上任何一条 → 自动否决。

---

## 版本策略

```
major.minor.patch

major — 核心 skill 接口变更、config 结构 breaking change
minor — 新 skill、新 extension 类目、新 adapter、进化融合
patch — bug 修复、现有 skill 优化、文档完善
```

当前发布版本：**v1.2.1**。

### 发布节奏

| 类型 | 频率 | 驱动力 |
|------|------|--------|
| patch | 按需 | bug / 文档 |
| minor | 每月 | 进化融合 / 社区贡献 |
| major | 每季度 | 架构级进化 |

---

## Roadmap 路线图

### v1.1 — 基础进化能力 ✓

- [x] **`forge evolve` 命令** — 本地信号收集 + 进化建议报告生成
- [x] **`forge add` 命令** — 一键安装社区/企业扩展包（Git/本地/Registry）
- [x] **Evolution Proposal 管理** — `forge ep create/list/status` 自动化 EP 生命周期
- [x] **Parallel Execute** — tasks.md `parallel:` 声明语法 + execute skill 升级
- [x] **Config Validation** — `forge doctor` 5 项健康检查 + 修复建议
- [x] **Adapter: Windsurf** — 新增 Windsurf 平台适配

### v1.2 — 可观测与可恢复工作流（实施中）

- [x] **Usage Analytics（本地）** — `forge analytics event` 写入最小化 JSONL；`forge evolve report` 汇总事件、质量与 EP 信号
- [x] **Workflow State & Approval** — `forge state show/transition/approve` 记录状态和人工计划批准
- [x] **Task Index & Workspace Registry** — `forge index rebuild`、`forge workspace add/list` 支持本地恢复和显式多仓根目录
- [x] **Checkpoint / Worktree** — `forge checkpoint` 与可选 `forge worktree` 提供可恢复、隔离的 Git 工作流
- [x] **Test-first Contract** — `forge tdd check` 和 plan/execute skill 要求测试先行或明确豁免
- [x] **Delta Spec Archive** — `forge spec archive` 保留 ADDED/MODIFIED/REMOVED 增量历史
- [x] **Portable Extension Bundle** — manifest 模板、`forge bundle validate/export`
- [x] **Evidence-shaped Memory** — `forge memory record/prune` 与证据字段约定
- [ ] **Adaptive Routing** — 需积累真实样本后再调整阈值；当前不基于无样本数据自动调参
- [ ] **Memory Search** — 保持离线前提下评估轻量索引/检索方案
- [ ] **Multi-Agent Mode** — 保持为可选协作策略，不成为基础流程依赖
- [ ] **Scaffold Skill** — 全栈脚手架自动生成

### v1.3 — 生态进化

- [ ] **Extension Marketplace** — 社区扩展发现和安装
- [ ] **Team Mode** — 多人协作，skill 按角色分配
- [ ] **Plugin API** — 第三方通过 API 扩展能力
- [ ] **Cross-Tool Interop** — AI 工具间任务传递
- [ ] **IDE Extension** — VS Code / JetBrains 原生集成

### v2.0 — 自主进化

- [ ] **Self-Improve** — 基于 learn 数据自动优化 skill 执行策略
- [ ] **Spec-as-Code** — spec 编译为可执行验收测试
- [ ] **Autonomous Mode** — 人类只在断路器和进化决策时介入
- [ ] **Cross-Project Memory** — 跨项目知识共享
- [ ] **Evolution Bot** — 自动生成进化提案并提交 PR

---

## 升级兼容保障

### 对用户的承诺

1. **patch 升级零影响** — `forge sync` 无感更新
2. **minor 升级向后兼容** — 新 skill 不影响已有工作流
3. **major 升级有迁移指南** — 提供 `forge migrate` 命令或文档
4. **本地修改永远不丢失** — `.local-modified` 标记保护

### 升级流程

```bash
# 日常同步
forge sync
# → 自动拉取、跳过本地修改的 skill、重新 generate

# Major 版本
forge sync
# → "⚠️ Major version change (1.x → 2.x)"
# → 显示 changelog + breaking changes
# → 用户确认后迁移
```

---

## 进化日志

> 记录每次重大进化决策，便于追溯。

| 日期 | 版本 | 进化内容 | 触发信号 |
|------|------|---------|---------|
| 2024-01 | v1.0.0 | 初始发布 | — |
| 2026-05 | v1.0.1 | 英文 README + 进化报告机制首次执行 | 国际化需求 + evolve skill 落地 |
| 2026-05 | v1.1.0 | 基础进化能力：evolve CLI / add / ep / parallel / doctor / windsurf | EP-001 落地 + 社区扩展需求 |
| 2026-07 | v1.2.0 | 本地可观测与可恢复工作流：analytics、state、index、workspace、checkpoint、worktree、TDD、delta spec、bundle、memory | EP-002 + 生态对标结论 |
| 2026-07 | v1.2.1 | 业务研发场景指南：首次使用、功能迭代、原型调整、线上与历史项目缺陷处理、测试自动化指引 | 业务使用路径与测试角色指引需求 |

---

## 如何参与进化

1. **提交 Evolution Proposal** — 发现新方向时，按模板提交 EP
2. **贡献 Extension** — 将新技术方向转化为具体 skill
3. **反馈使用数据** — 哪些 skill 好用、哪些该废弃
4. **挑战进化红线** — 如果某条红线阻碍了真正的进步，可以发起讨论

见 [CONTRIBUTING.md](CONTRIBUTING.md)
