---
name: monitoring-logging
version: "1.0.0"
description: "结构化日志体系集成"
type: extension
triggers:
  - command: "/logging"
  - auto: "new_project AND config.extensions.skills contains 'monitoring/logging'"
requires:
  - core_skill: execute
inputs:
  - memory/project-map.md
outputs:
  - 日志配置文件
  - Logger 工具封装
  - 日志格式规范
---

# Logging Skill

## 目标

为项目建立统一的结构化日志体系，支持本地开发和生产环境不同输出格式。

## 执行步骤

### Step 1: 检测框架与选择日志库

| 语言 | 推荐库 |
|------|--------|
| TypeScript | pino / winston |
| Java | SLF4J + Logback |
| Go | zerolog / zap |
| Python | structlog / loguru |
| Rust | tracing |

### Step 2: 配置日志格式

- 开发环境: 彩色可读格式
- 生产环境: JSON 结构化格式
- 必含字段: timestamp, level, message, traceId, service

### Step 3: 生成 Logger 封装

- 统一的 logger 实例创建
- 上下文注入（requestId, userId）
- 日志级别动态调整
- 敏感信息脱敏

### Step 4: 配置日志输出

- 文件轮转策略
- 标准输出（容器场景）
- 远程采集配置（ELK / Loki）

### Step 5: 验证

- 日志输出格式正确
- 敏感字段已脱敏
- 性能影响可接受
