---
name: rbac
version: "1.0.0"
description: "基于角色的访问控制集成"
type: extension
triggers:
  - command: "/rbac"
  - auto: "proposal mentions 权限 OR 角色 OR access control"
requires:
  - core_skill: execute
  - extension: auth-sso
inputs:
  - 角色和权限需求描述
  - memory/project-map.md
outputs:
  - 权限模型代码
  - 中间件/守卫
  - 管理接口（可选）
---

# RBAC Skill

## 目标

为项目集成基于角色的访问控制（Role-Based Access Control）。
支持角色定义、权限分配、路由守卫和资源级权限检查。

## 执行步骤

### Step 1: 分析权限需求

从用户需求中提取：
- 需要哪些角色（admin, user, editor...）
- 每个角色的权限范围
- 是否需要资源级权限
- 是否需要层级角色

### Step 2: 生成权限模型

```typescript
// 示例结构
interface Permission {
  resource: string;
  action: 'create' | 'read' | 'update' | 'delete';
}

interface Role {
  name: string;
  permissions: Permission[];
  inherits?: string[];
}
```

### Step 3: 生成中间件/守卫

根据框架生成对应的权限检查中间件：
- Express: middleware function
- Next.js: middleware + HOC
- Spring Boot: @PreAuthorize annotations
- FastAPI: dependency injection

### Step 4: 生成管理接口（可选）

如果需要动态角色管理：
- 角色 CRUD 接口
- 用户-角色分配接口
- 权限查询接口

### Step 5: 更新路由配置

为需要权限保护的路由添加守卫。

### Step 6: 生成测试

- 权限检查单元测试
- 角色继承测试
- 未授权访问测试
