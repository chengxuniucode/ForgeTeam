# Evolution Report — 2026-05-31

## 扫描范围
- 时间窗口: v1.0.0 发布 → 2026-05-31
- 信息源: AI 编码工具 Release Notes / 协议生态 / 社区实践 / 项目自身使用反馈

## 发现信号: 7 个

### 信号 1: Claude Code Agent SDK 与 Hooks 系统成熟
- 来源: Anthropic Claude Code SDK / Hooks API
- 方向: agent 编排 / 工具协议
- 时效性: 中期趋势（已落地，持续演进）
- 与 ForgeTeam 相关度: **高**
- 详情: Claude Code 已支持 subagent 编排、PreToolUse/PostToolUse hooks、session continuity。ForgeTeam 的 skill 可以通过 hooks 实现更深度的自动化触发，而非仅靠用户手动调用 slash command。

### 信号 2: MCP 协议生态爆发
- 来源: Model Context Protocol 生态
- 方向: 协议 / 基础设施
- 时效性: 长期方向（已成事实标准）
- 与 ForgeTeam 相关度: **高**
- 详情: MCP Server 已成为 AI 工具连接外部系统的标准方式。ForgeTeam 的 `extensions.mcp_servers` 规划需加速落地，企业扩展场景（Jira、GitLab、内部 API）均可通过 MCP 接入。

### 信号 3: 多 AI 编码工具并存格局确立
- 来源: Windsurf / Augment / Devin / Copilot Workspace / Codex CLI
- 方向: 平台适配
- 时效性: 长期方向
- 与 ForgeTeam 相关度: **高**
- 详情: 市场已形成 Claude Code / Cursor / Codex / Windsurf / Augment 多强并存格局。ForgeTeam 的 "平台无关" 定位价值凸显，但 adapter 覆盖需要扩展（Windsurf 已在 v1.1 roadmap 中）。

### 信号 4: 国际化与社区扩展需求
- 来源: 项目自身（刚完成英文 README）
- 方向: 开发者工作流 / 社区
- 时效性: 短期需求
- 与 ForgeTeam 相关度: **高**
- 详情: ForgeTeam 刚新增英文 README，说明面向国际开发者的意图已明确。Skill 文件、文档、CLI 提示信息的 i18n 是下一步自然延伸。

### 信号 5: Agentic Workflow 从单步到长链路自主
- 来源: Claude Code autonomous mode / Devin / OpenAI Codex agent
- 方向: agent 编排 / 自主执行
- 时效性: 中期趋势
- 与 ForgeTeam 相关度: **中**
- 详情: AI agent 可自主完成越来越长的任务链路（数百步）。ForgeTeam 的 Micro/Standard/Full 路由边界可能需要重新校准——以前认为 "500行以上需要 Full 路由" 的阈值可以上调。但断路器机制仍是差异化优势。

### 信号 6: 结构化项目上下文成为标准实践
- 来源: CLAUDE.md / DESIGN.md / .cursor/rules / AGENTS.md
- 方向: 上下文与记忆
- 时效性: 已成事实标准
- 与 ForgeTeam 相关度: **中**
- 详情: 几乎所有 AI 编码工具都引入了项目级配置文件。ForgeTeam 的 `forge generate` 已覆盖主流格式，但 DESIGN.md（设计系统上下文）和 .github/copilot-instructions.md 等新格式待评估。

### 信号 7: 本地使用分析与自适应
- 来源: 行业趋势 / ForgeTeam roadmap v1.2
- 方向: 质量与安全 / 自进化
- 时效性: 中期趋势
- 与 ForgeTeam 相关度: **中**
- 详情: skill 跳过率、断路器触发频率、任务完成时间等度量数据，可驱动路由阈值和 skill 流程的自动调优。目前 v1.2 已规划但未实现。

---

## 建议动作

### 立即融合 (2 项)

1. **i18n 基础设施** → 英文 README 已就绪，下一步为 CLI 输出和核心文档建立双语机制 → 排入 v1.0.1 patch
2. **Hooks 深度集成** → 为 Claude Code adapter 生成 hooks 配置（session-start 自动加载 skill context） → 建议生成 EP-002

### 规划融合 (3 项)

1. **MCP Server 配置生成** → `forge generate` 支持生成 `.claude/settings.json` 中的 MCP server 配置 → 排入 v1.1
2. **Windsurf Adapter** → 新增 Windsurf 平台适配器 → 排入 v1.1（已在 roadmap）
3. **路由阈值动态调整** → 基于 AI 能力增长，Micro 边界从 50 行上调到 80-100 行 → 排入 v1.2，需 usage data 验证

### 持续观察 (1 项)

1. **全自主模式 (Autonomous Mode)** → AI agent 自主能力仍在快速演进，但 ForgeTeam 的断路器是核心安全保障，不宜过早放开 → 观察 6 个月后再评估

### 明确拒绝 (1 项)

1. **引入 Node.js 运行时** → 有社区建议用 Node 替代 Shell 实现 CLI，提升跨平台能力 → **拒绝**：违反"纯文本架构"和"零依赖"进化红线

---

## 本期进化健康度

- 核心 skill 稳定度: **有优化**（14→10 精简完成，架构更清晰）
- Extension 活跃度: 新增 0 / 更新 0 / 废弃 0（awaiting community）
- 社区贡献: PR 0 / Issues 0 / EP 1（项目刚发布）
- 用户反馈趋势: **中性**（项目处于早期推广阶段）

---

## 版本建议

基于本次评估，建议近期版本节奏：

| 版本 | 内容 | 预计时间 |
|------|------|---------|
| v1.0.1 | 英文 README + 文档优化 | 本周 |
| v1.1.0 | Windsurf adapter + MCP 配置生成 + hooks 集成 + `forge evolve` 基础版 | 2026-06 |
| v1.2.0 | Usage analytics + adaptive routing + memory search | 2026-Q3 |
