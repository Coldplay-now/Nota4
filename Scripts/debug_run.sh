#!/bin/bash

# 调试运行脚本 - 捕获控制台输出

LOG_FILE="/Users/xt/LXT/code/trae/1107-model-eval/Nota4/Logs/debug_$(date +%Y%m%d_%H%M%S).log"

echo "🚀 Starting Nota4 with debug logging..."
echo "📝 Log file: $LOG_FILE"

# 停止旧进程
pkill -9 -x Nota4 2>/dev/null

sleep 1

# 启动应用并捕获输出
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
./Build/Nota4.app/Contents/MacOS/Nota4 > "$LOG_FILE" 2>&1 &

echo "✅ Nota4 started"
echo "📊 To view logs: tail -f $LOG_FILE"
echo "🔍 To filter sidebar logs: tail -f $LOG_FILE | grep SIDEBAR"









