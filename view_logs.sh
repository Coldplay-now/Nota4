#!/bin/bash

# 查看 Nota4 应用的实时日志输出
# 这个脚本会过滤出我们添加的调试信息

echo "======================================"
echo "开始监控 Nota4 应用日志"
echo "请在应用中插入图片，然后观察输出"
echo "按 Ctrl+C 停止监控"
echo "======================================"
echo ""

# 使用 log stream 命令监控应用日志，过滤出包含我们标记的行
log stream --process Nota4 --level debug --style compact | grep -E "\[INSERT\]|\[RENDER\]|\[PROCESS\]|\[WebView\]|🖼️|🎨|🔍|🌐|✅|❌|⚠️"






