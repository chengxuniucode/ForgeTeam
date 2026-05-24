# Contributing to ForgeTeam

感谢你对 ForgeTeam 的兴趣！本文档说明如何参与贡献。

---

## 贡献类型

| 类型 | 难度 | 说明 |
|------|------|------|
| 修复 typo / 文档 | 低 | 直接 PR |
| 新增 Extension Skill | 中 | 按规范编写 SKILL.md |
| 优化现有 Core Skill | 中 | 需要讨论方案 |
| 新增 Adapter | 中 | 适配新 AI 工具 |
| Core 架构变更 | 高 | 需要 RFC + 评审 |

---

## 快速开始

```bash
# 1. Fork 并克隆
git clone https://github.com/YOUR_NAME/ForgeTeam.git
cd ForgeTeam

# 2. 验证项目结构
bash tests/validate-structure.sh

# 3. 创建分支
git checkout -b feat/my-contribution

# 4. 开发并验证
# ... 编写代码 ...
bash tests/validate-structure.sh  # 确保结构仍然正确

# 5. 提交
git commit -m "feat(extensions): add deploy/docker skill"

# 6. Push 并创建 PR
git push origin feat/my-contribution
```

---

## 贡献 Extension Skill

这是最常见的贡献方式。按以下步骤操作：

### 1. 确定类目

```
extensions/
├── auth/           # 认证与权限
├── ui/             # 前端与 UI
├── deploy/         # 部署与运维
├── data/           # 数据与存储
├── integration/    # 第三方集成
├── testing/        # 测试增强
└── monitoring/     # 可观测性
```

如果现有类目不合适，可以在 PR 中提议新类目。

### 2. 创建 Skill 目录

```bash
mkdir -p extensions/{category}/{skill-name}
```

### 3. 编写 SKILL.md

必须遵循标准 frontmatter 格式：

```markdown
---
name: {category}-{skill-name}
version: "1.0.0"
description: "一句话描述"
type: extension
triggers:
  - command: "/{skill-name}"
  - auto: "{自动触发条件}"
requires:
  - core_skill: {依赖的核心 skill}
inputs:
  - {输入 1}
  - {输入 2}
outputs:
  - {产出 1}
  - {产出 2}
---

# {Skill Name} Skill

## 目标

{做什么、为什么需要}

## 执行步骤

### Step 1: {标题}
{内容}

### Step 2: {标题}
{内容}

### Step N: 验证
{如何验证 skill 执行成功}
```

### 4. 质量要求

- [ ] SKILL.md frontmatter 完整（name, version, description, type, triggers）
- [ ] 执行步骤清晰可操作
- [ ] 包含验证步骤
- [ ] 支持多语言/框架（至少覆盖 2 种）
- [ ] 不硬编码特定企业信息
- [ ] 不引入外部运行时依赖

---

## 贡献 Adapter

为新的 AI 工具添加适配支持：

### 1. 创建适配脚本

```bash
# adapters/{tool-name}.sh
```

### 2. 实现生成函数

```bash
generate_{tool_name}() {
  # 生成该工具所需的配置文件
  # 必须包含:
  #   - 路由逻辑
  #   - skill 引用
  #   - memory 加载
  #   - 验证规则
  #   - 安全规则
}
```

### 3. 注册到 CLI

在 `forge` 脚本的 `forge_generate()` 函数中添加 case 分支。

---

## 贡献 Core Skill 变更

核心 skill 的变更影响所有用户，需要更谨慎的流程：

### 1. 开 Issue 讨论

说明：
- 当前行为是什么
- 期望行为是什么
- 为什么需要变更
- 是否有 breaking change

### 2. 编写 RFC（如果是重大变更）

在 `evolution/` 下创建：

```markdown
# RFC: {标题}

## 动机
{为什么需要这个变更}

## 方案
{具体方案}

## 影响
{对现有用户的影响}

## 迁移
{如何迁移}
```

### 3. 实现 + 测试

确保 `tests/validate-structure.sh` 通过。

---

## 引入外部创新

当外部项目（Superpowers、OpenSpec、GStack 等）有值得借鉴的创新时：

### 评估流程

```
1. 创建 Issue，标签: "external-innovation"
2. 说明:
   - 来源项目和版本
   - 具体特性/思想
   - ForgeTeam 当前短板
   - 建议落位（core / extension / adapter / template）
3. 社区讨论
4. 维护者决策
5. 实现并标注来源
```

### 许可证要求

- 如果是 port/fork 代码：必须兼容 MIT 许可证
- 如果只是思想借鉴：在 commit message 或文档中标注灵感来源
- 禁止引入 GPL/AGPL 依赖

---

## Commit Message 规范

```
{type}({scope}): {描述}

type:
  feat     — 新功能
  fix      — 修复
  docs     — 文档
  refactor — 重构
  test     — 测试
  chore    — 构建/工具

scope:
  core     — 核心 skill
  ext      — extensions
  cli      — forge CLI
  adapter  — 平台适配
  docs     — 文档
```

**示例：**

```
feat(ext): add deploy/docker skill
fix(core): verify gate skips library run check correctly
docs: add ROADMAP.md and CONTRIBUTING.md
refactor(cli): simplify forge_detect_project logic
```

---

## PR 要求

- [ ] 分支基于最新 `main`
- [ ] `tests/validate-structure.sh` 通过
- [ ] commit message 符合规范
- [ ] 新增 skill 有完整 frontmatter
- [ ] 不包含硬编码密钥或企业信息
- [ ] 描述中说明变更目的和影响

---

## 发布流程（维护者）

```bash
# 1. 更新版本号
echo "1.1.0" > skills/version.txt

# 2. 更新 CHANGELOG
# 3. 创建 tag
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# 4. GitHub Release
# 附带: changelog、升级说明、breaking changes（如有）
```

---

## 行为准则

- 尊重所有参与者
- 技术讨论就事论事
- 不在 PR 中进行无关争论
- 新人友好，耐心解答

---

## 联系方式

- Issues: [GitHub Issues](https://github.com/chengxuniucode/ForgeTeam/issues)
- Discussions: [GitHub Discussions](https://github.com/chengxuniucode/ForgeTeam/discussions)
