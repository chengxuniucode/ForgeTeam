---
name: onboard
version: "1.0.0"
description: "项目画像生成，扫描项目结构并写入 memory"
triggers:
  - auto: "!exists(.forgeteam/memory/project-map.md)"
  - command: "/onboard"
route_level: [micro, standard, full]
inputs:
  - project_root_files
outputs:
  - .forgeteam/memory/project-map.md
next: null
token_budget: 1500
constraints:
  must:
    - "生成 project-map.md"
  should:
    - "检测并记录配置文件和构建命令"
---

# Onboard Skill

## 目标

首次接触项目时，自动扫描并生成项目画像，让后续所有 skill 都能快速理解项目上下文。
类似新员工入职第一天快速了解项目。

## 触发时机

- 项目中不存在 `.forgeteam/memory/project-map.md` 时自动触发
- 用户执行 `/onboard` 或 `forge onboard` 时手动触发
- `forge init` 完成后自动执行一次

## 执行步骤

### Step 1: 检测项目类型

扫描根目录文件，判断：

| 检测文件 | 项目类型 |
|---------|---------|
| package.json | Node.js |
| pom.xml | Java/Maven |
| build.gradle | Java/Gradle |
| go.mod | Go |
| Cargo.toml | Rust |
| requirements.txt / pyproject.toml | Python |
| *.sln / *.csproj | .NET |
| Makefile (only) | C/C++ |

### Step 2: 提取项目元数据

从检测到的配置文件中提取：
- 项目名称
- 版本
- 核心依赖列表（top 10）
- scripts/命令定义
- 入口文件

### Step 3: 扫描目录结构

生成 top-2-level 目录树，排除：
- node_modules/
- .git/
- dist/ / build/ / target/
- __pycache__/
- vendor/

### Step 4: 识别关键文件

自动识别并记录：
- 配置文件（.env.example, config/*, application.yml）
- 路由/接口定义
- 数据模型/Schema
- 测试目录
- CI/CD 配置

### Step 5: 检测命令

识别可用命令：
- `npm scripts` → test, build, start, dev
- `Makefile targets` → build, test, run
- `gradle tasks` → build, test, bootRun
- `go` → go build, go test

### Step 6: 写入 project-map.md

将上述信息写入 `.forgeteam/memory/project-map.md`，格式：

```markdown
# Project Map

## 基础信息
- 名称: {name}
- 类型: {type}
- 语言: {language}
- 框架: {framework}
- 版本: {version}

## 构建与运行
- 包管理: {package_manager}
- 构建命令: {build_cmd}
- 测试命令: {test_cmd}
- 启动命令: {start_cmd}
- 开发命令: {dev_cmd}

## 目录结构
{tree output}

## 关键文件
- 入口: {entry}
- 配置: {configs}
- 路由: {routes}
- 模型: {models}
- 测试: {tests}

## 依赖摘要
### 核心依赖
{top 10 with versions}

### 开发依赖
{key dev deps}

## 备注
- 生成时间: {timestamp}
- 最后更新: {timestamp}
```

## 增量更新

如果 project-map.md 已存在：
- 只更新变化的部分
- 保留人工添加的备注
- 更新"最后更新"时间戳

## 不做的事

- 不读取源代码内容（只看结构）
- 不执行任何命令（只读取文件）
- 不修改项目文件（只写 memory）
