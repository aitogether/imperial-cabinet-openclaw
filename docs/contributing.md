# 贡献指南 · Contributing

## 如何新增 Skill

### 目录结构

```
skills/
└── my-skill/
    ├── SKILL.md          ← 必须：Skill 指令文件
    └── references/       ← 可选：参考文档
```

### SKILL.md 模板

```markdown
# /my-skill — 部门名

## 角色
一句话描述此 Skill 的职责。

## 激活条件
用户说什么话时触发。

## 执行步骤
1. 第一步
2. 第二步
...

## 输出
产出什么 artefact（文件/报告/代码）。

## 禁止
- 不能做什么
- 不能越权做什么
```

### 命名规范

| 项目 | 规范 | 示例 |
|------|------|------|
| 目录名 | 小写英文 + 连字符 | `my-skill` |
| Skill 名 | 中文斜杠命令 | `/my-skill` |
| 部门 | 对应 AGENTS.md 中的部门 | 御史台 |

### 注册流程

1. 在 `skills/` 下创建目录
2. 编写 `SKILL.md`
3. 重启 Gateway：`openclaw gateway restart`
4. Skill 自动出现在 `<available_skills>` 列表

---

## 如何新增 Agent

### 步骤

1. **确定归属**：八部 / 一厂 / 御史台 / 新设
2. **编写定义**：在 `AGENTS.md` 中添加角色描述
3. **创建 Skill**：如需执行能力，在 `skills/` 下新建
4. **更新架构文档**：同步到 `docs/architecture.md`
5. **更新权限矩阵**：同步到 `docs/governance.md`

### 注意事项

- 新 Agent 需要明确的职责边界，避免与现有角色重叠
- 御前首辅的调度规则需同步更新（如需被调度）

---

## 提交规范

### Commit 格式

```
<类型>: <简短描述>

类型：
- feat: 新功能 / 新 Skill
- fix: 修复
- docs: 文档更新
- style: 格式调整
- refactor: 重构
- chore: 杂项
```

### 示例

```
feat: 新增 /质检 Skill — 浏览器自动化测试
fix: healthcheck.sh 磁盘空间检查逻辑
docs: 更新数据流架构文档
chore: 添加 CHANGELOG
```

---

## 发布流程

1. 更新 `docs/changelog.md`
2. 更新版本号（如适用）
3. 提交并推送 Git
4. 在 GitHub 创建 Release（可选）

---

## 版本号规范

采用 [SemVer](https://semver.org/) 语义化版本：

- **MAJOR**：不兼容的架构变更
- **MINOR**：新增 Skill 或功能
- **PATCH**：修复和文档更新
