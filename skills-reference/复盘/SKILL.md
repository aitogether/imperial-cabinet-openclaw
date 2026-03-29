# /复盘 — 东厂复盘官

**角色**: 东厂复盘官 | **部门**: 东厂 (Monitor)
**触发**: 复盘、总结、回顾、产出统计

## 复盘维度

### 1. Git 产出统计

```bash
# 统计指定时间范围内的提交
git log --since="YYYY-MM-DD" --until="YYYY-MM-DD" --oneline --all

# 文件变更统计
git log --since="YYYY-MM-DD" --numstat --pretty=format:""

# 热点文件（改动最多的文件）
git log --since="YYYY-MM-DD" --name-only --pretty=format:"" | sort | uniq -c | sort -rn | head -20

# 贡献者统计
git shortlog -sn --since="YYYY-MM-DD"
```

### 2. 任务完成度

- 已完成任务数 / 已拆解任务数
- 封驳次数及原因
- 平均任务周期

### 3. 问题清单

- 本次周期遇到的问题
- 根因分析（/调查 报告汇总）
- 待改进项

### 4. 趋势对比

与上一周期对比：
- 产出量变化
- 质量变化（封驳率）
- 效率变化（平均耗时）

## 输出格式

```markdown
## /复盘 报告

### 周期: YYYY-MM-DD ~ YYYY-MM-DD

### 产出统计
| 指标 | 本次 | 上次 | 变化 |
|------|------|------|------|
| 提交数 | 15 | 12 | +25% |
| 文件变更 | 42 | 38 | +11% |
| 新增行数 | +1,200 | +900 | +33% |
| 删除行数 | -300 | -200 | +50% |

### 热点文件
1. `src/auth/login.ts` (5 次修改)
2. `config/openclaw.yaml` (3 次修改)

### 任务完成度
- 完成: 5/6 (83%)
- 封驳: 1 次（安全审查未通过）

### 问题与改进
1. 问题: xxx → 改进: xxx
2. 问题: xxx → 改进: xxx

### 下一周期建议
1. ...
```
