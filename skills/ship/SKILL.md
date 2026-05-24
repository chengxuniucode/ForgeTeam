---
name: ship
version: "1.0.0"
description: "提交代码、归档 spec、生成 changelog"
triggers:
  - auto: "verify.pass"
  - command: "/ship"
route_level: [micro, standard, full]
inputs:
  - verify 通过结果
  - specs/active/{slug}/ (if exists)
  - git 状态
outputs:
  - git commit(s)
  - specs/archived/{slug}/ (moved from active)
  - CHANGELOG 更新 (full route)
next: learn
token_budget: 800
constraints:
  must:
    - "验证通过后才提交"
    - "归档 spec 到 specs/archived/"
  should:
    - "更新 changelog"
---

# Ship Skill

## 目标

验证通过后，将变更安全地提交到 Git 并归档相关 spec。
确保每次 ship 都有清晰的提交记录和可追溯的变更历史。

## 执行步骤

### Step 1: 确认 verify 结果

确认 verify skill 输出为 PASS，否则拒绝 ship。

### Step 2: 组织提交

**Micro Route**:
- 单次 commit，消息格式：`fix: {描述}` 或 `feat: {描述}`

**Standard Route**:
- 单次 squash commit 或逐 task commit（根据 config）
- 消息格式：`feat({scope}): {描述}`

**Full Route**:
- 逐 Wave commit，最终可选 squash
- 消息格式包含 spec 引用：`feat({scope}): {描述} [spec:{slug}]`

### Step 3: Commit Message 生成

```
{type}({scope}): {简短描述}

{详细描述，说明做了什么和为什么}

Changes:
- {文件变更摘要}

Verified: build ✓ test ✓ run ✓ safety ✓
```

Type 自动判定：
- 新文件为主 → `feat`
- 修改现有文件 → `fix` 或 `refactor`
- 只改配置/文档 → `chore` 或 `docs`
- 性能相关 → `perf`

### Step 4: 文档完整性检查

提交前确认文档与代码同步：

```
检查清单：
  ├── specs/active/{slug}/ 中的文档是否与代码变更一致？
  ├── 新增接口 → api.md 已更新？
  ├── 数据模型变更 → data-model.md 已更新？
  ├── 流程变更 → flow.md 已更新？
  ├── 配置变更 → config.md 已更新？
  └── 如有不一致 → 阻塞提交，返回 execute 补齐
```

如发现文档未同步，拒绝 ship 并提示：
```
⚠️ 文档-代码不同步，无法提交：
  - src/routes/user.ts 新增了 POST /api/users/export
  - 但 specs/active/{slug}/api.md 中无此接口描述
  → 请先补齐文档再执行 /forge-ship
```

### Step 5: 执行提交

```bash
# 添加代码和文档变更文件（必须同时包含）
git add {changed_code_files} {changed_doc_files}

# 确认没有意外文件
git status

# 提交
git commit -m "{generated_message}"
```

### Step 6: 归档 Spec

如果存在活跃 spec：
```bash
# 移动到归档目录
mv specs/active/{slug} specs/archived/{slug}

# 添加完成标记
echo "\n## Completed: $(date '+%Y-%m-%d')" >> specs/archived/{slug}/tasks.md
```

### Step 7: 更新 Changelog（Full Route）

追加到项目 CHANGELOG.md：
```markdown
## [{date}] - {slug}

### Added
- {新增功能}

### Changed
- {修改内容}

### Fixed
- {修复内容}
```

### Step 8: 清理 state.md

```markdown
# Current State
- spec: none
- phase: idle
- last_completed: {slug}
- last_ship: {timestamp}
```

## 安全检查

在 commit 之前再次确认：
- [ ] 无 `.env` 文件被追踪
- [ ] 无 `node_modules/`、`dist/` 等被追踪
- [ ] `.gitignore` 覆盖了敏感路径
- [ ] 没有意外的大文件（> 1MB）

## 不做的事

- 不 push（只 commit，push 由用户决定）
- 不创建 tag（除非用户配置了 auto-tag）
- 不触发 CI（那是 push 后的事）
- 不修改已有的 commit history
