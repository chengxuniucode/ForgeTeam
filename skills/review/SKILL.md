---
name: review
version: "1.0.0"
description: "自动代码评审，检查质量和一致性"
triggers:
  - auto: "all tasks completed in tasks.md"
  - command: "/review"
route_level: [standard, full]
inputs:
  - git diff (本次变更)
  - specs/active/{slug}/design.md
  - memory/preferences.md
outputs:
  - review 结果（通过/需修改）
  - 修改建议列表
next: verify (if pass) | execute (if needs fix)
token_budget: 3000
---

# Review Skill

## 目标

在所有 task 完成后，对整体变更进行代码评审。
检查一致性、遗漏、风险和改进机会。

## 评审维度

### 1. 功能完整性

- 所有需求点都已实现？
- 边界情况已处理？（空值、超限、异常输入）
- 错误处理完整？（try-catch、error boundary、fallback）

### 2. 代码质量

- 命名清晰表达意图？
- 函数长度合理？（建议 < 50 行）
- 重复代码已提取？
- 无死代码、未使用导入？

### 3. 一致性

- 与项目现有风格一致？
- 命名约定统一？
- 错误处理模式统一？
- 导入顺序和文件组织统一？

### 4. 安全

- 无硬编码密钥或凭据？
- 用户输入已验证和清理？
- 无 SQL 注入、XSS、路径遍历风险？
- 权限检查到位？

### 5. 性能（仅关注明显问题）

- 无明显 N+1 查询？
- 无不必要的全量加载？
- 大循环内无重复计算？
- 无内存泄漏风险？

### 6. 文档-代码一致性

- spec 中描述的接口与代码实际实现是否一致？（参数、返回值、路径）
- spec 中描述的业务流程与代码逻辑是否匹配？（条件分支、状态流转）
- 代码中新增/修改的功能是否已在文档中体现？
- 文档中引用的功能是否在代码中仍然存在？（未被删除或重命名）
- 数据模型字段、类型、约束是否与文档描述一致？

**判定标准：**

| 不一致类型 | 严重级别 |
|-----------|---------|
| 接口签名不一致（参数、返回值） | CRITICAL |
| 业务流程/状态流转描述与代码逻辑矛盾 | CRITICAL |
| 新功能缺少文档描述 | HIGH |
| 文档引用已删除/重命名的代码 | HIGH |
| 字段描述或类型不一致 | MEDIUM |
| 注释或示例过时 | LOW |

### 7. 测试覆盖

- 核心逻辑有单元测试？
- 异常路径有测试？
- 新代码覆盖率 ≥ 80%？

## 评审输出格式

```markdown
# Review Result

## Summary
- Status: PASS | NEEDS_FIX | BLOCKED
- Issues: {N} critical, {N} medium, {N} low
- Overall: {一句话总结}

## Critical Issues (必须修复)
1. [{file}:{line}] {问题描述}
   - 建议: {修复方式}

## Medium Issues (建议修复)
1. [{file}:{line}] {问题描述}
   - 建议: {修复方式}

## Low Issues (可选优化)
1. [{file}:{line}] {问题描述}
   - 建议: {修复方式}

## Positive Notes
- {做得好的地方}
```

## 评审后流程

- **PASS（无 critical）**: 自动进入 verify
- **NEEDS_FIX（有 critical/medium）**: 返回 execute 修复
  - 生成修复 task 追加到 tasks.md
  - 修复完成后再次 review
- **BLOCKED**: 暂停，需要人工决策

## 配置

在 `config.yaml` 中可配置评审严格度：

```yaml
review:
  strict_mode: false        # true = medium 也必须修复
  security_check: true      # 安全维度
  performance_check: true   # 性能维度
  style_check: true         # 风格维度
  max_review_rounds: 3      # 最多评审-修复轮次
```

## 不做的事

- 不做格式化（那是 linter 的事）
- 不重写正确但不够"优雅"的代码
- 不强制特定设计模式（除非项目已采用）
- 不评审非本次变更的代码
