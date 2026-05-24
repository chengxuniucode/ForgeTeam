# EP-001: 自进化机制

> 状态: accepted
> 创建: 2024-01-15
> 作者: ForgeTeam Core

---

## 触发信号

AI 编码工具生态在 2024 年进入爆发期，每周都有新工具、新范式、新协议出现。传统"盯着几个上游项目手动搬运"的模式无法持续。

- 观察到的技术趋势：AI agent 生态从单点工具走向协议互操作
- 来源：MCP 协议发布、A2A 讨论、多家 AI IDE 同时涌现
- 时效性判断：长期趋势，不是短期热点

## 当前短板

- ForgeTeam v1.0 只有 `forge sync` 从固定上游拉取更新
- 没有结构化的方式发现和评估新技术方向
- 没有从用户使用数据中自动发现改进机会的能力
- 进化决策完全依赖维护者主观判断

## 融合方案

### 方案描述

建立三层自进化机制：

1. **感知层** — `forge evolve` 命令，扫描生态变化，输出进化建议报告
2. **决策层** — Evolution Proposal (EP) 流程，结构化评估和决策
3. **度量层** — 本地 usage analytics，从实际使用中发现改进信号

### 落位

| 变更 | 位置 | 类型 |
|------|------|------|
| `forge evolve` 命令 | `forge` CLI | core |
| EP 模板和流程 | `evolution/` | template |
| 进化雷达文档 | `ROADMAP.md` | docs |
| 使用度量（v1.2） | `.forgeteam/analytics/` | core |

### 实现路径

1. v1.0: EP 模板 + ROADMAP 进化雷达（本 EP 即实现）
2. v1.1: `forge evolve` 命令基础版本
3. v1.2: 本地 usage analytics + adaptive routing

## 验证标准

- [x] EP 模板可用，社区可按模板提交进化提案
- [x] ROADMAP 包含进化雷达（按方向而非按项目组织）
- [ ] `forge evolve` 可生成有价值的进化建议报告
- [ ] 至少一次基于 usage analytics 的 skill 优化
- [x] 不违反进化红线

## 兼容影响

- 是否 breaking change：否
- 影响的现有 skill：无
- 迁移方案：无需迁移

## 参考

- [Evolutionary Architecture](https://www.thoughtworks.com/insights/topic/evolutionary-architecture)
- MCP Protocol Specification
- Claude Code Hooks System

---

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
|------|-------|------|------|
| 2024-01-15 | Core Team | accepted | 作为 v1.0 内建能力发布 |
