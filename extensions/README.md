# Extensions

企业扩展 Skill 按领域分类，每个类目下可包含多个独立 Skill。

## 目录结构

```
extensions/
├── auth/              # 认证与权限
│   ├── sso/           # SSO 单点登录
│   ├── rbac/          # 基于角色的访问控制
│   ├── oauth2/        # OAuth2 集成
│   └── jwt/           # JWT Token 管理
├── ui/                # 前端与 UI
│   ├── theme/         # 企业主题与设计系统
│   ├── i18n/          # 国际化
│   ├── form-builder/  # 动态表单生成
│   └── dashboard/     # 仪表盘模板
├── deploy/            # 部署与运维
│   ├── k8s/           # Kubernetes 部署
│   ├── docker/        # Docker 配置
│   ├── ci-github/     # GitHub Actions CI/CD
│   └── ci-gitlab/     # GitLab CI/CD
├── data/              # 数据与存储
│   ├── migration/     # 数据库迁移
│   ├── cache-redis/   # Redis 缓存集成
│   ├── orm-setup/     # ORM 初始化
│   └── search/        # 搜索引擎集成
├── integration/       # 第三方集成
│   ├── mq/            # 消息队列
│   ├── oss/           # 对象存储
│   ├── sms/           # 短信服务
│   └── payment/       # 支付集成
├── testing/           # 测试增强
│   ├── e2e/           # E2E 测试框架
│   ├── load-test/     # 压力测试
│   └── mock-server/   # Mock 服务
└── monitoring/        # 可观测性
    ├── logging/       # 日志体系
    ├── metrics/       # 指标采集
    ├── tracing/       # 链路追踪
    └── alerting/      # 告警配置
```

## 命名规范

- 目录名使用 kebab-case
- 每个 Skill 一个独立目录，包含 `SKILL.md`
- 类目目录可包含 `README.md` 说明该类目的通用约束

## 注册方式

在项目 `.forgeteam/config.yaml` 中按 `{category}/{name}` 引用：

```yaml
extensions:
  skills:
    - "auth/sso"
    - "auth/rbac"
    - "deploy/k8s"
    - "monitoring/logging"
```

## 开发新 Skill

```bash
# 1. 在对应类目下创建目录
mkdir -p extensions/{category}/{skill-name}

# 2. 编写 SKILL.md（遵循标准 frontmatter 格式）
# 必须包含: name, version, description, type: extension, triggers

# 3. 重新生成平台文件
forge generate --target claude
```
