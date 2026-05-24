---
name: verify
version: "2.0.0"
description: "三层验证：运行时安全防护 + 阶段门禁 + 编译器级质量验证"
triggers:
  - auto: "before any dangerous operation (safety guard)"
  - auto: "before phase transition (phase gate)"
  - auto: "after review.pass OR after execute (micro route)"
  - command: "/verify"
route_level: [micro, standard, full]
inputs:
  - 项目代码（当前状态）
  - .forgeteam/config.yaml (验证配置和安全配置)
  - memory/project-map.md (命令信息)
  - 即将执行的操作 (safety guard mode)
  - 当前阶段完成状态 (phase gate mode)
outputs:
  - allow | block | warn (safety guard)
  - gate_result: pass | fail (phase gate)
  - 验证结果 pass/fail (verification pipeline)
  - 失败详情
next: ship (if pass) | debug (if fail)
token_budget: 1500
constraints:
  must:
    - "阻断 hard_blocks 列表中的危险操作"
    - "阶段切换前检查前置条件"
    - "4 关全部执行（除配置为 SKIP 的条件）"
    - "任何 gate 失败即报 FAIL"
  should:
    - "记录拦截日志便于审计"
    - "输出门禁检查报告"
---

# Verify Skill

## 目标

统一三层验证职责：
1. **Safety Guard** — 危险操作实时拦截
2. **Phase Gate** — 阶段切换前置条件检查
3. **Verification Pipeline** — 代码质量编译器级验证

---

## Part 1: Safety Guard（运行时拦截）

在任何危险操作执行前介入，事前拦截而非事后检查。

### Level 1: 硬阻断（Block）

无论如何不允许执行：

```yaml
hard_blocks:
  commands:
    - "rm -rf /"
    - "rm -rf ~"
    - "rm -rf /*"
    - "> /dev/sda"
    - "mkfs"
    - "dd if=/dev/zero"
    - ":(){ :|:& };:"

  git:
    - "git push --force origin main"
    - "git push --force origin master"
    - "git reset --hard origin"
    - "git clean -fdx /"

  files:
    - write_to: "/etc/*"
    - write_to: "/usr/*"
    - write_to: "~/.ssh/*"
    - delete: ".git/"
    - delete: ".forgeteam/"
```

### Level 2: 确认（Confirm）

需要用户明确确认：

```yaml
confirmations:
  commands:
    - pattern: "rm -rf {any_directory}"
      message: "About to recursively delete directory. Confirm?"
    - pattern: "DROP TABLE|DROP DATABASE"
      message: "Destructive SQL operation. Confirm?"
    - pattern: "git push --force"
      message: "Force push will overwrite remote. Confirm?"

  files:
    - pattern: "overwrite existing config file"
      message: "About to overwrite {file}. Confirm?"
    - pattern: "delete more than 5 files"
      message: "About to delete {N} files. Confirm?"
```

### Level 3: 警告（Warn）

允许执行但给出提醒：

```yaml
warnings:
  commands:
    - pattern: "chmod 777"
      message: "Overly permissive. Consider 755 or 644"
    - pattern: "npm install {pkg} --save"
      message: "Adding new dependency: {pkg}"

  code:
    - pattern: "eval("
      message: "Using eval() - potential security risk"
    - pattern: "dangerouslySetInnerHTML"
      message: "XSS risk - ensure input is sanitized"
```

### 秘密检测

```yaml
secret_patterns:
  - name: "API Key"
    pattern: '(?i)(api[_-]?key|apikey)\s*[:=]\s*["\x27][A-Za-z0-9]{16,}'
  - name: "AWS Secret"
    pattern: '(?i)aws.{0,20}secret.{0,20}[:=]\s*["\x27][A-Za-z0-9/+=]{40}'
  - name: "Private Key"
    pattern: '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'
  - name: "JWT Token"
    pattern: 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
  - name: "Database URL"
    pattern: '(?i)(mysql|postgres|mongodb)://[^\s]{10,}'
  - name: "Generic Secret"
    pattern: '(?i)(secret|password|passwd|pwd)\s*[:=]\s*["\x27][^\s]{8,}'
```

### 文件保护

```yaml
protected_files:
  never_modify: [".git/config", ".git/HEAD"]
  never_delete: [".forgeteam/", "specs/"]
  never_commit: [".env", "*.pem", "*.key", "*secret*", "*credential*"]
```

### 安全配置

```yaml
# config.yaml
safety:
  level: "standard"      # paranoid | standard | relaxed
  allow_force_push: false
  secret_scan: true
  custom_blocks: []
  custom_allows: []
```

