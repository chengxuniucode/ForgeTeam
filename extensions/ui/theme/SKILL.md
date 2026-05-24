---
name: ui-theme
version: "1.0.0"
description: "企业 UI 主题和设计系统集成"
type: extension
triggers:
  - command: "/ui-theme"
  - auto: "new frontend project"
requires:
  - core_skill: execute
inputs:
  - 企业设计规范（可选）
  - memory/project-map.md
outputs:
  - 主题配置文件
  - 设计 Token
  - 布局模板
---

# UI Theme Skill

## 目标

为前端项目集成企业 UI 主题和设计系统。
确保视觉一致性和品牌合规。

## 执行步骤

### Step 1: 检测前端框架

| 框架 | 主题方案 |
|------|---------|
| React + Tailwind | tailwind.config.js theme extension |
| React + MUI | createTheme() |
| Vue + Element | SCSS variables |
| Next.js | CSS variables + Tailwind |
| Angular + Material | Angular Material theming |

### Step 2: 安装企业 UI 组件库

如果企业有标准组件库：
```bash
npm install @company/ui-components
```

### Step 3: 配置主题变量/Token

生成设计 Token 文件：
```css
:root {
  /* Colors */
  --color-primary: #1a73e8;
  --color-secondary: #5f6368;
  --color-success: #34a853;
  --color-warning: #fbbc04;
  --color-error: #ea4335;

  /* Typography */
  --font-family: 'Inter', sans-serif;
  --font-size-base: 16px;
  --line-height-base: 1.5;

  /* Spacing */
  --spacing-unit: 8px;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
}
```

### Step 4: 生成布局模板

- 应用 Shell（Header + Sidebar + Content）
- 响应式断点配置
- 页面骨架模板

### Step 5: 设置暗色模式支持

- CSS 变量切换
- 系统偏好检测
- 用户偏好存储

### Step 6: 集成字体和图标资源

- Web 字体加载配置
- 图标库接入（SVG sprite / Icon font）
- 静态资源路径配置
