# Skill 命令详解

> **核心原则：用户只需描述需求，ForgeTeam 自动路由。**
> 以下 slash command 在需要手动干预或从中断恢复时使用。

## 自动路由 vs 手动命令

```
┌──────────────────────────────────────────────────────────────┐
│  用户描述需求（自然语言）                                        │
│  "给用户管理模块添加批量导出功能"                                 │
└──────────────────────┬───────────────────────────────────────┘
                       │ ForgeTeam 自动判定
                       ▼
         ┌─────────────┴─────────────┐
         │ 变更规模 < 50 行?          │ → Micro    → execute → verify → done
         │ 变更规模 50-500 行?        │ → Standard → plan → [html] → execute → review → verify → ship
         │ 变更规模 > 500 行?         │ → Full     → propose → [html] → plan → execute → review → verify → ship
         └───────────────────────────┘
         [html] = 涉及 UI/页面变更时插入原型确认，纯后端跳过
```

**手动命令的使用场景：**
- 从中断会话恢复：`/forge-execute`（继续之前的任务）
- 强制进入某阶段：`/forge-verify`（只跑验证）
- 强制全流程：`/forge-propose`（即使是小改动也要先讨论方案）
- 触发企业扩展：`/deploy-k8s`、`/logging`

---

## `/forge-propose` — 需求澄清与方案选型

**何时使用：** 大型变更（>500行）、不确定方案、需要多方案对比时

**输入：** 自然语言描述需求

**流程：**

```
用户描述需求
    │
    ▼
Step 1: 需求澄清
    ├── 提取 What / Why / Who / Scope
    └── 信息不足时提问（最多 3 个关键问题）
    │
    ▼
Step 2: 上下文加载
    ├── 读取 project-map.md（项目结构）
    ├── 读取 decisions.md（历史决策）
    └── 读取 known-issues.md（避免重蹈覆辙）
    │
    ▼
Step 3: 方案选型
    ├── 列出 2-3 个可行方案
    ├── 每个方案: 实现方式 / 优点 / 缺点 / 预估工作量
    └── 推荐一个方案并说明理由
    │
    ▼
Step 4: 输出 proposal
    └── specs/active/{slug}/proposal.md
    │
    ▼
Step 5: 等待用户确认
    ├── 用户确认 → 自动进入 /forge-plan
    └── 用户调整 → 修改后重新确认
```

**产出物：** `specs/active/{slug}/proposal.md`

**示例：**

```
用户: "我们需要把单体认证系统重构为独立微服务"

ForgeTeam (propose):
┌─────────────────────────────────────────────┐
│ # Proposal: auth-microservice               │
│                                             │
│ ## 方案 A: 直接拆分（2周）                    │
│   抽取现有代码到新服务...                     │
│                                             │
│ ## 方案 B: 渐进式迁移（4周）                  │
│   Strangler Fig 模式，逐步替换...            │
│                                             │
│ ## 方案 C: 引入第三方 (1周 + 费用)            │
│   Auth0 / Keycloak...                       │
│                                             │
│ ## 推荐: 方案 B                              │
│   理由: 风险低，可分阶段验证，不影响线上       │
└─────────────────────────────────────────────┘
确认此方案？[Y/调整/重选]
```

**断路器：** 用户连续 3 次说"不对" → 暂停，直接问"请告诉我你具体想要什么"

---

## `/forge-html` — 生成静态 HTML 原型

**何时使用：** propose 完成后，涉及 UI/页面/交互变更时，先生成原型可视化确认再开发

**输入：** propose 产出的需求规格（`specs/active/{slug}/proposal.md`）

**流程：**

```
需求规格 (来自 propose)
    │
    ▼
Step 1: 提取可视化要素
    ├── 页面列表和布局结构
    ├── 核心交互（点击、切换、提交）
    ├── 数据展示方式（列表、表格、表单）
    └── 用户操作流程
    │
    ▼
Step 2: 生成 HTML 原型
    ├── 纯 HTML + CSS + 内联 JS（零依赖）
    ├── 可直接在浏览器中双击打开
    ├── 关键交互有模拟响应
    └── 页面间导航可跳转
    │
    ▼
Step 3: 输出原型文件
    └── prototype/{feature}/
        ├── index.html        (入口页)
        ├── pages/*.html      (各功能页)
        └── README.md         (查看说明)
    │
    ▼
Step 4: 等待用户确认
    ├── ✅ 确认通过 → 进入 /forge-plan
    ├── ❌ 需修改 → 自动判断修改类型：
    │       ├── 布局调整 → 只重新生成 HTML
    │       └── 功能变更 → 同步更新 spec + 重新生成 HTML
    └── ↩️ 重大偏离 → 回到 /forge-propose
```

**产出物：** `prototype/{feature}/` 目录（含 HTML 页面 + 说明文档）

**示例：**

