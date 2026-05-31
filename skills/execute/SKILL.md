---
name: execute
version: "1.0.0"
description: "逐任务执行代码变更"
triggers:
  - auto: "tasks.md exists AND status == planned|in-progress"
  - command: "/execute"
route_level: [micro, standard, full]
inputs:
  - specs/active/{slug}/tasks.md (standard/full)
  - user_request (micro)
  - memory/project-map.md
  - memory/known-issues.md
outputs:
  - 代码变更
  - tasks.md 状态更新
next: review (standard/full) | verify (micro)
token_budget: 5000-20000
constraints:
  must:
    - "每 task 完成后可编译"
    - "不跳过任何 task"
  should:
    - "文档同步更新"
---

# Execute Skill

## 目标

按 tasks.md 中的顺序逐任务实现代码变更。
每完成一个 task 就更新状态并触发增量验证。

## 执行模式

### Micro Mode（无 tasks.md）

直接根据用户请求实现变更：
1. 分析请求
2. 确定要修改的文件
3. 实现变更
4. 直接进入 verify

### Standard/Full Mode（有 tasks.md）

按波次（Wave）执行：
1. 读取 tasks.md
2. 找到当前 Wave 中未完成的 task
3. 逐 task 执行
4. 每完成一个 task：
   - 更新 tasks.md 中的 checkbox
   - 运行该 task 的 verify 条件
   - 如果验证通过 → 标记 ✓，继续下一个
   - 如果验证失败 → 进入 debug 循环

## 执行规则

### 代码编写原则

1. **最小变更原则**：只修改完成当前 task 所需的代码
2. **不超前实现**：不提前实现后续 task 的内容
3. **保持可编译**：每个 task 完成后项目必须可编译
4. **遵循项目风格**：参考现有代码的命名、结构、格式
5. **引用已知问题**：检查 known-issues.md 避免已知坑
6. **文档代码同步**：代码变更必须同步更新对应文档（见下方规则）

### 文档-代码同步规则

**核心原则：代码是实现，文档是契约。两者必须始终一致，不允许出现"代码改了但文档没跟上"的情况。**

每完成一个 task，必须检查并同步以下文档：

| 变更类型 | 必须同步的文档 |
|----------|---------------|
| 新增/修改 API 接口 | `specs/active/{slug}/api.md`（接口签名、参数、返回值） |
| 新增/修改数据模型 | `specs/active/{slug}/data-model.md`（字段、类型、约束） |
| 新增/修改页面/组件 | `specs/active/{slug}/pages.md`（页面清单、路由、组件职责） |
| 修改业务流程/逻辑 | `specs/active/{slug}/flow.md`（流程步骤、条件分支、状态流转） |
| 修改配置/环境变量 | `specs/active/{slug}/config.md`（配置项、默认值、说明） |
| 修改数据库结构 | `specs/active/{slug}/migration.md`（DDL、迁移步骤、回滚方式） |

**同步时机：** 在 task 的增量验证之前完成文档更新，确保文档和代码在同一个 task 内保持一致。

**同步格式：**

```markdown
## {模块名} — {功能描述}

### 接口/组件/模型

{签名、参数、返回值等技术契约}

### 行为说明

{业务逻辑、边界条件、异常处理}

### 变更记录

| 日期 | Task | 变更内容 |
|------|------|---------|
| {date} | Task N | {具体变更} |
```

**不允许的情况：**

- 代码增加了新接口，但文档中没有对应描述
- 代码修改了参数/返回值，但文档仍是旧版本
- 代码删除了功能，但文档仍然引用
- 文档描述的行为与代码实际行为不一致

**验证方式：** review skill 会对比代码变更和文档变更，如发现不同步将标记为 HIGH 级别问题。

### 增量验证

每个 task 完成后运行：
```bash
# 1. 编译检查
{build_command} 2>&1 | tail -20

# 2. 相关测试
{test_command} --filter={related_tests}

# 3. Lint（如果配置了）
{lint_command} {changed_files}
```

### 状态更新

执行中持续更新 `specs/active/{slug}/tasks.md`：

```markdown
- [x] Task 1: 创建用户模型
  - files: src/models/user.ts
  - verified: ✓ build pass, tests pass
  - completed: 2024-01-15T10:30:00Z

- [ ] Task 2: 实现注册接口  ← current
  - files: src/routes/auth.ts
  - depends: Task 1
  - verify: pending
```

### 同时更新 state.md

```markdown
# Current State
- spec: specs/active/user-auth/
- phase: execute
- current_task: 2/5
- last_action: "完成用户模型创建"
- next_action: "实现注册接口"
```

## 断路器

单个 task 内：
- 编译错误修复尝试 ≤ 3 次
- 测试失败修复尝试 ≤ 3 次
- 超过限制 → 暂停，报告问题，等待人工

跨 task：
- 如果连续 2 个 task 都触发断路器 → 整体暂停
- 提示用户可能需要重新 plan

## 并行执行（Parallel Execute）

### 并行声明语法

tasks.md 中使用 `parallel:` 标记声明可并行执行的任务组：

```markdown
## Wave 1

- [x] Task 1: 创建数据模型
  - files: src/models/user.ts
  - verified: ✓

## Wave 2

parallel:
- [ ] Task 2: 实现注册接口
  - files: src/routes/register.ts
  - depends: Task 1
- [ ] Task 3: 实现登录接口
  - files: src/routes/login.ts
  - depends: Task 1

## Wave 3

- [ ] Task 4: 集成测试
  - files: tests/auth.test.ts
  - depends: Task 2, Task 3
```

### 并行执行规则

1. **`parallel:` 块内的 task 无相互依赖**，可同时开始
2. AI 工具应尽量利用多文件编辑能力同时处理并行任务
3. 并行任务的**验证仍然逐个进行**，确保每个 task 独立通过
4. 一个并行任务失败**不阻塞**同组其他任务继续，但阻塞下一 Wave
5. 并行块结束后，所有任务必须标记 ✓ 才能进入下一 Wave

### 并行安全约束

- 并行任务**不得修改同一文件**（文件冲突 → 改为串行）
- 并行任务**不得有隐含依赖**（共享状态、执行顺序假设）
- 若执行中发现并行冲突，自动降级为逐个执行并记录

### 串行回退

当 AI 工具不支持真正并行时（如单线程 CLI），并行声明仍有价值：
- 告诉 AI **这些任务无顺序依赖**，可以选择任意顺序执行
- 允许 AI 跳过中间验证，在并行块末尾统一验证
- 未来支持真并行时无需修改 tasks.md

## 不做的事

- 不修改 tasks.md 中的任务描述（只改状态）
- 不跳过 task（必须按顺序）
- 不在未完成当前 task 时开始下一个
- 不修改不在 task.files 列表中的文件（除非是必要的间接影响）
