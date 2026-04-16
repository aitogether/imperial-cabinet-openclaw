# 🏛️ OpenClaw 架构文档

本文档描述 OpenClaw（内阁都察制）的内部结构与工作流映射。

---

## 1. Agent 角色与职责

OpenClaw 采用「内阁都察制」治理模型，每个 Agent 对应一个官僚角色：

| 角色 | 职责 | 输出产物 |
|------|------|----------|
| **御前内阁 (Emperor)** | 顶层决策者，接收任务并分派给六部 | Task spec |
| **内阁大学士 (Chancellor)** | 总协调人，监督各阶段进度 | Phase status |
| **吏部尚书 (Minister of Personnel)** | 人员配置与权限管理 | Role assignment |
| **工部尚书 (Minister of Works)** | 执行具体任务（编码、写作、调研） | Artifacts (code, doc) |
| **都察院 (Censorate)** | 质量审查与合规检查 | Review report |
| **通政司 (Communication)** | 对外交互（GitHub、邮件、Slack） | PR / Notification |

### 技能（Skill）映射

每个角色绑定一个或多个 Skill：
- `research` → 吏部 / 都察院（信息收集与验证）
- `write` → 工部（内容生成）
- `code` → 工部（代码实现）
- `review` → 都察院（合规审查）
- `publish` → 通政司（发布）

---

## 2. 工作流阶段（Workflow Phases）

一个完整的 OpenClaw 流程分为 **立案 → 调研 → 起草 → 复核 → 定稿** 五个阶段：

```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│   立案   │──▶│   调研   │──▶│   起草   │──▶│   复核   │──▶│   定稿   │
│  Issue  │   │ Research│   │  Draft  │   │ Review  │   │  Done   │
└─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
      │             │             │             │             │
      ▼             ▼             ▼             ▼             ▼
   Emperor     Chancellor     Minister     Censorate     Emperor
   (决策)       (协调)        (执行)       (审查)        (验收)
```

### 阶段说明

1. **立案（Case Filing）**
   - 输入：GitHub Issue / 用户需求描述
   - 输出：结构化任务卡（Task Card）
   - 负责：Emperor（御前内阁）
   - 产出：`task.yaml`

2. **调研（Research）**
   - 输入：Task Card
   - 输出：背景资料 + 可行性报告（`brief.md`）
   - 负责：Chancellor（内阁大学士）协调，吏部执行调研
   - 产出：`research/` 目录

3. **起草（Drafting）**
   - 输入：Task Card + brief.md
   - 输出：代码补丁 / 文档草稿（`patch.diff` / `draft.md`）
   - 负责：工部尚书（Minister of Works）
   - 产出：`draft/` 目录

4. **复核（Review）**
   - 输入：Draft artifacts
   - 输出：审查意见 + 通过/驳回决定（`review.json`）
   - 负责：都御史（Censorate Lead）
   - 产出：`reviews/` 目录

5. **定稿（Finalization）**
   - 输入：Approved draft
   - 输出：PR / Release / Report（最终交付物）
   - 负责：Emperor + 通政司
   - 产出：GitHub PR / Email / Slack 通知

---

## 3. 配置映射（Configuration → Flow）

OpenClaw 的流程由 YAML 配置文件驱动，每个阶段映射到具体的 Skill：

```yaml
flow:
  name: standard-pipeline
  stages:
   立案:
     agent: emperor
     skill: plan
     input: issue.body
     output: task.yaml

   调研:
     agent: chancellor
     skill: research
     input: task.yaml
     output: brief.md

   起草:
     agent: minister
     skill: write
     input: brief.md
     output: patch.diff

   复核:
     agent: censor
     skill: review
     input: patch.diff
     output: review.json

   定稿:
     agent: emperor
     skill: publish
     input: review.approved ? patch.diff : null
     output: github-pr
```

### 关键配置项

- `agent`：指定哪个角色负责该阶段（对应 Agent 身份）
- `skill`：绑定哪个 Skill（决定能力边界）
- `input` / `output`：上下游文件依赖
- `condition`：条件分支（例如只有 review.approved 才进入定稿）

---

## 4. 数据流与存储

```
┌─────────────┐
│   GitHub    │ ← Webhook 触发
│   Issue     │
└──────┬──────┘
       │
       ▼
┌─────────────┐    ┌──────────┐    ┌──────────┐
│  Emperor    │───▶│ Chancellor│───▶│ Minister │
│  (Plan)     │    │(Research) │    │ (Write)  │
└──────┬──────┘    └────┬─────┘    └────┬─────┘
       │               │               │
       ▼               ▼               ▼
   task.yaml      brief.md      patch.diff
                               │
                               ▼
                        ┌────────────┐
                        │ Censorate  │
                        │ (Review)   │
                        └──────┬─────┘
                               │
                               ▼
                          review.json
                               │
                               ▼
                        ┌────────────┐
                        │ Emperor    │
                        │ (Publish)  │
                        └────────────┘
                               │
                               ▼
                           GitHub PR
```

所有中间产物（`task.yaml`, `brief.md`, `patch.diff`, `review.json`）均存储在仓库的 `.openclaw/` 目录下，便于追溯与审计。

---

## 5. 扩展与自定义

### 添加新 Agent 角色

在 `agents/` 目录下新增 `my-agent.py`，继承 `BaseAgent` 并实现 `run()` 方法：

```python
from openclaw import BaseAgent

class MyAgent(BaseAgent):
    def run(self, input_data):
        # 自定义处理逻辑
        return {"output": "processed"}
```

然后在 `flow.yml` 中引用：

```yaml
stages:
  custom:
    agent: my-agent
    skill: custom
```

### 自定义 Skill

Skill 是 Agent 的能力单元，在 `skills/` 目录下定义：

```python
from openclaw import Skill

class MySkill(Skill):
    def execute(self, context):
        # 业务逻辑
        return result
```

---

## 6. 监控与运维

- **日志**：所有 Agent 运行日志写入 `.openclaw/logs/`
- **指标**：Prometheus 格式指标暴露在 `/metrics` 端点
- **告警**：都察院审查失败时自动发送 Slack 通知

---

如有疑问，请参考 [README.md](README.md) 或提交 [Issue](https://github.com/aitogether/imperial-cabinet-openclaw/issues)。
