#!/bin/bash
# healthcheck.sh — 东厂健康监控
# 检查 OpenClaw Gateway、模型可用性、磁盘空间等
# 用法: bash healthcheck.sh [--quiet]
# 配合 cron 使用: */30 * * * * bash ~/.openclaw/workspace/scripts/healthcheck.sh --quiet

set -euo pipefail

QUIET="${1:-}"
ALERTS=""
WARNINGS=""
STATUS="✅"

check() {
  local name="$1"
  local result="$2"
  if [[ "$result" == OK* ]]; then
    : # 正常
  else
    ALERTS="${ALERTS}\n🔴 **${name}**: ${result}"
    STATUS="🔴"
  fi
}

warn() {
  local name="$1"
  local msg="$2"
  WARNINGS="${WARNINGS}\n🟡 **${name}**: ${msg}"
  if [ "$STATUS" = "✅" ]; then
    STATUS="🟡"
  fi
}

# 1. Gateway 状态
GW_STATUS=$(openclaw gateway status 2>&1 | grep -i "running\|active\|ok\|healthy" || echo "DOWN")
if echo "$GW_STATUS" | grep -qi "running\|active\|ok\|healthy"; then
  check "Gateway" "OK"
else
  check "Gateway" "未运行"
fi

# 2. 磁盘空间
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
  check "磁盘空间" "使用率 ${DISK_USAGE}% — 危险"
elif [ "$DISK_USAGE" -gt 80 ]; then
  warn "磁盘空间" "使用率 ${DISK_USAGE}% — 注意"
else
  check "磁盘空间" "OK (${DISK_USAGE}%)"
fi

# 3. 内存压力
MEM_PRESSURE=$(memory_pressure 2>/dev/null | grep "System-wide" | head -1 || echo "unknown")
if echo "$MEM_PRESSURE" | grep -qi "critical\|warning"; then
  check "内存" "内存压力过高"
elif echo "$MEM_PRESSURE" | grep -qi "stressed"; then
  warn "内存" "内存压力偏高"
else
  check "内存" "OK"
fi

# 4. LCM 数据库完整性
LCM_DB="$HOME/.openclaw/lcm.db"
if [ -f "$LCM_DB" ]; then
  INTEGRITY=$(sqlite3 "$LCM_DB" "PRAGMA integrity_check;" 2>&1)
  if [ "$INTEGRITY" = "ok" ]; then
    check "LCM 数据库" "OK"
  else
    check "LCM 数据库" "损坏: ${INTEGRITY}"
  fi
else
  warn "LCM 数据库" "文件不存在"
fi

# 5. OpenClaw 日志错误检查
LOG_DIR="$HOME/.openclaw/logs"
if [ -d "$LOG_DIR" ]; then
  RECENT_ERRORS=$(find "$LOG_DIR" -name "*.log" -mmin -60 -exec grep -c "ERROR\|FATAL\|CRASH" {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
  if [ "$RECENT_ERRORS" -gt 50 ]; then
    warn "日志错误" "最近 1 小时有 ${RECENT_ERRORS} 条错误日志"
  else
    check "日志" "OK (最近1小时 ${RECENT_ERRORS} 条错误)"
  fi
fi

# 6. Agent 目录检查
AGENT_DIR="$HOME/.openclaw/agents"
if [ -d "$AGENT_DIR" ]; then
  AGENT_COUNT=$(ls -1d "$AGENT_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
  check "Agent 目录" "OK (${AGENT_COUNT} 个 agent)"
fi

# === 输出 ===
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ -n "$ALERTS" ] || [ -n "$WARNINGS" ]; then
  echo "🚨 健康检查报告 — ${TIMESTAMP}"
  echo "状态: ${STATUS}"
  echo ""
  if [ -n "$ALERTS" ]; then
    echo "### 🔴 告警"
    echo -e "$ALERTS"
  fi
  if [ -n "$WARNINGS" ]; then
    echo "### 🟡 警告"
    echo -e "$WARNINGS"
  fi
else
  if [ "$QUIET" != "--quiet" ]; then
    echo "✅ 健康检查通过 — ${TIMESTAMP}"
    echo "Gateway: 运行中 | 磁盘: ${DISK_USAGE}% | 内存: OK | 数据库: OK"
  fi
fi

# 返回状态码（供 cron 使用）
if [ "$STATUS" = "🔴" ]; then
  exit 1
elif [ "$STATUS" = "🟡" ]; then
  exit 0  # 警告不报错
else
  exit 0
fi
