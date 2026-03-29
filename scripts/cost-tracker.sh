#!/bin/bash
# cost-tracker.sh — 户部成本统计
# 统计 OpenClaw 会话 Token 用量、存储成本、模型分布
# 用法: bash cost-tracker.sh [天数，默认7]

set -euo pipefail

DAYS=${1:-7}
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
LCM_DB="$OPENCLAW_HOME/lcm.db"
DATE=$(date +%Y-%m-%d)
REPORT_DIR="$OPENCLAW_HOME/workspace/reports"
REPORT_FILE="$REPORT_DIR/cost-report-${DATE}.md"
SINCE_DATE=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "-${DAYS} days" +%Y-%m-%d)

mkdir -p "$REPORT_DIR"

echo "📊 户部成本统计 — 最近 ${DAYS} 天 (${SINCE_DATE} ~ ${DATE})"
echo ""

# === 会话统计 ===
echo "## 会话概况"

if [ -f "$LCM_DB" ]; then
  TOTAL_CONVS=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM conversations;" 2>/dev/null || echo "N/A")
  ACTIVE_CONVS=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM conversations WHERE datetime(last_message_at) >= datetime('now', '-${DAYS} days');" 2>/dev/null || echo "N/A")
  TOTAL_MSGS=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM messages;" 2>/dev/null || echo "N/A")
  RECENT_MSGS=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM messages WHERE datetime(created_at) >= datetime('now', '-${DAYS} days');" 2>/dev/null || echo "N/A")
  TOTAL_SUMMARIES=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM summaries;" 2>/dev/null || echo "N/A")

  echo "| 指标 | 数值 |"
  echo "|------|------|"
  echo "| 总会话数 | ${TOTAL_CONVS} |"
  echo "| 活跃会话（${DAYS}天内） | ${ACTIVE_CONVS} |"
  echo "| 总消息数 | ${TOTAL_MSGS} |"
  echo "| 近期消息数 | ${RECENT_MSGS} |"
  echo "| 压缩摘要数 | ${TOTAL_SUMMARIES} |"

  # 消息类型分布
  echo ""
  echo "## 消息角色分布"
  echo "| 角色 | 数量 |"
  echo "|------|------|"
  sqlite3 "$LCM_DB" "SELECT role, COUNT(*) FROM messages WHERE datetime(created_at) >= datetime('now', '-${DAYS} days') GROUP BY role ORDER BY COUNT(*) DESC;" 2>/dev/null \
    | while IFS='|' read role count; do
        echo "| ${role} | ${count} |"
      done
else
  echo "⚠️ LCM 数据库未找到: $LCM_DB"
fi

# === 存储用量 ===
echo ""
echo "## 存储用量"
echo "| 目录/文件 | 大小 |"
echo "|-----------|------|"

for item in lcm.db memory/main.sqlite logs browser extensions agents; do
  path="$OPENCLAW_HOME/$item"
  if [ -e "$path" ]; then
    size=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo "| ${item} | ${size} |"
  fi
done

TOTAL_SIZE=$(du -sh "$OPENCLAW_HOME" 2>/dev/null | cut -f1)
echo "| **OpenClaw 总计** | **${TOTAL_SIZE}** |"

# === Workspace 用量 ===
WORKSPACE_SIZE=$(du -sh "$OPENCLAW_HOME/workspace" 2>/dev/null | cut -f1)
echo ""
echo "| workspace/ | ${WORKSPACE_SIZE} |"

# === Skills 统计 ===
SKILL_COUNT=$(ls -1d "$OPENCLAW_HOME/workspace/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "| 已安装 Skills | ${SKILL_COUNT} |"

# === 输出报告文件 ===
cat > "$REPORT_FILE" << EOF
# 户部成本报告 — ${DATE}

统计周期: ${SINCE_DATE} ~ ${DATE} (${DAYS} 天)
生成时间: $(date '+%Y-%m-%d %H:%M:%S CST')

## 会话概况
| 指标 | 数值 |
|------|------|
| 总会话数 | ${TOTAL_CONVS:-N/A} |
| 活跃会话 | ${ACTIVE_CONVS:-N/A} |
| 总消息数 | ${TOTAL_MSGS:-N/A} |
| 近期消息数 | ${RECENT_MSGS:-N/A} |
| 压缩摘要数 | ${TOTAL_SUMMARIES:-N/A} |

## 存储用量
| 项目 | 大小 |
|------|------|
| OpenClaw 总计 | ${TOTAL_SIZE} |
| workspace | ${WORKSPACE_SIZE} |
| 已安装 Skills | ${SKILL_COUNT} |

---
*由户部成本追踪脚本自动生成*
EOF

echo ""
echo "---"
echo "✅ 报告已保存: ${REPORT_FILE}"