```
用户: /forge-html
（上一步 propose 产出了"用户管理模块批量导出"的方案）

ForgeTeam (html-prototype):
┌─────────────────────────────────────────────────┐
│ ✅ 原型已生成：prototype/user-export/           │
│                                                 │
│ 📄 页面清单：                                    │
│   • index.html — 用户列表页（含筛选和勾选）       │
│   • pages/export-config.html — 导出配置弹窗       │
│   • pages/export-progress.html — 导出进度页       │
│                                                 │
│ 🖱️ 可交互元素：                                  │
│   • 列表勾选（单选/全选）                         │
│   • "导出"按钮 → 弹出配置面板                     │
│   • 格式选择（CSV/Excel）                         │
│   • "确认导出" → 显示进度条                       │
│                                                 │
│ 请在浏览器中打开 index.html 查看。                 │
│ 确认通过后我们进入任务拆解阶段。                    │
└─────────────────────────────────────────────────┘
```

**原型特点：**

| 特点 | 说明 |
|------|------|
| 零依赖 | 纯 HTML/CSS/JS，双击即可打开，不需要任何服务器 |
| 交互可感知 | 按钮可点击、Tab 可切换、表单有验证提示 |
| 线框风格 | 重布局和交互逻辑，不追求视觉完美 |
| Mock 数据 | 列表和表格使用贴近真实的假数据 |
| 响应式 | 基础的 PC/移动端适配 |

**适用判断：**

- ✅ 新页面、新功能、交互流程变更、表单设计 → 建议使用
- ❌ 纯后端 API、bug 修复、简单样式微调 → 跳过此步骤

**断路器：** 修改超过 3 轮仍未通过 → 暂停，建议重新澄清需求

---

## `/forge-plan` — 任务拆解与执行计划

**何时使用：** Standard/Full 路由的第一步（或 propose 确认后自动触发）

**输入：**
- Standard: 用户请求（直接描述）
- Full: `specs/active/{slug}/proposal.md`（已确认的方案）

**流程：**

```
需求输入（proposal 或直接描述）
    │
    ▼
Step 1: 分析需求
    ├── Standard: 从用户请求提取需求点
    └── Full: 读取已确认的 proposal
    │
    ▼
Step 2: 设计（Full Route Only）
    └── 输出 design.md（架构、数据模型、接口、文件清单）
    │
    ▼
Step 3: 任务拆解
    ├── 原子粒度（每 task = 一次提交能完成）
    ├── 按 Wave 分组（同一 Wave 内可并行）
    ├── 显式标注依赖关系
    └── 每个 task 有明确验证标准
    │
    ▼
Step 4: 输出 tasks.md
    └── specs/active/{slug}/tasks.md
    │
    ▼
Step 5: 确认
    ├── 用户说"开始" → 自动进入 /forge-execute
    └── 用户要调整 → 修改后再次确认
```

**产出物：** `specs/active/{slug}/tasks.md`（+ 可选 `design.md`）

**示例产出：**

```markdown
# Tasks: user-export

## Route: standard
## Status: planned
## Estimated: 5 tasks, M effort

## Wave 1 (可并行)

- [ ] Task 1: 创建导出服务
  - type: create
  - files: src/services/export.service.ts
  - depends: none
  - verify: tsc --noEmit 通过

- [ ] Task 2: 添加导出 API 路由
  - type: create
  - files: src/routes/export.route.ts
  - depends: none
  - verify: build 通过

## Wave 2 (依赖 Wave 1)

- [ ] Task 3: 实现 CSV 生成逻辑
  - type: modify
  - files: src/services/export.service.ts
  - depends: Task 1
  - verify: 单元测试通过
```

**拆解粒度参考：**

| 任务类型 | 典型粒度 |
|---------|---------|
| 新建数据模型 | 1 task per model |
| 新建 API 接口 | 1 task per endpoint |
| 修改已有函数 | 1 task per function |
| 添加测试 | 1 task per test file |
| 数据库迁移 | 1 task per migration |

---

## `/forge-execute` — 逐任务代码实现

**何时使用：** plan 确认后自动触发，或从中断恢复时手动调用

**流程：**

