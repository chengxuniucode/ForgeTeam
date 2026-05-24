---
name: integration-mq
version: "1.0.0"
description: "消息队列集成（Kafka/RabbitMQ/RocketMQ）"
type: extension
triggers:
  - command: "/mq"
  - auto: "proposal mentions 消息 OR 异步 OR 事件驱动 OR queue"
requires:
  - core_skill: execute
inputs:
  - 消息场景描述
  - memory/project-map.md
outputs:
  - Producer/Consumer 代码
  - 消息模型定义
  - 配置文件
  - 错误处理和重试逻辑
---

# Message Queue Integration Skill

## 目标

为项目集成消息队列能力，支持异步通信、事件驱动和解耦场景。

## 执行步骤

### Step 1: 确定 MQ 选型

| 场景 | 推荐 |
|------|------|
| 高吞吐流式处理 | Kafka |
| 灵活路由 + 延迟消息 | RabbitMQ |
| 企业级事务消息 | RocketMQ |

### Step 2: 安装依赖

根据语言和 MQ 选型安装 SDK。

### Step 3: 生成代码

- Producer: 消息发送封装
- Consumer: 消息消费处理
- Model: 消息体定义
- Config: 连接配置（环境变量引用）
- Error handling: 死信队列、重试策略

### Step 4: 配置集成

- 连接参数走环境变量
- 序列化方式统一
- 消费者组命名规范
- 监控埋点

### Step 5: 验证

- 编译通过
- 连接配置正确（mock/本地验证）
- 消息序列化/反序列化正确
