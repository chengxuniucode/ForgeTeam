---
name: safety-guard
version: "1.0.0"
description: "运行时安全防护，阻止危险操作"
triggers:
  - auto: "before any file write"
  - auto: "before any command execution"
  - auto: "before any git operation"
route_level: [micro, standard, full]
inputs:
  - 即将执行的操作
  - 安全规则配置
outputs:
  - allow | block | warn
next: null (inline check)
token_budget: 100
constraints:
  must:
    - "阻断 hard_blocks 列表中的操作"
  should:
    - "记录拦截日志便于审计"
---

# Safety Guard Skill

## 目标

作为持续运行的安全层，在任何危险操作执行前介入。
不是事后检查，而是事前拦截。

## 检查分类

### Level 1: 硬阻断（Block）

这些操作无论如何不允许执行：

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

这些操作需要用户明确确认：

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

这些操作允许执行但给出提醒：

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
    - pattern: "exec("
      message: "Command execution - ensure input is validated"
```

## 秘密检测

实时扫描即将写入的内容：

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

## 文件保护

```yaml
protected_files:
  never_modify:
    - ".git/config"
    - ".git/HEAD"
    - "~/.gitconfig" (global)

  never_delete:
    - ".forgeteam/"
    - "specs/"
    - ".env" (warn but allow)

  never_commit:
    - ".env"
    - "*.pem"
    - "*.key"
    - "*secret*"
    - "*credential*"
    - "*.p12"
```

## 响应速度

Safety Guard 必须是轻量级的：
- 正则匹配，不做语义分析
- 总延迟 < 50ms
- 不阻塞正常操作流程
- 不需要网络请求

## 配置覆盖

用户可以在 config.yaml 中调整：

```yaml
safety:
  level: "standard"      # paranoid | standard | relaxed
  allow_force_push: false
  allow_root_delete: false
  custom_blocks: []
  custom_allows: []
  secret_scan: true
```

## 审计日志

所有 block 和 confirm 操作都记录到 `.forgeteam/safety.log`：
```
[2024-01-15T10:30:00Z] BLOCK: rm -rf /tmp/project (matched hard_block)
[2024-01-15T10:31:00Z] CONFIRM: git push --force origin feature (user approved)
[2024-01-15T10:32:00Z] WARN: chmod 777 scripts/deploy.sh
```