```
┌── Micro Mode ──────────────────────────┐
│ 分析请求 → 确定文件 → 实现 → verify     │
└────────────────────────────────────────┘

┌── Standard/Full Mode ──────────────────────────────────────────┐
│                                                                │
│  读取 tasks.md                                                 │
│      │                                                         │
│      ▼                                                         │
│  Wave 1: Task 1 ──────────────────────────┐                   │
│      │ 实现代码                             │                   │
│      │ 更新 tasks.md checkbox [x]          │ 同一 Wave         │
│      │ 增量验证 (build + 相关测试)          │ 可并行            │
│      │   ├── 通过 → ✓ 继续                 │                   │
│      │   └── 失败 → 进入 debug 循环         │                   │
│      │                                    │                   │
│  Wave 1: Task 2 ──────────────────────────┘                   │
│      │                                                         │
│      ▼                                                         │
│  全部完成 → 自动进入 /forge-review                              │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

**执行规则：**
1. **最小变更** — 只改完成当前 task 所需的代码
2. **不超前实现** — 不提前做后续 task 的事
3. **保持可编译** — 每个 task 完成后项目必须可编译
4. **遵循项目风格** — 参考现有代码命名和结构
5. **检查已知问题** — 读 known-issues.md 避免已知坑

**断路器：**
- 单 task 内修复尝试 ≤ 3 次 → 超过则暂停
- 连续 2 个 task 都触发断路器 → 整体暂停，提示重新 plan

---

## `/forge-review` — 自动代码评审

**何时使用：** 所有 task 完成后自动触发（Standard/Full 路由）

**评审维度：**

| 维度 | 检查内容 |
|------|---------|
| 功能完整性 | 需求点全覆盖、边界情况、错误处理 |
| 代码质量 | 命名、函数长度(<50行)、重复、死代码 |
| 一致性 | 风格统一、命名约定、错误处理模式 |
| 安全 | 无硬编码密钥、输入验证、注入防护 |
| 性能 | 无 N+1 查询、无不必要全量加载 |
| 测试覆盖 | 核心逻辑有测试、覆盖率 ≥ 80% |

**评审后流转：**
- **PASS（无 critical）** → 自动进入 `/forge-verify`
- **NEEDS_FIX（有 critical/medium）** → 返回 `/forge-execute` 修复后再评审
- **BLOCKED** → 暂停，需人工决策

---

## `/forge-verify` — 四关门禁验证

**验证流水线：**

```
Build Gate ──→ Test Gate ──→ Run Gate ──→ Safety Gate
    │              │             │              │
  编译/构建     测试通过      服务可启动      无安全风险
  exit 0       + 覆盖率≥80%   10s不崩溃     无密钥泄露
    │              │             │              │
  FAIL?          FAIL?        FAIL?          FAIL?
    ↓              ↓             ↓              ↓
  → debug        → debug      → debug       → BLOCK(人工)
```

| Gate | 通过标准 | 失败处理 |
|------|---------|---------|
| Build | exit code == 0 | 自动 debug |
| Test | 全部通过 + 覆盖率达标 | 自动 debug |
| Run | 10s 内不崩溃 | 自动 debug |
| Safety | 无安全风险 | **阻塞，报告人工** |

---

## `/forge-ship` — 提交代码并归档

**流程：** verify PASS → 生成 commit message → 安全检查 → git commit → 归档 spec → 更新 CHANGELOG

**注意：** 只做 `git commit`，不会 `git push`。push 由用户决定。

---

## `/forge-debug` — 验证失败自动修复

**循环：** 分析错误 → 应用修复 → 重新 verify → 最多 3 次 → 超过则暂停等人工

---

## `/forge-memory` — 进度保存 + 经验提取

统一管理跨会话记忆，合并原 checkpoint 和 learn 的功能：

**进度保存：** 当前阶段、进度、上下文、恢复指令 → `.forgeteam/memory/state.md`

**恢复：** 下次会话自动检测，提示"继续上次？"

**经验提取：**

| 来源 | 写入 | 示例 |
|------|------|------|
| 技术决策 | `decisions.md` | 选了 Redis 而非 Memcached |
| 解决新问题 | `known-issues.md` | MySQL 8.0 的 GROUP BY 兼容性坑 |
| 用户偏好 | `preferences.md` | commit message 用中文 |

---

## 完整流程示例

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         Full Route 完整流程                               │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  用户: "重构订单模块，支持多币种"                                          │
│                                                                          │
│  ① /forge-propose                                                        │
│     → 输出 proposal.md (3 个方案对比)                                     │
│     → 用户确认方案 B                                                      │
│                                                                          │
│  ② /forge-plan                                                           │
│     → 输出 design.md (架构 + 接口)                                        │
│     → 输出 tasks.md (12 个 task, 4 个 Wave)                              │
│     → 用户说"开始"                                                        │
│                                                                          │
│  ③ /forge-execute                                                        │
│     → 逐 task 实现 → 逐 task 增量验证                                     │
│     → tasks.md 实时更新进度                                               │
│     → (中途可 /forge-memory 保存)                                         │
│                                                                          │
│  ④ /forge-review                                                         │
│     → 评审: 1 medium issue                                               │
│     → 回到 execute 修复 → 再次 review → PASS                             │
│                                                                          │
│  ⑤ /forge-verify                                                         │
│     → Build ✓ → Test ✓ → Run ✓ → Safety ✓                               │
│                                                                          │
│  ⑥ /forge-ship                                                           │
│     → git commit → spec 归档 → CHANGELOG 更新                            │
│                                                                          │
│  ⑦ /forge-memory                                                         │
│     → 记录: 多币种用 BigDecimal 不用 float (decisions.md)                 │
│                                                                          │
│  Done. ✓                                                                 │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```
