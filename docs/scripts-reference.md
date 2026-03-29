# 运维脚本说明 · Scripts Reference

内阁都察制提供三个运维脚本，由东厂（monitor）维护，配合 cron 定期执行。

## 脚本清单

| 脚本 | 功能 | 建议频率 |
|------|------|---------|
| `cost-tracker.sh` | 算力与存储成本统计 | 每周一次 |
| `healthcheck.sh` | 系统健康巡检 | 每 30 分钟 |
| `retrospective.sh` | Git 产出与会话复盘 | 每周一次 |

---

## 1. cost-tracker.sh — 户部成本统计

### 功能
- 扫描 LCM 数据库的会话数、消息数、存储占用
- 按模型分类统计 token 用量
- 输出结构化报告

### 用法
```bash
bash scripts/cost-tracker.sh
```

### 输出示例
```
📊 LCM 成本统计
| 指标 | 数值 |
|------|------|
| 会话数 | 199 |
| 消息数 | 17,377 |
| 存储大小 | 1.8G |
| 摘要数 | 2,120 |
```

### 配合 cron
```bash
# 每周一早上 9 点执行
0 9 * * 1 bash ~/.openclaw/workspace/scripts/cost-tracker.sh >> ~/.openclaw/workspace/logs/cost.log 2>&1
```

---

## 2. healthcheck.sh — 东厂健康巡检

### 功能
检查 6 项健康指标：

| 检查项 | 正常 | 警告 | 告警 |
|--------|------|------|------|
| Gateway | 运行中 | — | 未运行 |
| 磁盘空间 | <80% | 80-90% | >90% |
| 内存压力 | 正常 | 偏高 | 临界 |
| LCM 数据库 | 完整性 OK | 不存在 | 损坏 |
| 日志错误 | <50/小时 | — | >50/小时 |
| Agent 目录 | 存在 | — | 缺失 |

### 用法
```bash
# 正常模式（输出报告）
bash scripts/healthcheck.sh

# 静默模式（cron 用，只在异常时输出）
bash scripts/healthcheck.sh --quiet
```

### 返回码
| 码 | 含义 |
|----|------|
| 0 | 正常或警告 |
| 1 | 存在告警 |

### 配合 cron
```bash
# 每 30 分钟检查，异常时通知
*/30 * * * * bash ~/.openclaw/workspace/scripts/healthcheck.sh --quiet || echo "健康检查异常"
```

---

## 3. retrospective.sh — 东厂复盘官

### 功能
- Git 提交统计（数量、新增/删除行数、变更文件数）
- 热点文件排行（改动最多的文件）
- 贡献者统计
- 最近提交列表
- LCM 会话活跃度（活跃会话数、消息总数）
- 已安装 Skill 清单

### 用法
```bash
# 默认：统计最近 7 天
bash scripts/retrospective.sh

# 指定天数
bash scripts/retrospective.sh 30

# 指定仓库路径
bash scripts/retrospective.sh 7 /path/to/repo
```

### 输出
- 终端打印完整报告
- 同时保存到 `reports/retro-YYYY-MM-DD.md`

### 配合 cron
```bash
# 每周日晚 10 点生成复盘报告
0 22 * * 0 bash ~/.openclaw/workspace/scripts/retrospective.sh >> ~/.openclaw/workspace/logs/retro.log 2>&1
```

---

## 日志目录建议

```bash
mkdir -p ~/.openclaw/workspace/logs
```

| 脚本 | 日志路径 |
|------|---------|
| cost-tracker.sh | `logs/cost.log` |
| healthcheck.sh | `logs/healthcheck.log` |
| retrospective.sh | `logs/retro.log` |

> 日志目录默认不在 Git 中，建议在 `.gitignore` 中排除 `logs/`。
