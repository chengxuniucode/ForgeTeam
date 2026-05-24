---
name: quality-gate
version: "1.0.0"
description: "阶段切换时的质量门禁检查"
triggers:
  - auto: "before phase transition"
  - command: "/gate-check"
route_level: [standard, full]
inputs:
  - 当前阶段完成状态
  - 目标阶段要求
  - config.yaml 门禁配置
outputs:
  - gate_result: pass | fail | warn
  - missing_items: []
next: null (gate check is inline)
token_budget: 500
---

# Quality Gate Skill

## 目标

在每次阶段切换时（如 plan → execute、execute → review），
检查前置条件是否满足，避免带着缺陷进入下一阶段。

## 门禁矩阵

### propose → plan

| 检查项 | 必须 | 说明 |
|--------|------|------|
| proposal.md 存在 | ✓ | Full route 必须有 proposal |
| 用户已确认方案 | ✓ | 不能未确认就开始 plan |
| 范围已明确 | ✓ | In/Out scope 已定义 |

### plan → execute

| 检查项 | 必须 | 说明 |
|--------|------|------|
| tasks.md 存在 | ✓ | 必须有任务列表 |
| tasks 有 verify 条件 | ✓ | 每个 task 知道怎么验证 |
| 无循环依赖 | ✓ | task 依赖图无环 |
| design.md 存在 | △ | Full route 必须，Standard 可选 |
| 用户已确认计划 | ✓ | 不能未确认就开始写代码 |

### execute → review

| 检查项 | 必须 | 说明 |
|--------|------|------|
| 所有 tasks 已完成 | ✓ | tasks.md 中全部 checked |
| 编译通过 | ✓ | 至少能 build |
| 无明显语法错误 | ✓ | Lint 无 error 级别 |

### review → verify

| 检查项 | 必须 | 说明 |
|--------|------|------|
| review 结果为 PASS | ✓ | 无 critical issues |
| critical issues 已修复 | ✓ | 如果有的话 |

### verify → ship

| 检查项 | 必须 | 说明 |
|--------|------|------|
| Build Gate 通过 | ✓ | 编译成功 |
| Test Gate 通过 | ✓ | 测试全绿 |
| Run Gate 通过 | △ | 非 library 项目必须 |
| Safety Gate 通过 | ✓ | 无安全风险 |

## 门禁失败处理

```markdown
# Gate Check Failed: {from} → {to}

## 缺失项
- ✗ {missing item 1}
- ✗ {missing item 2}

## 补救方式
- {how to fix item 1}
- {how to fix item 2}

## 选项
1. 修复后重新检查 → 执行修复 + `/gate-check`
2. 强制跳过（需 config 允许） → 记录跳过原因
3. 回退到上一阶段 → 重新执行当前阶段
```

## 配置

```yaml
# config.yaml
quality_gates:
  strict: false           # true = 所有检查都是硬门禁
  allow_skip: true        # 允许带理由跳过
  skip_log: true          # 跳过操作记入日志

  custom_gates:
    execute_review:
      - check: "lint_pass"
        required: true
      - check: "type_check_pass"
        required: true
```

## 门禁日志

所有门禁检查结果记录到 `.forgeteam/gates.log`：
```
[2024-01-15T10:00:00Z] plan→execute: PASS (all 5 checks passed)
[2024-01-15T11:30:00Z] execute→review: FAIL (2/5 tasks incomplete)
[2024-01-15T11:45:00Z] execute→review: PASS (all tasks complete)
[2024-01-15T12:00:00Z] review→verify: PASS (no critical issues)
[2024-01-15T12:05:00Z] verify→ship: PASS (all 4 gates green)
```
