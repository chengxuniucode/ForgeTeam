# ForgeTeam

**[中文](README.md) | English**

> One person, full team delivery.

Open-source AI coding framework that gives one person the delivery capability of a full-stack team. Pure Shell + Markdown architecture, zero dependencies, 3-minute integration, compatible with Claude Code / Cursor / Codex / OpenCode.

---

## Installation

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/chengxuniucode/ForgeTeam/main/install.sh | bash

# Or manual install
git clone https://github.com/chengxuniucode/ForgeTeam.git ~/.forgeteam
ln -sf ~/.forgeteam/forge /usr/local/bin/forge
```

## Initialize a Project

```bash
cd your-project
forge init
```

This automatically:
- Creates `.forgeteam/` directory (config + memory)
- Scans the project to generate `project-map.md`
- Detects language/framework/build commands
- Generates AI tool config files (CLAUDE.md / .cursor/rules/ etc.)

## How It Works

ForgeTeam consists of two layers:

| Layer | Responsibility | Executor |
|-------|---------------|----------|
| **CLI Layer** (`forge` command) | Init, detect project, generate config, sync updates, run verification | User in terminal |
| **Skill Layer** (10 SKILL.md files) | Requirement clarification, task breakdown, code implementation, review, doc sync | AI tool in session |

The CLI provides infrastructure; Skills provide behavioral guidance. AI tools read skill files as workflow instructions. Users can independently verify code quality at any time via `forge verify`, without relying on AI self-reporting completion.

---

## Usage

**Simply describe your requirements in natural language — ForgeTeam automatically determines routing and executes. No commands to memorize.**

```
User: "Fix the XSS vulnerability on the login page"
→ Auto-detect < 50 lines → Micro route → Direct fix → Verify → Done

User: "Add CSV export for users"
→ Auto-detect 50-500 lines → Standard route → Plan → Implement → Review → Verify → Ship

User: "Refactor auth system into an independent microservice"
→ Auto-detect > 500 lines → Full route → Proposal → Plan → Implement → Review → Verify → Ship
```

### Three Routes

| Route | Change Size | Automated Flow |
|-------|-------------|----------------|
| Micro | < 50 lines | execute → verify → done |
| Standard | 50-500 lines | plan → [html] → execute → review → verify → ship |
| Full | > 500 lines | propose → [html] → plan → execute → review → verify → ship |

> `[html]` indicates an automatic prototype confirmation step for UI/page changes; skipped for pure backend changes.

### Manual Commands (Optional)

Use slash commands when manual intervention is needed:

| Command | Purpose |
|---------|---------|
| `/forge-propose` | Force requirement clarification and solution comparison |
| `/forge-html` | Generate static HTML prototype, confirm in browser before development |
| `/forge-plan` | Manually trigger task breakdown |
| `/forge-execute` | Resume execution from interruption |
| `/forge-review` | Manually trigger code review |
| `/forge-verify` | Run verification (safety guard + stage gates + 4-gate verification) |
| `/forge-ship` | Manually commit and archive |
| `/forge-debug` | Provide guidance after verification failure, then continue |
| `/forge-memory` | Save progress + extract lessons to memory |
| `/forge-evolve` | Assess ecosystem changes and self-evolve |
| `/forge-onboard` | Re-scan project structure |

See [Skill Command Reference](docs/USAGE.md) for details.

---

## Enterprise Extensions

### Register Extensions

Edit `.forgeteam/config.yaml`:

```yaml
extensions:
  skills:
    - "auth/sso"           # SSO single sign-on
    - "auth/rbac"          # Role-based access control
    - "deploy/k8s"         # K8s deployment
    - "monitoring/logging" # Structured logging
    - "data/migration"     # Database migration
    - "integration/mq"     # Message queue
    - "testing/e2e"        # E2E testing
```

Regenerate config after registration:

```bash
forge generate --target claude
```

### Develop Custom Skills

```bash
mkdir -p .forgeteam/extensions/skills/{category}/{name}
# Write SKILL.md (standard frontmatter format)
# Register in config.yaml
# forge generate --target claude
```

### Team Sharing

```bash
# Team maintains an extension repository
git clone https://github.com/your-org/forge-skills.git .forgeteam/extensions/skills

# Enable as needed in config.yaml
```

### MCP Server Integration (Planned)

Configure external system connections (company APIs, Jira, etc.) via the `extensions.mcp_servers` field in `config.yaml`.

See [extensions/README.md](extensions/README.md) for details.

---

## Multi-Platform Support

Same skills, different AI tool configurations:

```bash
forge generate --target claude     # → CLAUDE.md + .claude/commands/
forge generate --target cursor     # → .cursor/rules/forgeteam.mdc
forge generate --target codex      # → codex.md
forge generate --target opencode   # → AGENTS.md
```

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `forge init` | Initialize in current project |
| `forge onboard` | Re-scan project structure |
| `forge generate --target X` | Generate AI tool config |
| `forge sync` | Sync upstream skill updates |
| `forge status` | View current task status |
| `forge config` | View configuration |
| `forge version` | View version |
| `forge verify` | Run 4-gate verification (Build→Test→Run→Safety) |
| `forge uninstall` | Uninstall ForgeTeam |

---

## Supported Languages

| Language | Frameworks |
|----------|-----------|
| TypeScript/JavaScript | Next.js, React, Vue, Express |
| Java | Spring Boot, Maven, Gradle |
| Go | Standard library |
| Rust | Cargo |
| Python | Django, FastAPI, pytest |

---

## Core Mechanisms

- **Auto-routing** — Automatically selects workflow based on change size, no manual judgment needed
- **Compiler-level verification** — Build → Test → Run → Safety 4-gate checks, not relying on AI self-reporting
- **Circuit breaker** — Auto-pauses after 3 failed fixes, awaiting human intervention
- **Cross-session memory** — Decisions, preferences, known issues persist across sessions, gets smarter over time
- **Self-evolution** — Continuously senses AI coding ecosystem changes, proactively learns and integrates new directions

---

## Documentation

| Document | Content |
|----------|---------|
| [USAGE.md](docs/USAGE.md) | Skill command reference: flows, examples, circuit breaker |
| [extensions/README.md](extensions/README.md) | Extension categories, directory structure, development standards |
| [ROADMAP.md](docs/ROADMAP.md) | Self-evolution strategy and version roadmap |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | How to contribute |
| [evolution/](evolution/) | Evolution Proposals (EP) |

---

## License

MIT
