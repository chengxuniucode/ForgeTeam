---
name: deploy-k8s
version: "1.0.0"
description: "Kubernetes 部署配置生成"
type: extension
triggers:
  - command: "/deploy-k8s"
  - auto: "ship completed AND config has deploy-k8s"
requires:
  - core_skill: ship
inputs:
  - 项目构建产物信息
  - memory/project-map.md
outputs:
  - Dockerfile
  - K8s manifests (Deployment, Service, Ingress, ConfigMap, HPA)
  - Helm chart (可选)
  - CI/CD pipeline 配置
---

# Deploy K8s Skill

## 目标

为项目生成生产级 Kubernetes 部署配置，包括多阶段 Docker 构建、K8s 资源清单和可选的 Helm Chart。

## 执行步骤

### Step 1: 检测项目构建方式

根据 project-map.md 确定：
- 语言和运行时版本
- 构建命令和产物路径
- 运行时依赖
- 暴露端口

### Step 2: 生成 Dockerfile

多阶段构建，最小化镜像：
- Build stage: 编译/打包
- Runtime stage: 只包含运行时依赖
- 非 root 用户运行
- 健康检查指令

### Step 3: 生成 K8s Manifests

```
k8s/
├── deployment.yaml
├── service.yaml
├── ingress.yaml
├── configmap.yaml
├── hpa.yaml
└── kustomization.yaml
```

### Step 4: 生成 Helm Chart（可选）

如果 config 中启用：
```
chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
└── .helmignore
```

### Step 5: 配置 CI/CD Pipeline

根据平台生成：
- GitHub Actions workflow
- GitLab CI pipeline
- 包含 build → push → deploy 阶段

### Step 6: 验证

- Dockerfile 可构建
- K8s manifests 语法正确（kubectl --dry-run）
- Helm chart lint 通过（如适用）
