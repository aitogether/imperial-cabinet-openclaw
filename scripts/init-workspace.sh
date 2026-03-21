#!/usr/bin/env bash
# ============================================================
# 内阁都察制 · 工作区初始化脚本
# Imperial Cabinet & Censorate — Workspace Init Script
# ============================================================
#
# 使用方法：
#   bash scripts/init-workspace.sh
#
# 功能：
#   - 创建 ~/.openclaw/workspace 目录（如不存在）
#   - 将 workspace-templates/*.example.* 拷贝为实际文件
#   - ⚠️ 不会覆盖已有文件（安全操作）
#
# 注意：
#   - 这是示例脚本，用户可以自行调整路径或策略
#   - 不做任何破坏性操作

set -e

WORKSPACE="${HOME}/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="${REPO_ROOT}/workspace-templates"

echo "🐲 内阁都察制 · 工作区初始化"
echo "=========================="
echo ""

# 检查模板目录是否存在
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "❌ 模板目录不存在: $TEMPLATES_DIR"
    echo "   请确保在仓库根目录下运行此脚本。"
    exit 1
fi

# 创建工作区目录
if [ ! -d "$WORKSPACE" ]; then
    echo "📁 创建工作区目录: $WORKSPACE"
    mkdir -p "$WORKSPACE"
else
    echo "📁 工作区目录已存在: $WORKSPACE"
fi

# 拷贝模板文件（不覆盖已有文件）
copy_if_not_exists() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -f "$dst" ]; then
        echo "⏭️  跳过 $name（已存在，不覆盖）"
    else
        cp "$src" "$dst"
        echo "✅ 创建 $name"
    fi
}

echo ""
echo "📋 拷贝模板文件..."
echo ""

copy_if_not_exists \
    "${TEMPLATES_DIR}/USER.example.md" \
    "${WORKSPACE}/USER.md" \
    "USER.md（用户画像）"

copy_if_not_exists \
    "${TEMPLATES_DIR}/SOUL.example.md" \
    "${WORKSPACE}/SOUL.md" \
    "SOUL.md（御前首辅人设）"

copy_if_not_exists \
    "${TEMPLATES_DIR}/AGENTS.example.md" \
    "${WORKSPACE}/AGENTS.md" \
    "AGENTS.md（架构总览）"

copy_if_not_exists \
    "${TEMPLATES_DIR}/MEMORY.example.md" \
    "${WORKSPACE}/MEMORY.md" \
    "MEMORY.md（长期规则）"

echo ""
echo "=========================="
echo "✅ 初始化完成！"
echo ""
echo "下一步："
echo "  1. 编辑 ${WORKSPACE}/ 下的文件，根据你的需求自定义"
echo "  2. 确保 ~/.openclaw/openclaw.yaml 已正确配置"
echo "  3. 启动 OpenClaw: openclaw gateway start"
echo ""
