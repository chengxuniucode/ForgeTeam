---
name: data-migration
version: "1.0.0"
description: "数据库迁移脚本生成与管理"
type: extension
triggers:
  - command: "/migration"
  - auto: "plan contains 数据模型 OR 数据库 OR schema"
requires:
  - core_skill: execute
inputs:
  - 数据模型变更需求
  - memory/project-map.md
outputs:
  - 迁移脚本文件
  - 回滚脚本
---

# Data Migration Skill

## 目标

为数据模型变更生成安全的迁移脚本，支持版本化管理和回滚。

## 执行步骤

### Step 1: 检测迁移框架

| 框架 | 迁移工具 |
|------|---------|
| Spring Boot | Flyway / Liquibase |
| Django | django migrations |
| Node.js | Prisma / TypeORM / Knex |
| Go | golang-migrate / goose |
| Rust | diesel / sqlx |

### Step 2: 分析变更

从需求中提取：
- 新增表/字段
- 修改字段类型/约束
- 删除表/字段
- 索引变更
- 数据迁移（DML）

### Step 3: 生成迁移脚本

- 使用框架原生迁移格式
- 命名包含时间戳和描述
- 分离 DDL 和 DML
- 大表变更考虑在线 DDL

### Step 4: 生成回滚脚本

每个迁移必须有对应的回滚操作。

### Step 5: 验证

- 迁移脚本语法正确
- 回滚脚本可执行
- 不包含破坏性操作（除非显式确认）
