# ForgeTeam PreToolUse Safety Hook

## 触发时机

任何工具执行前自动检查。

## 检查规则

### 硬阻断 (Block)

以下操作无条件阻止：

```yaml
blocked_patterns:
  - pattern: "rm -rf /"
    action: block
    message: "Dangerous: recursive root deletion blocked"

  - pattern: "git push.*--force.*main"
    action: block
    message: "Force push to main/master blocked"

  - pattern: "git push.*--force.*master"
    action: block
    message: "Force push to main/master blocked"

  - pattern: "DROP TABLE|DROP DATABASE"
    action: confirm
    message: "Destructive SQL detected, confirm?"

  - pattern: "chmod 777"
    action: warn
    message: "Overly permissive permissions"
```

### 秘密检测

扫描即将写入的内容：

```yaml
secret_patterns:
  - "(?i)(api[_-]?key|secret|password|token)\\s*[:=]\\s*['\"][^'\"]{8,}"
  - "(?i)aws[_-]?(access|secret)"
  - "-----BEGIN (RSA |EC )?PRIVATE KEY-----"
```

### 文件保护

```yaml
file_protections:
  - ".env*"
  - "*.pem"
  - "*.key"
  - "*credentials*"
```

## 实现方式

此 hook 通过 AI 工具的 PreToolUse 机制注入：
- Claude Code: `.claude/settings.json` hooks 配置
- Cursor: 内置于 rules 中
- 其他平台: 通过 skill 指令约束
