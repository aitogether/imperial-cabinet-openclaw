# 🐲 内阁都察制 · 一人公司多 Agent 治理框架
适合对象：已经在用 OpenClaw 的个人开发者 / 小团队，有意把日常工作流交给多 Agent 接手。
不适合：完全没接触过 OpenClaw、希望一键 SaaS 化的人。
当前状态：实验性 Alpha，接口可能会变动
> **Imperial Cabinet & Censorate System for Solo-Entrepreneurs**
> A multi-agent orchestration framework based on OpenClaw, using traditional Chinese bureaucratic metaphors for task governance.

---

## 项目简介

本项目是基于 [OpenClaw](https://docs.openclaw.ai) 的 **多 Agent 治理框架**，面向一人公司、独立开发者和小团队。

我们采用「内阁 + 八部一厂 + 御史台」的传统官制隐喻来组织 AI Agent 的协作：

- **皇帝**：人类决策者，只做批示与拍板，不写命令和代码
- **御前首辅（Grand Secretary）**：唯一的 AI 入口，负责统筹、拆解、路由、监督
- **八部**：内阁（规划）、工部（技术）、户部（财务）、兵部（安全）、吏部（运营）、礼部（文案）、刑部（合规）、翰林院（文档）
- **一厂**：东厂（监控与审计）
- **御史台（Censorate）**：专职审核与封驳，把关质量底线

### 核心特点

| 特点 | 说明 |
|------|------|
| 🎯 零额外依赖 | 纯 OpenClaw 原生，不需要 Docker、Web 后端或前端 |
| 📋 文档驱动 | 用 Markdown 文件定义人设、规则和流程，开箱即用 |
| 🔄 渐进式严格 | 先用约定，再逐步程序化为严格状态机和看板 |
| 🏗️ 可逐步裁剪 | 11 个 Agent 可以按需裁剪，最小只需御前首辅 + 2~3 个部 |

---

## English Overview

**Imperial Cabinet & Censorate** is a multi-agent governance framework built on [OpenClaw](https://docs.openclaw.ai). It uses traditional Chinese bureaucratic metaphors — Emperor, Grand Secretary, Eight Ministries, Censorate, and Eastern Depot — to orchestrate AI agents for solo-entrepreneurs and small teams.

**Key design principles:**
- Zero extra backend dependencies (pure OpenClaw native)
- Document-first: all personas, rules, and workflows defined in Markdown
- Progressive strictness: start with conventions, evolve toward state machines and dashboards
- Modular: use all 11 agents or trim down to 3–4 as needed

---

## 快速开始（Quickstart）

### 前置条件

- 安装 [OpenClaw](https://docs.openclaw.ai)（v1.0+）
- 至少配置一个 AI 模型（OpenRouter / OpenAI / Anthropic 等）

### 三步上手

```bash
# 1. 克隆仓库
git clone https://github.com/yourname/imperial-cabinet-openclaw.git
cd imperial-cabinet-openclaw

# 2. 拷贝配置模板（根据本地路径和模型修改）
cp config/openclaw.example.yaml ~/.openclaw/openclaw.yaml
# 编辑 openclaw.yaml，填入你的模型配置和 API 密钥

# 3. 初始化工作区
bash scripts/init-workspace.sh

# 4. 启动 OpenClaw，开始与御前首辅对话
openclaw gateway start
```

详细文档请参阅 [docs/getting-started.md](docs/getting-started.md)。

---

## 致敬与差异说明

本项目在设计理念上深受 [Edict](https://github.com/cft0808/edict)启发。Edict 是社区里的一个三省六部制多 Agent 框架，实现了门下省审核和军机处看板等机制。

**我们明确致敬 Edict，但两者定位不同：**

| 维度 | Edict | 内阁都察制 |
|------|-------|-----------|
| 目标用户 | 通用多 Agent 协作 | 一人公司 / 小团队 |
| 技术栈 | Python + React + Docker | 纯 OpenClaw 原生 |
| 额外依赖 | 需要部署后端 + 前端 | 零额外依赖 |
| 审核机制 | 程序化封驳（门下省） | 约定化审核（御史台） |
| 可观测性 | 完整 Web Dashboard | 轻量 Markdown + Canvas |
| 架构风格 | 流程驱动（严格状态机） | 文档驱动（渐进式严格） |

**本仓库为独立实现，不复制 Edict 任何代码，仅在理念上参考其公开的设计思路。**

---

## 目录结构

```
.
├── README.md                  # 本文件
├── LICENSE                    # MIT License
├── .gitignore                 # Git 忽略规则
├── config/
│   └── openclaw.example.yaml  # OpenClaw 配置示例
├── workspace-templates/
│   ├── USER.example.md        # 用户画像模板
│   ├── SOUL.example.md        # 御前首辅人设模板
│   ├── AGENTS.example.md      # 架构总览模板
│   └── MEMORY.example.md      # 长期规则模板
├── docs/
│   ├── architecture.md        # 架构详解
│   ├── getting-started.md     # 三步上手
│   ├── governance.md          # 治理规则（状态机 + 权限矩阵）
│   └── faq.md                 # 常见问题
├── examples/
│   ├── solo-content-pipeline.md   # 一人公司内容流水线示例
│   └── automation-income-flow.md  # 自动化收入流示例
└── scripts/
    └── init-workspace.sh      # 工作区初始化脚本
```

---

## 许可证

本项目采用 [MIT License](LICENSE) 开源。

---

## 参考资料

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Edict](https://github.com/cft0808/edict) 我们的设计启发来源
- [OpenClaw 社区](https://discord.com/invite/clawd)
# imperial-cabinet-openclaw
