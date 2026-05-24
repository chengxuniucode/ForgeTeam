---
name: testing-e2e
version: "1.0.0"
description: "E2E 测试框架集成（Playwright/Cypress）"
type: extension
triggers:
  - command: "/e2e"
  - auto: "config.extensions.skills contains 'testing/e2e'"
requires:
  - core_skill: verify
inputs:
  - 关键用户流程描述
  - memory/project-map.md
outputs:
  - E2E 测试配置
  - 测试用例模板
  - CI 集成配置
---

# E2E Testing Skill

## 目标

为项目集成端到端测试能力，覆盖关键用户流程，确保功能回归保护。

## 执行步骤

### Step 1: 选择测试框架

| 场景 | 推荐 |
|------|------|
| Web 应用（通用） | Playwright |
| React 生态优先 | Cypress |
| API 为主 | Playwright (API mode) |
| 移动端 | Detox / Appium |

### Step 2: 安装与配置

- 安装测试框架
- 生成配置文件
- 配置 baseURL 和环境变量
- 设置 reporter

### Step 3: 生成测试模板

- Page Object 模式基础结构
- 关键流程测试用例骨架
- 测试数据工厂
- 公共 fixture

### Step 4: CI 集成

- 添加 E2E 测试到 CI pipeline
- 配置浏览器环境
- 并行执行策略
- 失败截图/视频保存

### Step 5: 验证

- 测试框架可启动
- 示例用例可执行
- CI 配置语法正确
