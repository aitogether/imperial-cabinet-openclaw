# 常见问题 · FAQ

## 与 Edict 有什么不同？

[Edict](https://github.com/anthropics/edict) 是 Anthropic 推出的多 Agent 治理框架，同样使用中国传统官制隐喻，我们深受其启发。

主要区别：

| 维度 | Edict | 内阁都察制 |
|------|-------|-----------|
| 技术栈 | Python + React + Docker | 纯 OpenClaw 原生 |
| 额外依赖 | 需要部署后端 + 前端 | 零额外依赖 |
| 审核机制 | 程序化封驳（门下省） | 约定化审核（御史台） |
| 可观测性 | 完整 Web Dashboard | Markdown + Canvas |
| 架构风格 | 流程驱动（严格状态机） | 文档驱动（渐进式严格） |
| 目标用户 | 通用多 Agent 协作 | 一人公司 / 小团队 |

**本仓库为独立实现，不复制 Edict 任何代码，仅在理念上参考其公开的设计思路。**

## 必须 11 个 Agent 吗？

不是。11 个 Agent 是完整配置，你可以根据实际需要裁剪：

**最小配置**（3 个 Agent）：
- 御前首辅（main）：调度中枢
- 工部（engineering）：技术实现
- 礼部（content）：内容产出

**推荐起步配置**（5 个 Agent）：
- 御前首辅（main）
- 内阁（cabinet）：任务拆解
- 工部（engineering）
- 礼部（content）
- 东厂（monitor）：基本审计

在 `openclaw.yaml` 中删除不需要的 Agent 配置即可。

## 怎么看待性能和成本？

### 模型选择

- **御前首辅**: 建议使用较强的模型（如 GPT-4 Turbo、Claude 3.5 Sonnet），因为它是调度中枢
- **各部**: 可以使用较便宜的模型（如 GPT-4o Mini），执行具体任务
- **御史台**: 建议使用较强的模型，审核需要判断力

### 成本控制

- 利用 Skill 优先规则，避免重复造轮子
- 东厂监控 Token 消耗，定期复盘
- 户部负责成本分析和 ROI 评估

## 本地模型 vs 远程模型？

两种都支持：

- **远程模型**（OpenRouter / OpenAI / Anthropic）：开箱即用，质量较高
- **本地模型**（Ollama / llama.cpp）：免费、隐私好、但质量可能不如远程

建议：御前首辅和御史台用远程模型，各部可以用本地模型。

## 我不想叫「皇帝」，可以改吗？

当然可以。所有称呼（皇帝、御前首辅、八部等）都是可以自定义的。编辑以下文件即可：

- `USER.md`：你的自称
- `SOUL.md`：御前首辅对你的称呼
- `AGENTS.md`：各部的名称和职责

框架的核心是「单一入口 + 分工协作 + 审核把关」，与具体称呼无关。

## 怎么添加自定义 Agent？

1. 在 `~/.openclaw/agents/` 下创建新目录（如 `my-custom-agent/`）
2. 创建 `AGENTS.md`：定义职责、输出、典型任务
3. 创建 `config.yaml`：配置 agentId、模型、能力
4. 在 `~/.openclaw/openclaw.yaml` 中注册
5. 在 `AGENTS.md` 架构总览中更新

## 遇到问题怎么办？

1. 查看 [OpenClaw 官方文档](https://docs.openclaw.ai)
2. 加入 [OpenClaw 社区 Discord](https://discord.com/invite/clawd)
3. 在本仓库提交 Issue
