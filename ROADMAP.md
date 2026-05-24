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
| 人类监督模式演进 | 断路器不再是唯一方式 | 升级 safety-guard 策略 |

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
| 供应链安全自动化 | 依赖审计可 AI 化 | safety-guard 增强 |
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

### 机制一：`forge evolve` 命令（规划中）

```bash
forge evolve
# 自动扫描:
#   1. 检查 GitHub trending (AI coding 相关)
#   2. 检查已关注项目的 release notes
#   3. 分析社区 issues 中的 feature requests
#   4. 对比当前 skill 能力 vs 生态趋势
# 输出:
#   - evolution-report.md (进化建议报告)
#   - 建议新增/升级的 skill 列表
#   - 建议关注的新方向
```

### 机制二：Learn → Evolve 闭环

```
用户日常使用 ForgeTeam
        │
        ├── learn skill 记录决策和问题
        ├── debug 记录修复模式
        ├── checkpoint 记录中断原因
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

当前版本：**1.0.0**

### 发布节奏

| 类型 | 频率 | 驱动力 |
|------|------|--------|
| patch | 按需 | bug / 文档 |
| minor | 每月 | 进化融合 / 社区贡献 |
| major | 每季度 | 架构级进化 |

---

## Roadmap 路线图

### v1.1 — 基础进化能力

- [ ] **`forge evolve` 命令** — 进化建议报告生成
- [ ] **`forge add` 命令** — 一键安装社区/企业扩展包
- [ ] **Evolution Proposal 模板** — 结构化进化提案机制
- [ ] **Parallel Execute** — 同一 Wave 内多 task 真并行
- [ ] **Config Validation** — `forge doctor` 检查配置健康度
- [ ] **Adapter: Windsurf** — 新增 Windsurf 平台适配

### v1.2 — 智能进化

- [ ] **Usage Analytics（本地）** — 统计 skill 使用率、跳过率、断路器触发率
- [ ] **Adaptive Routing** — 基于历史数据自动调整路由阈值
- [ ] **Spec Format v2** — 可扩展的结构化 spec，支持自动验收
- [ ] **Memory Search** — 记忆系统支持语义检索
- [ ] **Multi-Agent Mode** — 多 skill 并行协作
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
| — | — | （后续进化记录于此追加） | — |

---

## 如何参与进化

1. **提交 Evolution Proposal** — 发现新方向时，按模板提交 EP
2. **贡献 Extension** — 将新技术方向转化为具体 skill
3. **反馈使用数据** — 哪些 skill 好用、哪些该废弃
4. **挑战进化红线** — 如果某条红线阻碍了真正的进步，可以发起讨论

见 [CONTRIBUTING.md](CONTRIBUTING.md)
