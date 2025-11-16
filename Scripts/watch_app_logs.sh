#!/bin/bash

# Nota4 实时日志监控 - 简化版
# 用于在 Xcode 运行应用时实时查看日志

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOGS_DIR="$PROJECT_ROOT/Logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOGS_DIR/app_console_$TIMESTAMP.log"

mkdir -p "$LOGS_DIR"

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Nota4 实时日志监控                  ║${NC}"
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo ""
echo -e "${GREEN}📝 现在请在 Xcode 中点击 Run 按钮${NC}"
echo -e "${GREEN}🔍 我会自动捕获所有日志...${NC}"
echo ""
echo -e "${YELLOW}⏸  按 Ctrl+C 停止监控${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 统计计数器
error_count=0
warning_count=0
info_count=0

# 捕获 Ctrl+C
trap cleanup EXIT

cleanup() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📊 监控统计:${NC}"
    echo -e "  ${RED}错误: $error_count${NC}"
    echo -e "  ${YELLOW}警告: $warning_count${NC}"
    echo -e "  ${GREEN}信息: $info_count${NC}"
    echo ""
    echo -e "${GREEN}✅ 日志已保存到:${NC}"
    echo -e "  $LOG_FILE"
    echo ""
    
    # 如果有错误，显示
    if [ "$error_count" -gt 0 ]; then
        echo -e "${RED}⚠️  发现 $error_count 个错误！${NC}"
        echo -e "${YELLOW}查看错误详情:${NC}"
        echo -e "  grep ERROR $LOG_FILE"
        echo ""
    fi
}

# 监控日志
log stream \
    --predicate 'processImagePath contains "Nota4" OR subsystem contains "nota4"' \
    --style compact \
    --level debug \
    --color always \
    2>&1 | while read -r line; do
    
    # 保存到文件
    echo "$line" >> "$LOG_FILE"
    
    # 提取时间戳和消息
    timestamp=$(date '+%H:%M:%S')
    
    # 根据日志级别分类显示
    if echo "$line" | grep -qi "error"; then
        ((error_count++))
        echo -e "${RED}[${timestamp}] [ERROR]${NC} $line"
    elif echo "$line" | grep -qi "warning"; then
        ((warning_count++))
        echo -e "${YELLOW}[${timestamp}] [WARN]${NC} $line"
    elif echo "$line" | grep -qi "crash\|fatal\|exception"; then
        ((error_count++))
        echo -e "${RED}[${timestamp}] [FATAL]${NC} $line"
        # 响铃提示
        printf '\a'
    else
        ((info_count++))
        echo -e "${GREEN}[${timestamp}]${NC} $line"
    fi
done

