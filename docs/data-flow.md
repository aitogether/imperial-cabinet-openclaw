# 数据流架构 · Data Flow

## 核心数据存储

| 存储 | 路径 | 用途 | 格式 |
|------|------|------|------|
| OpenClaw 配置 | `~/.openclaw/openclaw.json` | 全局配置 | JSON |
| LCM 数据库 | `~/.openclaw/lcm.db` | 会话历史、摘要 | SQLite |
| Workspace | `~/.openclaw/workspace/` | 脚本、文档、项目 | 文件系统 |
| 记忆文件 | `~/.openclaw/workspace/MEMORY.md` | 长期记忆总则 | Markdown |
| 记忆片段 | `~/.openclaw/workspace/memory/*.md` | 按日期/主题的记忆 | Markdown |

## 消息流转路径

```
用户消息
  │
  ▼
┌─────────────────────────────┐
│  OpenClaw Gateway            │
│  鉴权 → 路由 → 模型调用      │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  御前首辅 (main)             │
│  加载: SOUL.md / MEMORY.md  │
│  / AGENTS.md / 会话历史      │
└──────────┬──────────────────┘
           │
     ┌─────┼─────┬─────────┐
     ▼     ▼     ▼         ▼
   内阁  工部  御史台    东厂 ...
     │     │     │         │
     └─────┴─────┴─────────┘
           │
           ▼
┌─────────────────────────────┐
│  LCM 数据库 (lcm.db)        │
│  自动压缩旧消息为摘要        │
└─────────────────────────────┘
```

## LCM 数据库详解

### 摘要压缩机制

当会话历史超过上下文窗口时：

1. **原始消息** → 压缩为 `sum_xxx` 摘要
2. 摘要保留**关键信息**：决策、结论、数字
3. 摘要形成 **DAG**（有向无环图），支持递归展开
4. 摘要附带 `Expand for details about:` 脚注

### 检索工具

| 工具 | 用途 | 成本 |
|------|------|------|
| `lcm_grep` | 正则/全文搜索 | ⚡ 低 |
| `lcm_describe` | 查看摘要元数据 | ⚡ 低 |
| `lcm_expand` | 展开摘要 DAG | 🐢 中 |
| `lcm_expand_query` | 委派子代理深度回忆 | 🐌 高 (~120s) |

### 检索优先级

```
lcm_grep → lcm_describe → lcm_expand → lcm_expand_query
                                          ↑ 最后手段
```

## Memory 文件

### 写入规则

| 场景 | 写入位置 |
|------|---------|
| 重要决策 | `memory/YYYY-MM-DD-topic.md` |
| 用户偏好 | `USER.md` 或 `memory/` |
| 硬规则变更 | `MEMORY.md` |
| 项目复盘 | `reports/` |

### 读取方式

- `memory_search("关键词")` — 语义搜索
- `memory_get("path", from, lines)` — 精确读取

## Workspace 文件流

```
~/.openclaw/workspace/
├── AGENTS.md          ← 每次对话加载
├── SOUL.md            ← 每次对话加载
├── USER.md            ← 每次对话加载
├── MEMORY.md          ← 每次对话加载
├── IDENTITY.md        ← 每次对话加载
├── TOOLS.md           ← 每次对话加载
├── HEARTBEAT.md       ← 心跳时检查
├── skills/*/SKILL.md  ← 按需加载（匹配时）
├── scripts/           ← 手动执行或 cron
├── memory/*.md        ← memory_search 按需
└── reports/           ← retrospective.sh 生成
```

## Skill 加载机制

```
用户消息 → 扫描 <available_skills> 列表
              │
              ├── 匹配 description
              ├── 找到最匹配的 Skill
              └── 读取 SKILL.md（只读一个）
```

**关键规则**：
- 每次对话**最多加载 1 个** Skill
- 多个匹配时选**最具体**的
- Skill 是**指令文件**，不是可执行代码
