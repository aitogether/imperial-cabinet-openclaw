# 三步上手 · Getting Started

## 前置条件

- 已安装 [OpenClaw](https://docs.openclaw.ai)（v1.0+）
- 已配置至少一个 AI 模型（如 OpenRouter、OpenAI、Anthropic 等）

## 第一步：克隆仓库

```bash
git clone https://github.com/yourname/imperial-cabinet-openclaw.git
cd imperial-cabinet-openclaw
```

## 第二步：配置 OpenClaw

```bash
# 拷贝配置模板
cp config/openclaw.example.yaml ~/.openclaw/openclaw.yaml
```

编辑 `~/.openclaw/openclaw.yaml`：

1. 确认 `workspace` 路径指向你的工作目录（默认 `~/.openclaw/workspace`）
2. 在模型配置部分填入你使用的模型和 API 密钥
3. 根据需要启用或禁用特定 Agent

> ⚠️ **安全提示**: 不要将 API 密钥硬编码在配置文件中，使用环境变量引用（如 `${OPENROUTER_API_KEY}`）。

## 第三步：初始化工作区

```bash
bash scripts/init-workspace.sh
```

这个脚本会：
- 创建 `~/.openclaw/workspace` 目录（如不存在）
- 将模板文件拷贝为实际配置（如目标文件不存在）
- **不会覆盖**你已有的任何文件

## 启动对话

```bash
openclaw gateway start
```

现在你可以通过 OpenClaw 与「御前首辅」对话了。

## 验证安装

在对话中输入：

```
请列出所有已注册的 Agent 及其职责
```

如果御前首辅正确回答了 11 个 Agent 的信息，说明配置成功。

## 自定义

### 裁剪 Agent

如果不需要全部 11 个 Agent，可以在 `openclaw.yaml` 中只保留需要的部分。最小配置：

```yaml
agents:
  main:
    path: "~/.openclaw/agents/main"
    router_enabled: true
  # 只保留你需要的部
  engineering:
    path: "~/.openclaw/agents/engineering"
  content:
    path: "~/.openclaw/agents/content"
```

### 修改人格

编辑 `~/.openclaw/workspace/SOUL.md` 来自定义御前首辅的性格、沟通风格和工作原则。

### 添加新部门

1. 在 `~/.openclaw/agents/` 下创建新目录
2. 添加 `AGENTS.md`（职责定义）和 `config.yaml`（配置）
3. 在 `~/.openclaw/openclaw.yaml` 中注册
4. 在 `AGENTS.md` 架构总览中更新
