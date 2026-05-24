---
name: debug
version: "1.0.0"
description: "验证失败时的自动修复循环"
triggers:
  - auto: "verify.fail"
  - command: "/debug"
route_level: [micro, standard, full]
inputs:
  - verify 失败信息
  - 错误日志/堆栈
  - 当前代码状态
  - memory/known-issues.md
outputs:
  - 代码修复
  - 修复说明
next: verify (重新验证)
token_budget: 3000
constraints:
  must:
    - "收集错误信息再修复，不盲目尝试"
    - "3 次失败触发断路器暂停"
  should:
    - "参考 known-issues.md 避免重复踩坑"
---

# Debug Skill

## 目标

当 verify 门禁失败时，自动分析错误并尝试修复。
最多尝试 N 次（默认 3），超过则暂停等待人工。

## 执行流程

```
verify.fail
    │
    ▼
[分析错误类型]
    │
    ├── 编译错误 → 语法/类型修复
    ├── 测试失败 → 逻辑修复
    ├── 启动失败 → 配置/依赖修复
    └── 安全问题 → 报告给用户（不自动修复）
    │
    ▼
[应用修复]
    │
    ▼
[重新 verify]
    │
    ├── PASS → 继续流程
    └── FAIL → 递增计数器
         │
         ├── count < limit → 重新分析
         └── count >= limit → 断路器打开
```

## 错误分析策略

### 编译错误

```
1. 提取错误信息（文件、行号、错误类型）
2. 读取相关代码上下文（前后 10 行）
3. 判断错误类型：
   - 类型错误 → 修正类型定义
   - 导入错误 → 修正导入路径
   - 语法错误 → 修正语法
   - 缺失定义 → 补充定义
4. 应用修复
5. 重新编译验证
```

### 测试失败

```
1. 提取失败的测试名和断言信息
2. 区分：
   - 测试本身有误 → 不修改测试（除非明确是测试 bug）
   - 实现逻辑有误 → 修改实现代码
3. 读取测试期望和实际输出的差异
4. 分析 root cause
5. 修复实现代码
6. 重新运行失败的测试
```

### 启动失败

```
1. 检查启动日志
2. 常见原因：
   - 端口占用 → 使用其他端口或等待
   - 环境变量缺失 → 检查 .env.example
   - 依赖未安装 → 运行安装命令
   - 配置错误 → 修正配置文件
3. 修复后重新启动验证
```

## 已知问题匹配

在尝试修复前，先检查 `known-issues.md`：
- 如果错误模式匹配已知问题 → 直接应用已知解法
- 节省反复试错的时间

## 修复记录

每次修复都记录：
```markdown
## Debug Attempt {N}

- Gate: {which gate failed}
- Error: {error message}
- Analysis: {root cause}
- Fix: {what was changed}
- Result: {pass/still-fail}
```

## 断路器

```yaml
circuit_breaker:
  max_attempts: 3           # 同一错误最多尝试 3 次
  consecutive_fails: 2      # 连续 2 个不同错误也触发
  cooldown: "human_input"   # 暂停等待人工

  output_on_break:
    - error_summary
    - attempted_fixes
    - suggested_directions
    - related_known_issues
```

## 暂停时输出格式

```markdown
# Debug Paused — Human Input Needed

## 问题
{错误描述}

## 已尝试
1. {尝试 1 及结果}
2. {尝试 2 及结果}
3. {尝试 3 及结果}

## 建议方向
- {可能的解法 A}
- {可能的解法 B}

## 相关信息
- 错误文件: {file:line}
- 相关测试: {test file}
- 可能相关的已知问题: {link to known-issues}

请提供指导后输入 `/debug` 继续
```

## 不做的事

- 不自动修复安全问题
- 不修改测试来让测试通过（除非测试本身有明确 bug）
- 不删除代码来规避编译错误
- 不绕过验证（如 skip test、ignore error）
