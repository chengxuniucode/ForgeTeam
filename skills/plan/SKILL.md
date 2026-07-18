---
name: plan
version: "1.0.0"
description: "任务拆解与执行计划生成"
triggers:
  - auto: "route_level in [standard, full]"
  - command: "/plan"
route_level: [standard, full]
inputs:
  - specs/active/{slug}/proposal.md (if full route)
  - user_request (if standard route)
  - memory/project-map.md
  - memory/decisions.md
outputs:
  - specs/active/{slug}/tasks.md
  - specs/active/{slug}/design.md (if full route)
next: execute
token_budget: 3000
constraints:
  must:
    - "生成 tasks.md 含波次和验证条件"
    - "每个 task 粒度到一次提交能完成"
  should:
    - "加载 known-issues.md 规避已知问题"
---

# Plan Skill

## 目标

将已确认的需求（proposal 或直接请求）拆解为可逐步执行的任务列表，
每个任务粒度到"一次提交能完成"。

## 执行步骤

### Step 1: 分析需求

**Standard Route**:
- 直接从用户请求提取需求点
- 参考 project-map 了解现有结构

**Full Route**:
- 读取 `specs/active/{slug}/proposal.md`
- 基于已确认的方案进行设计

### Step 2: 设计（Full Route Only）

生成 `specs/active/{slug}/design.md`：

```markdown
# Design: {title}

## 架构变更
{新增/修改的模块、组件、接口}

## 数据模型
{新增/修改的数据结构}

## 接口定义
{API endpoints / function signatures}

## 依赖关系
{新增的依赖包、外部服务}

## 文件变更清单
{将要创建/修改/删除的文件列表}
```

### Step 3: 任务拆解

拆解原则：
1. 每个 task 是一个原子操作（创建文件 / 修改函数 / 添加测试）
2. task 之间的依赖关系显式标注
3. 可并行的 task 标记为同一波次
4. 每个 task 有明确的验证标准
5. 对可自动化验证的行为，先列出失败测试；无法测试时在 task 中写明豁免理由

### Step 4: 生成 tasks.md

使用 `parallel:` 标记声明无相互依赖、可同时执行的任务组：

```markdown
# Tasks: {slug}

## Route: {micro|standard|full}
## Status: planned
## Created: {timestamp}
## Estimated: {task_count} tasks, {size} effort

---

## Wave 1

parallel:
- [ ] Task 1: {描述}
  - type: create|modify|delete
  - files: {文件路径列表}
  - depends: none
  - verify: {验证方式}

- [ ] Task 2: {描述}
  - type: create
  - files: {文件路径}
  - depends: none
  - verify: {验证方式}

## Wave 2

- [ ] Task 3: {描述}
  - type: modify
  - files: {文件路径}
  - depends: Task 1, Task 2
  - verify: {验证方式}

## Wave 3

parallel:
- [ ] Task 4a: {描述}
  - type: create
  - files: {文件路径A}
  - depends: Task 3
  - verify: {验证方式}

- [ ] Task 4b: {描述}
  - type: create
  - files: {文件路径B}
  - depends: Task 3
  - verify: {验证方式}
```

**并行标记规则：**
- `parallel:` 放在 Wave 标题后、task 列表前
- 同一 `parallel:` 块内的 task 不得修改相同文件
- 没有 `parallel:` 标记的 Wave 默认串行执行
- 拆解时优先考虑哪些 task 可以并行以缩短执行路径

### Step 5: 确认

将任务计划呈现给用户。
- 如果用户说"开始" → 触发 execute
- 如果用户说要调整 → 修改 tasks.md 后再次确认

## 拆解启发式

| 任务类型 | 典型粒度 |
|---------|---------|
| 新建数据模型 | 1 task per model |
| 新建 API endpoint | 1 task per endpoint (含路由+handler+validator) |
| 修改已有函数 | 1 task per function |
| 添加测试 | 1 task per test file |
| 修改配置 | 1 task (可合并多个配置变更) |
| 数据库迁移 | 1 task per migration |

## 质量要求

- 每个 task 的 `verify` 字段必须写明如何验证完成
- 文件路径必须具体到文件名（不能只写目录）
- 依赖关系不能有环
- 总 task 数建议：Standard 3-10 个，Full 5-30 个
