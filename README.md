# ForgeTeam

> One person, full team delivery.

开源 AI 编码框架，让一个人拥有全栈团队的交付能力。纯 Shell + Markdown 架构，零依赖，3 分钟集成，适配 Claude Code / Cursor / Codex / OpenCode。

---

## 安装

```bash
# 一键安装
curl -sSL https://raw.githubusercontent.com/chengxuniucode/ForgeTeam/main/install.sh | bash

# 或手动安装
git clone https://github.com/chengxuniucode/ForgeTeam.git ~/.forgeteam
ln -sf ~/.forgeteam/forge /usr/local/bin/forge
```

## 初始化项目

```bash
cd your-project
forge init
```

执行后自动完成：
- 创建 `.forgeteam/` 目录（配置 + 记忆）
- 扫描项目生成 `project-map.md`
- 检测语言/框架/构建命令
- 生成 AI 工具配置文件（CLAUDE.md / .cursor/rules/ 等）

## 工作原理

ForgeTeam 由两层组成：

| 层 | 负责什么 | 执行者 |
|----|---------|--------|
| **CLI 层**（`forge` 命令） | 初始化、检测项目、生成配置、同步更新、运行验证 | 用户在终端执行 |
| **Skill 层**（14 个 SKILL.md） | 需求澄清、任务拆解、代码实现、评审、文档同步 | AI 工具在会话中执行 |

CLI 提供基础设施，Skill 提供行为指南。AI 工具读取 skill 文件作为工作流程指令，用户可随时通过 `forge verify` 独立验证代码质量，不依赖 AI 自称完成。

---

## 使用方式

**直接用自然语言描述需求，ForgeTeam 自动判定路由并执行。无需记住命令。**

```
用户: "修复登录页的 XSS 漏洞"
→ 自动判定 < 50 行 → Micro 路由 → 直接修复 → 验证 → 完成

用户: "添加用户导出为 CSV 的功能"
→ 自动判定 50-500 行 → Standard 路由 → 计划 → 实现 → 评审 → 验证 → 提交

用户: "重构认证系统为独立微服务"
→ 自动判定 > 500 行 → Full 路由 → 方案选型 → 计划 → 实现 → 评审 → 验证 → 提交
```

### 三种路由

| 路由 | 变更规模 | 自动流程 |
|------|---------|---------|
| Micro | < 50 行 | execute → verify → done |
| Standard | 50-500 行 | plan → [html] → execute → review → verify → ship |
| Full | > 500 行 | propose → [html] → plan → execute → review → verify → ship |

> `[html]` 表示涉及 UI/页面变更时自动插入原型确认环节，纯后端变更时跳过。

### 手动命令（可选）

在需要手动干预时使用 slash command：

| 命令 | 用途 |
|------|------|
| `/forge-propose` | 强制进入需求澄清和方案对比 |
| `/forge-html` | 生成静态 HTML 原型，浏览器确认交互后再开发 |
| `/forge-plan` | 手动触发任务拆解 |
| `/forge-execute` | 从中断恢复继续执行 |
| `/forge-review` | 手动触发代码评审 |
| `/forge-verify` | 手动运行四关验证 |
| `/forge-ship` | 手动提交并归档 |
| `/forge-debug` | 验证失败后提供指导再继续 |
| `/forge-checkpoint` | 会话结束前保存进度 |
| `/forge-onboard` | 重新扫描项目结构 |
| `/forge-learn` | 提取经验到记忆 |
| `/forge-evolve` | 评估生态变化并自进化 |
| `/forge-safety-guard` | 危险操作前安全检查 |
| `/forge-quality-gate` | 阶段切换质量门禁 |

详细说明见 [Skill 命令详解](docs/USAGE.md)

---

## 企业扩展

### 注册扩展

编辑 `.forgeteam/config.yaml`：

```yaml
extensions:
  skills:
    - "auth/sso"           # SSO 单点登录
    - "auth/rbac"          # 角色权限
    - "deploy/k8s"         # K8s 部署
    - "monitoring/logging" # 结构化日志
    - "data/migration"     # 数据库迁移
    - "integration/mq"     # 消息队列
    - "testing/e2e"        # E2E 测试
```

注册后重新生成配置：

```bash
forge generate --target claude
```

### 开发自定义 Skill

```bash
mkdir -p .forgeteam/extensions/skills/{category}/{name}
# 编写 SKILL.md（标准 frontmatter 格式）
# 注册到 config.yaml
# forge generate --target claude
```

### 团队共享

```bash
# 团队维护一个扩展仓库
git clone https://github.com/your-org/forge-skills.git .forgeteam/extensions/skills

# 在 config.yaml 中按需启用
```

### MCP Server 集成（规划中）

通过 `config.yaml` 的 `extensions.mcp_servers` 字段配置外部系统连接（公司 API、Jira 等）。

详细说明见 [extensions/README.md](extensions/README.md)

---

## 多平台适配

同一套 skill，生成不同 AI 工具的配置：

```bash
forge generate --target claude     # → CLAUDE.md + .claude/commands/
forge generate --target cursor     # → .cursor/rules/forgeteam.mdc
forge generate --target codex      # → codex.md
forge generate --target opencode   # → AGENTS.md
```

---

## CLI 命令

| 命令 | 说明 |
|------|------|
| `forge init` | 在当前项目初始化 |
| `forge onboard` | 重新扫描项目结构 |
| `forge generate --target X` | 生成 AI 工具配置 |
| `forge sync` | 同步上游 skill 更新 |
| `forge status` | 查看当前任务状态 |
| `forge config` | 查看配置 |
| `forge version` | 查看版本 |
| `forge verify` | 运行四关验证（Build→Test→Run→Safety） |
| `forge uninstall` | 卸载 ForgeTeam |

---

## 支持的语言

| 语言 | 框架 |
|------|------|
| TypeScript/JavaScript | Next.js, React, Vue, Express |
| Java | Spring Boot, Maven, Gradle |
| Go | Standard library |
| Rust | Cargo |
| Python | Django, FastAPI, pytest |

---

## 核心机制

- **自动路由** — 根据变更规模自动选择工作流，无需手动判断
- **编译器级验证** — Build → Test → Run → Safety 四关门禁，不靠 AI 自称完成
- **断路器** — 3 次修复失败自动暂停，等待人工介入
- **跨会话记忆** — 决策、偏好、已知问题跨会话保留，越用越聪明
- **自进化** — 持续感知 AI 编码生态变化，主动学习和融合新方向

---

## 文档

| 文档 | 内容 |
|------|------|
| [USAGE.md](docs/USAGE.md) | Skill 命令详解：流程、示例、断路器 |
| [extensions/README.md](extensions/README.md) | 扩展分类、目录结构、开发规范 |
| [ROADMAP.md](docs/ROADMAP.md) | 自进化策略和版本规划 |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | 如何参与贡献 |
| [evolution/](evolution/) | 进化提案 (EP) |

---

## License

MIT
