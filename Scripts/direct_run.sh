#!/bin/bash

# Nota4 直接运行脚本（避免 open 命令问题）

set -e

cd "$(dirname "$0")/.."

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nota4 快速运行${NC}"

# 1. 增量构建
echo -e "${BLUE}⚙️  编译中...${NC}"
swift build -c debug 2>&1 | grep -E "Compiling|Linking|Build complete" || true

# 2. 关闭旧实例
pkill -x Nota4 2>/dev/null || true

# 3. 直接运行可执行文件
echo -e "${GREEN}▶️  启动 Nota4...${NC}"
.build/debug/Nota4 &

sleep 1

# 检查是否成功启动
if pgrep -x Nota4 > /dev/null; then
    echo -e "${GREEN}✅ Nota4 启动成功！${NC}"
else
    echo -e "\033[0;31m❌ Nota4 启动失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 完成！${NC}"
