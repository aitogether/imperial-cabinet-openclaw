#!/bin/bash
# retrospective.sh — 东厂复盘官自动化
# 生成 Git 产出统计 + 任务完成度报告
# 用法: bash retrospective.sh [仓库路径] [天数，默认7]

set -euo pipefail

# 参数: retrospective.sh [天数，默认7] [仓库路径，默认workspace]
DAYS="${1:-7}"
REPO="${2:-$HOME/.openclaw/workspace}"
DATE=$(date +%Y-%m-%d)
REPORT_DIR="$HOME/.openclaw/workspace/reports"
REPORT_FILE="$REPORT_DIR/retro-${DATE}.md"
SINCE_DATE=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "-${DAYS} days" +%Y-%m-%d)

mkdir -p "$REPORT_DIR"

echo "# 📋 东厂复盘报告 — ${DATE}"
echo ""
echo "周期: ${SINCE_DATE} ~ ${DATE} (${DAYS} 天)"
echo "仓库: ${REPO}"
echo ""

cd "$REPO" 2>/dev/null || { echo "⚠️ 仓库路径不存在: $REPO"; exit 1; }

# 检查是否是 git 仓库
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "⚠️ 不是 Git 仓库"
  exit 1
fi

# === 提交统计 ===
COMMIT_COUNT=$(git log --since="$SINCE_DATE" --oneline --all 2>/dev/null | wc -l | tr -d ' ')
echo "## 提交统计"
echo "| 指标 | 数值 |"
echo "|------|------|"
echo "| 提交数 | ${COMMIT_COUNT} |"

# 新增/删除行数
ADDED=$(git log --since="$SINCE_DATE" --numstat --pretty=format:"" 2>/dev/null | awk '{a+=$1} END {print a+0}')
DELETED=$(git log --since="$SINCE_DATE" --numstat --pretty=format:"" 2>/dev/null | awk '{d+=$2} END {print d+0}')
echo "| 新增行数 | +${ADDED} |"
echo "| 删除行数 | -${DELETED} |"

# 变更文件数
CHANGED_FILES=$(git log --since="$SINCE_DATE" --name-only --pretty=format:"" 2>/dev/null | sort -u | grep -v "^$" | wc -l | tr -d ' ')
echo "| 变更文件数 | ${CHANGED_FILES} |"

# === 热点文件 ===
echo ""
echo "## 热点文件（改动最多）"
echo "| 次数 | 文件 |"
echo "|------|------|"
git log --since="$SINCE_DATE" --name-only --pretty=format:"" 2>/dev/null \
  | grep -v "^$" \
  | sort | uniq -c | sort -rn | head -10 \
  | while read count file; do
      echo "| ${count} | \`${file}\` |"
    done

# === 贡献者 ===
echo ""
echo "## 贡献者"
echo "| 提交数 | 贡献者 |"
echo "|--------|--------|"
git shortlog -sn --since="$SINCE_DATE" --all 2>/dev/null \
  | while read count author; do
      echo "| ${count} | ${author} |"
    done

# === 最近提交 ===
echo ""
echo "## 最近提交（${DAYS}天内）"
echo '```'
git log --since="$SINCE_DATE" --oneline --all --decorate 2>/dev/null | head -20
echo '```'

# === LCM 会话统计 ===
LCM_DB="$HOME/.openclaw/lcm.db"
if [ -f "$LCM_DB" ]; then
  echo ""
  echo "## 会话活跃度"
  RECENT_MSGS=$(sqlite3 "$LCM_DB" "SELECT COUNT(*) FROM messages WHERE datetime(created_at) >= datetime('now', '-${DAYS} days');" 2>/dev/null || echo "N/A")
  ACTIVE_CONVS=$(sqlite3 "$LCM_DB" "SELECT COUNT(DISTINCT conversation_id) FROM messages WHERE datetime(created_at) >= datetime('now', '-${DAYS} days');" 2>/dev/null || echo "N/A")
  echo "| 指标 | 数值 |"
  echo "|------|------|"
  echo "| 活跃会话数 | ${ACTIVE_CONVS} |"
  echo "| 消息总数 | ${RECENT_MSGS} |"
fi

# === Skills 使用 ===
echo ""
echo "## 已安装 Skills"
SKILL_COUNT=$(ls -1d "$HOME/.openclaw/workspace/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "共 ${SKILL_COUNT} 个："
ls -1 "$HOME/.openclaw/workspace/skills/" 2>/dev/null | while read skill; do
  echo "- /${skill}"
done

# === 输出文件 ===
{
  echo "# 📋 东厂复盘报告 — ${DATE}"
  echo ""
  echo "周期: ${SINCE_DATE} ~ ${DATE} (${DAYS} 天)"
  echo ""
  echo "## 提交统计"
  echo "| 提交 | +行 | -行 | 文件 |"
  echo "|------|-----|-----|------|"
  echo "| ${COMMIT_COUNT} | +${ADDED} | -${DELETED} | ${CHANGED_FILES} |"
  echo ""
  echo "## 会话活跃度"
  echo "| 活跃会话 | 消息数 |"
  echo "|---------|--------|"
  echo "| ${ACTIVE_CONVS:-N/A} | ${RECENT_MSGS:-N/A} |"
  echo ""
  echo "---"
  echo "*由东厂复盘官自动生成*"
} > "$REPORT_FILE" 2>/dev/null || true

echo ""
echo "---"
echo "✅ 复盘报告已保存: ${REPORT_FILE}"
