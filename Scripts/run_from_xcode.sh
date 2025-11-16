#!/bin/bash

# 脚本名称: run_from_xcode.sh
# 描述: 从终端运行应用并显示彩色日志

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/Build"
APP_NAME="Nota4"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/$APP_NAME"
DEBUG_EXECUTABLE="$PROJECT_ROOT/.build/debug/$APP_NAME"

echo "🚀 启动 Nota4（调试模式）..."

# 方案 1: 如果 .app 包存在且是最新的，使用它
if [ -f "$EXECUTABLE_PATH" ]; then
    echo "📦 使用应用包: $APP_PATH"
    
    # 停止旧实例
    if pgrep -x "$APP_NAME" > /dev/null; then
        echo "🛑 停止旧实例..."
        killall "$APP_NAME" 2>/dev/null || true
        sleep 0.5
    fi
    
    # 启动应用，输出重定向到终端
    echo "▶️  启动应用..."
    echo "📝 日志输出:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    "$EXECUTABLE_PATH" 2>&1 &
    APP_PID=$!
    
    # 等待一会儿让应用启动
    sleep 1
    
    # 监控日志（从系统日志中读取）
    log stream --predicate "process == \"$APP_NAME\"" --style compact --color always 2>/dev/null | while IFS= read -r line; do
        # 彩色输出
        if [[ $line == *"[EXIT]"* ]]; then
            echo -e "\033[0;31m$line\033[0m"  # 红色
        elif [[ $line == *"[CREATE]"* ]]; then
            echo -e "\033[0;35m$line\033[0m"  # 紫色
        elif [[ $line == *"[SAVE]"* ]]; then
            echo -e "\033[0;34m$line\033[0m"  # 蓝色
        elif [[ $line == *"[LOAD]"* ]]; then
            echo -e "\033[0;32m$line\033[0m"  # 绿色
        elif [[ $line == *"[FOCUS]"* ]]; then
            echo -e "\033[0;33m$line\033[0m"  # 黄色
        elif [[ $line == *"[BINDING]"* ]]; then
            echo -e "\033[0;36m$line\033[0m"  # 青色
        else
            echo "$line"
        fi
    done
    
# 方案 2: 否则使用调试可执行文件
elif [ -f "$DEBUG_EXECUTABLE" ]; then
    echo "⚠️  应用包不存在，使用调试可执行文件"
    echo "📝 注意: 可能无法显示窗口，建议先运行 'make run'"
    echo "▶️  启动应用..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    "$DEBUG_EXECUTABLE" 2>&1 | while IFS= read -r line; do
        # 彩色输出
        if [[ $line == *"[EXIT]"* ]]; then
            echo -e "\033[0;31m$line\033[0m"
        elif [[ $line == *"[CREATE]"* ]]; then
            echo -e "\033[0;35m$line\033[0m"
        elif [[ $line == *"[SAVE]"* ]]; then
            echo -e "\033[0;34m$line\033[0m"
        elif [[ $line == *"[LOAD]"* ]]; then
            echo -e "\033[0;32m$line\033[0m"
        elif [[ $line == *"[FOCUS]"* ]]; then
            echo -e "\033[0;33m$line\033[0m"
        elif [[ $line == *"[BINDING]"* ]]; then
            echo -e "\033[0;36m$line\033[0m"
        else
            echo "$line"
        fi
    done
else
    echo "❌ 错误: 找不到可执行文件"
    echo "请先运行: make run"
    exit 1
fi
