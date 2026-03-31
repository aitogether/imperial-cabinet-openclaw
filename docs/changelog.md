# 变更日志 · Changelog

## v2.1.0 (2026-03-31)

### 新增

- **`/审` 审查并行编排 Skill**（`skills-reference/review-parallel/SKILL.md`）
  - 四路并行：审码/审安/审设/codex 同时执行，提速 3 倍
  - 设计理念来自华罗庚《统筹方法》：互不依赖的工序应并行执行
  - 汇总裁决：交叉验证 + 盲区识别 + 终审裁决

### 改进

- 审查阶段从串行 4 步重构为并行 1 步（`/审` 编排入口）
- AGENTS.example.md 路由规则更新，状态机描述同步
- MEMORY.example.md 升级为 v2.1，Skill 清单 11→12
- README.md 更新版本号、Skill 数量、文件树

### 文件变更

| 文件 | 操作 |
|------|------|
| `skills-reference/review-parallel/SKILL.md` | 新增 |
| `workspace-templates/AGENTS.example.md` | 更新（阶段 4 并行化） |
| `workspace-templates/MEMORY.example.md` | 更新（v2.1 + 12 Skills） |
| `README.md` | 更新（版本号 + Skill 数量） |
| `docs/changelog.md` | 本条 |

---

## v2.0.0-alpha (2026-03-29)

### 新增

- **11 个 Skill 实装**：从 AGENTS.md 内联描述升级为独立 SKILL.md 文件
  - 问诊、审码、审安、审设、调查、codex、质检、性能、发布、部署、复盘
- **3 个运维脚本**：成本追踪、健康检查、复盘自动化
- **仪表盘集成**：OpenClaw Bot Dashboard 部署验证
- **5 篇新文档**：数据流、仪表盘、脚本说明、贡献指南、变更日志

### 改进

- 内阁都察制 v2 架构文档全面更新
- 任务状态机从 7 个扩展到 9 个（含取消和封驳）
- Agent 间通讯权限矩阵正式定义

### 修复

- healthcheck.sh 的 check 函数逻辑（OK 判断条件修复）

---

## v1.0.0 (2026-03-25)

### 初始版本

- 内阁都察制架构定义
- 八部一厂 + 御史台角色定义
- 基础 workspace 模板
- GitHub 仓库初始化
- 24 个已安装 Skill（含内置 + 自定义）
