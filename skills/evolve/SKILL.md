---
name: evolve
version: "1.0.0"
description: "自进化能力：感知生态变化、评估融合方案、驱动版本迭代"
triggers:
  - command: "/evolve"
  - auto: "forge evolve CLI"
route_level: [standard, full]
inputs:
  - AI 编码生态最新动态
  - memory/decisions.md (历史进化决策)
  - .forgeteam/analytics/ (使用数据, v1.2+)
  - GitHub Issues / Community feedback
outputs:
  - evolution/EP-{NNN}-{title}.md (进化提案)
  - evolution-report.md (进化建议报告)
next: null
token_budget: 3000
constraints:
  must:
    - "通过进化红线检查（不破坏零依赖、不引入 breaking change）"
  should:
    - "产出 EP 文档记录进化决策"
---

# Evolve Skill

## 目标

使 ForgeTeam 具备自我进化能力。不依赖对特定项目的跟踪，而是：
1. 持续感知整个 AI 编码生态的技术方向
2. 从自身使用数据中发现改进机会
3. 结构化评估新方向的融合价值
4. 驱动版本迭代决策

## 进化不等于堆功能

进化的核心判断标准：
- 是否让用户**更快**交付？
- 是否**降低**了认知负担？
- 是否保持了"one person, full team"的承诺？
- 是否符合进化红线？

## 执行步骤

### Step 1: 感知 (Sense)

扫描以下信息源，发现值得关注的变化：

| 信息源 | 关注维度 |
|--------|---------|
| GitHub Trending (AI/DevTools) | 新工具、新范式、社区热度 |
| AI 工具 Release Notes | 新能力、新协议、Breaking Changes |
| 社区 Issues / Discussions | 用户痛点、Feature Request、使用模式 |
| 技术博客 / 论文 | 新研究方向、行业趋势 |
| 本地 usage analytics | skill 跳过率、断路器频率、完成时间 |

输出：**变化信号列表**

```markdown
## 感知信号 ({date})

### 信号 1: {描述}
- 来源: {URL / 项目 / 论文}
- 方向: {agent 编排 / 工作流 / 上下文 / 质量 / 协议}
- 时效性: {短期热点 / 中期趋势 / 长期方向}
- 与 ForgeTeam 相关度: {高 / 中 / 低}

### 信号 2: ...
```

### Step 2: 评估 (Evaluate)

对高相关度信号进行深度评估：

```
信号 → 问自己 5 个问题:

1. 这解决了什么真实痛点？（不是"看起来酷"）
2. ForgeTeam 用户是否有此需求？（看 Issues / analytics）
3. 融合代价多大？（改核心 vs 加扩展 vs 只改文档）
4. 是否违反进化红线？
5. 投入产出比：这个方向值得现在投入吗？
```

评估矩阵：

| 维度 | 得分标准 |
|------|---------|
| 痛点真实度 | 有用户反馈 > 有行业数据 > 仅有理论支持 |
| 融合代价 | 改文档 < 加 extension < 加 core skill < 改架构 |
| 时效性 | 长期趋势 > 中期方向 > 短期热点 |
| 竞争态势 | 我们不做用户会流失 > 锦上添花 > 可有可无 |

### Step 3: 决策 (Decide)

根据评估结果，给出决策建议：

| 决策 | 条件 | 动作 |
|------|------|------|
| **立即融合** | 痛点真实 + 代价低 + 时效紧 | 生成 EP → 排入下个 minor |
| **规划融合** | 痛点真实 + 代价中等 + 长期趋势 | 生成 EP → 排入 roadmap |
| **持续观察** | 方向对但时机不成熟 | 记录到进化雷达 |
| **明确拒绝** | 违反红线 / ROI 太低 | 记录拒绝原因 |

### Step 4: 产出 (Output)

根据决策生成对应产出：

**进化建议报告（`evolution-report.md`）:**

```markdown
# Evolution Report — {date}

## 扫描范围
- 时间窗口: {上次 evolve 到现在}
- 信息源: {扫描了什么}

## 发现信号: {N} 个

## 建议动作

### 立即融合 ({N} 项)
1. {信号} → {建议方案} → EP-{NNN}

### 规划融合 ({N} 项)
1. {信号} → {建议方向} → 排入 v{X.Y}

### 持续观察 ({N} 项)
1. {信号} → {观察理由}

### 明确拒绝 ({N} 项)
1. {信号} → {拒绝理由}

## 本期进化健康度
- 核心 skill 稳定度: {无变更 / 有优化 / 有重构}
- Extension 活跃度: {新增 N / 更新 N / 废弃 N}
- 社区贡献: {PR N / Issues N / EP N}
- 用户反馈趋势: {正面 / 中性 / 需关注}
```

**进化提案（如决策为"融合"）:**
- 按 `evolution/EP-000-template.md` 格式生成

### Step 5: 记录与归档

- 更新 `ROADMAP.md` 进化日志
- 更新进化雷达（如发现新方向）
- 归档本次 evolution-report

## 进化频率建议

| 模式 | 频率 | 适用场景 |
|------|------|---------|
| 定期进化 | 每月一次 | 日常迭代 |
| 事件驱动 | 即时 | 重大行业变化（新协议发布、重量级工具推出） |
| 回顾进化 | 每季度 | major 版本规划前 |

## 进化红线（不可违反）

1. **纯文本架构** — 永远是 Shell + Markdown
2. **一个人能用** — 不要求团队配合
3. **3 分钟上手** — 核心流程透明
4. **离线可用** — 不强制云依赖
5. **平台无关** — 不绑定特定 AI 工具
6. **人类最终决策** — 断路器永远存在

## 与其他 Skill 的关系

```
memory (每次交付后提取经验)
  │
  └──→ 积累数据 → 为 evolve 提供用户侧信号
  
evolve (定期评估生态变化)
  │
  ├──→ 升级 core skills (propose/plan/execute/...)
  ├──→ 新增 extensions
  ├──→ 升级 adapters
  └──→ 更新 templates

sync (拉取最新版本)
  │
  └──→ 将 evolve 决策的产出分发给用户
```

## 不做的事

- 不自动执行进化（人类审批 EP 后才实施）
- 不追短期热点（必须通过时效性判断）
- 不因为"别人有"就加（必须通过痛点验证）
- 不打破向后兼容（除非 major 版本且有迁移路径）
- 不引入编译依赖（进化不能破坏纯文本架构）
