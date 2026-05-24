---
name: auth-sso
version: "1.0.0"
description: "企业 SSO 登录集成"
type: extension
triggers:
  - auto: "new_project AND config.extensions.skills contains 'auth-sso'"
  - command: "/auth-sso"
requires:
  - core_skill: execute
  - config: "extensions.auth_provider"
inputs:
  - config.yaml (auth_provider 配置)
  - memory/project-map.md
outputs:
  - 认证相关代码文件
  - 路由守卫配置
---

# Auth SSO Skill

## 目标

为项目集成企业 SSO 单点登录能力。
支持 OIDC、SAML、CAS 等主流协议。

## 前置条件

config.yaml 中需要配置：
```yaml
extensions:
  auth_provider:
    type: "oidc"                # oidc | saml | cas
    issuer: "https://sso.company.com"
    client_id: "${SSO_CLIENT_ID}"
    client_secret: "${SSO_CLIENT_SECRET}"
    redirect_uri: "/auth/callback"
    scopes: ["openid", "profile", "email"]
```

## 执行步骤

### Step 1: 检测框架

根据 project-map.md 中的框架信息选择集成方式：

| 框架 | 集成方式 |
|------|---------|
| Next.js | next-auth + provider |
| Express | passport + strategy |
| Spring Boot | spring-security-oauth2 |
| FastAPI | authlib |
| Go | golang.org/x/oauth2 |

### Step 2: 安装依赖

根据框架安装对应的认证库。

### Step 3: 生成认证代码

生成以下文件：
- 认证配置文件
- 登录/回调路由
- 中间件/守卫
- 用户 session 管理
- 登出处理

### Step 4: 配置集成

更新项目配置，确保：
- 环境变量引用正确（不硬编码）
- 回调地址可配置
- Token 刷新逻辑完整
- 错误处理到位

### Step 5: 验证

- 编译通过
- 认证流程可走通（mock 模式）
- 无密钥泄露

## 自定义点

企业可以覆盖：
- 登录页面模板
- 用户信息映射逻辑
- 角色权限映射
- Session 过期策略
