---
name: verify
version: "1.0.0"
description: "编译器级质量验证：Build → Test → Run → Safety 四关"
triggers:
  - auto: "after review.pass OR after execute (micro route)"
  - command: "/verify"
route_level: [micro, standard, full]
inputs:
  - 项目代码（当前状态）
  - .forgeteam/config.yaml (验证配置)
  - memory/project-map.md (命令信息)
outputs:
  - 验证结果 (pass/fail)
  - 失败详情
next: ship (if pass) | debug (if fail)
token_budget: 1000
---

# Verify Skill

## 目标

用编译器级的客观验证代替"AI 自称完成"。
必须通过全部门禁才能进入 ship 阶段。

## 验证流水线

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
# 自动检测构建系统
if [ -f "package.json" ]; then
  npm run build 2>&1
elif [ -f "pom.xml" ]; then
  mvn compile 2>&1
elif [ -f "go.mod" ]; then
  go build ./... 2>&1
elif [ -f "Cargo.toml" ]; then
  cargo build 2>&1
elif [ -f "pyproject.toml" ]; then
  python -m py_compile $(find . -name "*.py" -not -path "*/venv/*") 2>&1
fi
```

**通过标准**: exit code == 0

**Library 项目额外检查**:
- TypeScript: `tsc --noEmit`
- Go: `go vet ./...`
- Rust: `cargo clippy`

### Gate 2: Test

```bash
# 自动检测测试框架
if [ -f "package.json" ]; then
  npm test 2>&1
elif [ -f "pom.xml" ]; then
  mvn test 2>&1
elif [ -f "go.mod" ]; then
  go test ./... 2>&1
elif [ -f "Cargo.toml" ]; then
  cargo test 2>&1
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
  pytest 2>&1
fi
```

**通过标准**:
- 所有测试通过 (exit code == 0)
- 新代码覆盖率 ≥ config.verification.coverage_threshold (默认 80%)

**无测试时的策略**:
- 如果项目完全没有测试 → Gate 标记为 WARN，不阻塞
- 如果项目有测试但本次变更没写 → Gate 标记为 WARN
- config.yaml 可配置 `test_gate: strict` 则 WARN 也阻塞

### Gate 3: Run

```bash
# 启动服务并健康检查
START_CMD=$(detect_start_command)
$START_CMD &
PID=$!
sleep 5

# 健康检查
if curl -sf http://localhost:${PORT}/health > /dev/null 2>&1; then
  echo "PASS: service healthy"
elif curl -sf http://localhost:${PORT}/ > /dev/null 2>&1; then
  echo "PASS: service responding"
elif kill -0 $PID 2>/dev/null; then
  echo "PASS: process alive (no HTTP endpoint)"
else
  echo "FAIL: service crashed"
fi

# 清理
kill $PID 2>/dev/null
```

**通过标准**: 服务启动且 10 秒内不崩溃

**跳过条件**:
- 项目类型为 library → 跳过
- 没有启动命令 → 跳过
- config.yaml 中 `run_gate: false` → 跳过

### Gate 4: Safety

```bash
# 检查是否有密钥泄露
grep -rn "(?i)(api.?key|secret|password|token)\s*[:=]\s*['\"][^'\"]{8,}" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.java" \
  --include="*.go" --include="*.rs" --include="*.yaml" --include="*.json" \
  . 2>/dev/null | grep -v node_modules | grep -v ".forgeteam"

# 检查 .env 是否被 git 追踪
git ls-files --error-unmatch .env 2>/dev/null && echo "FAIL: .env tracked"

# 检查文件权限
find . -name "*.sh" -not -perm 755 -not -path "*node_modules*"
```

**通过标准**: 无任何安全风险检出

**失败处理**: Safety Gate 失败不进入自动 debug，直接报告给用户

## 验证结果输出

```markdown
# Verification Result

## Summary: PASS ✓ | FAIL ✗

### Build Gate: ✓ PASS
- Command: npm run build
- Duration: 3.2s
- Output: Clean build, no warnings

### Test Gate: ✓ PASS
- Command: npm test
- Duration: 8.7s
- Tests: 42 passed, 0 failed
- Coverage: 87% (threshold: 80%)

### Run Gate: ✓ PASS
- Command: npm start
- Port: 3000
- Health: HTTP 200 in 2.1s
- Stable: No crash in 10s

### Safety Gate: ✓ PASS
- Secrets: None detected
- .env: Not tracked
- Permissions: OK

---
Overall: ALL GATES PASSED → Ready to ship
```

## 失败时

如果任何 Gate 失败：
1. 收集错误信息
2. 触发 debug skill
3. debug 修复后重新运行 verify（从失败的 Gate 开始）
4. 最多重试 config.verification.circuit_breaker_limit 次（默认 3）
5. 超过限制 → 暂停，报告给用户