---

## Part 2: Phase Gate（阶段门禁）

在每次阶段切换时检查前置条件，避免带着缺陷进入下一阶段。

### 门禁矩阵

#### propose → plan

| 检查项 | 必须 | 说明 |
|--------|------|------|
| proposal.md 存在 | ✓ | Full route 必须有 proposal |
| 用户已确认方案 | ✓ | 不能未确认就开始 plan |
| 范围已明确 | ✓ | In/Out scope 已定义 |

#### plan → execute

| 检查项 | 必须 | 说明 |
|--------|------|------|
| tasks.md 存在 | ✓ | 必须有任务列表 |
| tasks 有 verify 条件 | ✓ | 每个 task 知道怎么验证 |
| 无循环依赖 | ✓ | task 依赖图无环 |
| 用户已确认计划 | ✓ | 不能未确认就开始写代码 |

#### execute → review

| 检查项 | 必须 | 说明 |
|--------|------|------|
| 所有 tasks 已完成 | ✓ | tasks.md 中全部 checked |
| 编译通过 | ✓ | 至少能 build |

#### review → verify

| 检查项 | 必须 | 说明 |
|--------|------|------|
| review 结果为 PASS | ✓ | 无 critical issues |
| critical issues 已修复 | ✓ | 如果有的话 |

#### verify → ship

| 检查项 | 必须 | 说明 |
|--------|------|------|
| Build Gate 通过 | ✓ | 编译成功 |
| Test Gate 通过 | ✓ | 测试全绿 |
| Run Gate 通过 | △ | 非 library 项目必须 |
| Safety Gate 通过 | ✓ | 无安全风险 |

### 门禁失败处理

```markdown
# Gate Check Failed: {from} → {to}

## 缺失项
- ✗ {missing item 1}
- ✗ {missing item 2}

## 选项
1. 修复后重新检查
2. 强制跳过（需 config.quality_gates.allow_skip = true）
3. 回退到上一阶段重新执行
```

### 门禁配置

```yaml
# config.yaml
quality_gates:
  strict: false           # true = 所有检查都是硬门禁
  allow_skip: true        # 允许带理由跳过
  skip_log: true          # 跳过操作记入日志
```

---

## Part 3: Verification Pipeline（编译器级验证）

用编译器级的客观验证代替"AI 自称完成"。

### 验证流水线

```
Build Gate ──→ Test Gate ──→ Run Gate ──→ Safety Gate
   │              │             │              │
   ▼              ▼             ▼              ▼
  FAIL?          FAIL?        FAIL?          FAIL?
   │              │             │              │
   ▼              ▼             ▼              ▼
  debug          debug        debug         BLOCK
```

### Gate 1: Build

```bash
# 执行 config.yaml 中配置的 build 命令
$BUILD_CMD 2>&1
```

**通过标准**: exit code == 0

### Gate 2: Test

```bash
# 执行 config.yaml 中配置的 test 命令
$TEST_CMD 2>&1
```

**通过标准**: 所有测试通过 (exit code == 0)

**无测试时**:
- config `test_gate_mode: warn` → 标记为 WARN，不阻塞
- config `test_gate_mode: strict` → WARN 也阻塞

### Gate 3: Run

```bash
$START_CMD &
PID=$!
sleep 5
kill -0 $PID 2>/dev/null  # 检查进程是否存活
kill $PID 2>/dev/null      # 清理
```

**通过标准**: 服务启动且 5 秒内不崩溃

**跳过条件**: 项目类型为 library / 无启动命令 / config `run_gate: false`

### Gate 4: Safety

```bash
# 检查密钥泄露
grep -rn "(?i)(api.?key|secret|password|token)\s*[:=]\s*['\"][^'\"]{8,}" ...

# 检查 .env 是否被 git 追踪
git ls-files --error-unmatch .env 2>/dev/null
```

**通过标准**: 无安全风险检出

**失败处理**: Safety Gate 失败不进入自动 debug，直接报告给用户

### 断路器

- 最多重试 `config.verification.circuit_breaker_limit` 次（默认 3）
- 超过限制 → 暂停，报告给用户等待人工介入

### 验证结果输出

```markdown
# Verification Result: PASS ✓ | FAIL ✗

### Build Gate: ✓ PASS
### Test Gate: ✓ PASS
### Run Gate: SKIP (library)
### Safety Gate: ✓ PASS

Overall: ALL GATES PASSED → Ready to ship
```

---

## 响应速度

Safety Guard 部分必须轻量级：
- 正则匹配，不做语义分析
- 总延迟 < 50ms
- 不阻塞正常操作流程
