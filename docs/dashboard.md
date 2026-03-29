# 仪表盘 · Dashboard

## 概述

内阁都察制使用 [OpenClaw Bot Dashboard](https://github.com/xmanrui/OpenClaw-bot-review) 作为可视化监控面板。这是一个轻量级 Web 应用，直接读取本地 OpenClaw 配置，无需数据库。

## 功能一览

| 功能 | 说明 |
|------|------|
| 🤖 Bot 总览 | 卡片墙展示所有 Agent、模型、平台绑定状态 |
| 🧠 模型列表 | 所有 Provider 和模型配置，支持单模型测试 |
| 💬 会话管理 | 按 Agent 浏览会话，Token 用量统计 |
| 📊 消息统计 | Token 消耗趋势、平均响应时间，SVG 图表 |
| 🔧 技能管理 | 已安装 Skill 搜索和筛选 |
| 🚨 告警中心 | 模型不可用/无响应告警，飞书通知 |
| 🏥 Gateway 健康 | 实时状态指示，10s 自动轮询 |
| 🎮 Pixel Office | 像素风 Agent 办公室动画 |

## 快速启动

```bash
# 克隆
git clone https://github.com/xmanrui/OpenClaw-bot-review.git
cd OpenClaw-bot-review

# 安装
npm install

# 启动
npm run start
```

浏览器访问 http://localhost:3000

## Docker 部署

```bash
docker build -t openclaw-dashboard .
docker run -d -p 3000:3000 openclaw-dashboard
```

自定义配置路径：

```bash
docker run -d --name openclaw-dashboard -p 3000:3000 \
  -e OPENCLAW_HOME=/opt/openclaw \
  -v /path/to/openclaw:/opt/openclaw \
  openclaw-dashboard
```

## 与内阁都察制的对应

| 仪表盘功能 | 对应部门 | 用途 |
|-----------|---------|------|
| Bot 总览 | 东厂 | Agent 状态监控 |
| 消息统计 | 户部 | 成本核算 |
| Gateway 健康 | 东厂 | 系统可用性 |
| 告警中心 | 东厂 | 异常检测 |
| 技能管理 | 吏部 | Skill 清点 |

## 前置条件

- Node.js 18+
- OpenClaw 已安装，配置文件 `~/.openclaw/openclaw.json` 存在

## 配置

默认读取 `~/.openclaw/openclaw.json`。自定义路径：

```bash
OPENCLAW_HOME=/opt/openclaw npm run start
```
